#!/bin/bash

################################################################################
# Dependency Checker Script for Helmfile Releases
# 
# 功能：
# 1. 解析 helmfile.yaml 中的 releases 配置
# 2. 根据当前 release 名称查找其依赖项（needs）
# 3. 从 helmfile.yaml 读取全局配置（checkInterval、maxRetries）
# 4. 轮询检查依赖项的 pod 是否处于 Running 状态
# 5. 输出详细的检查日志
#
# 环境变量：
# - RELEASE_NAME: 当前 release 名称（必需）
# - NAMESPACE: Kubernetes 命名空间（默认：default）
#
# 配置来源：
# - helmfile.yaml 中的 dependencyChecker 配置
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 基础配置参数
RELEASE_NAME="${RELEASE_NAME:-}"
NAMESPACE="${NAMESPACE:-default}"
HELMFILE_PATH="/helmfile/helmfile.yaml"

# 从 helmfile.yaml 读取的配置（稍后解析）
CHECK_INTERVAL=""
MAX_RETRIES=""
VERBOSE=""

# 日志函数
log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} [INFO] $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} [SUCCESS] $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} [WARNING] $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} [ERROR] $1"
}

# 从 helmfile.yaml 解析全局配置
parse_global_config() {
    log_info "Parsing global configuration from helmfile.yaml"

    # 尝试使用 yq 解析（更可靠）
    if command -v yq &> /dev/null; then
        CHECK_INTERVAL=$(yq eval '.dependencyChecker.checkInterval // 5' "$HELMFILE_PATH" 2>/dev/null || echo "5")
        MAX_RETRIES=$(yq eval '.dependencyChecker.maxRetries // 120' "$HELMFILE_PATH" 2>/dev/null || echo "120")
        VERBOSE=$(yq eval '.dependencyChecker.verbose // true' "$HELMFILE_PATH" 2>/dev/null || echo "true")
    else
        # 降级方案：使用 grep/awk 解析
        CHECK_INTERVAL=$(grep -A 10 "^dependencyChecker:" "$HELMFILE_PATH" 2>/dev/null | grep "checkInterval:" | awk '{print $2}' || echo "5")
        MAX_RETRIES=$(grep -A 10 "^dependencyChecker:" "$HELMFILE_PATH" 2>/dev/null | grep "maxRetries:" | awk '{print $2}' || echo "120")
        VERBOSE=$(grep -A 10 "^dependencyChecker:" "$HELMFILE_PATH" 2>/dev/null | grep "verbose:" | awk '{print $2}' || echo "true")
        
        # 如果没有找到配置，使用默认值
        [ -z "$CHECK_INTERVAL" ] && CHECK_INTERVAL=5
        [ -z "$MAX_RETRIES" ] && MAX_RETRIES=120
        [ -z "$VERBOSE" ] && VERBOSE=true
    fi

    log_info "Configuration loaded:"
    log_info "  - Check Interval: ${CHECK_INTERVAL}s"
    log_info "  - Max Retries: $MAX_RETRIES"
    log_info "  - Verbose: $VERBOSE"
}

# 检查必需的环境变量
check_prerequisites() {
    if [ -z "$RELEASE_NAME" ]; then
        log_error "RELEASE_NAME environment variable is not set"
        exit 1
    fi

    if [ ! -f "$HELMFILE_PATH" ]; then
        log_error "Helmfile not found at: $HELMFILE_PATH"
        exit 1
    fi

    # 检查 kubectl 是否可用
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl command not found"
        exit 1
    fi

    # 检查 yq 是否可用（用于解析 YAML）
    if ! command -v yq &> /dev/null; then
        log_warning "yq not found, will use grep/awk for parsing (less reliable)"
    fi

    # 解析全局配置
    parse_global_config

    log_info "Prerequisites check passed"
    log_info "Release Name: $RELEASE_NAME"
    log_info "Namespace: $NAMESPACE"
}

# 解析 helmfile.yaml 获取依赖项
parse_dependencies() {
    local release_name=$1
    local dependencies=()

    log_info "Parsing dependencies for release: $release_name" >&2

    # 尝试使用 yq 解析（更可靠）
    if command -v yq &> /dev/null; then
        # 使用 yq 解析 needs 字段
        dependencies=($(yq eval ".releases[] | select(.name == \"$release_name\") | .needs[]" "$HELMFILE_PATH" 2>/dev/null || echo ""))
    else
        # 降级方案：使用 grep/awk 解析
        local in_release=false
        local in_needs=false
        
        while IFS= read -r line; do
            # 检测到目标 release
            if echo "$line" | grep -q "name: $release_name"; then
                in_release=true
                continue
            fi
            
            # 在目标 release 中检测 needs 字段
            if [ "$in_release" = true ] && echo "$line" | grep -q "needs:"; then
                in_needs=true
                continue
            fi
            
            # 解析 needs 列表
            if [ "$in_needs" = true ]; then
                # 如果遇到新的顶级字段，停止解析
                if echo "$line" | grep -qE "^[a-zA-Z]"; then
                    break
                fi
                
                # 提取依赖项名称
                local dep=$(echo "$line" | grep -oP '^\s*-\s*\K[a-zA-Z0-9-]+' || echo "")
                if [ -n "$dep" ]; then
                    dependencies+=("$dep")
                fi
            fi
            
            # 如果遇到下一个 release，停止解析
            if [ "$in_release" = true ] && echo "$line" | grep -qE "^\s*-\s*name:"; then
                break
            fi
        done < "$HELMFILE_PATH"
    fi

    # 输出依赖项
    if [ ${#dependencies[@]} -eq 0 ]; then
        log_info "No dependencies found for release: $release_name" >&2
        return 0
    fi

    log_info "Found ${#dependencies[@]} dependencies: ${dependencies[*]}" >&2
    echo "${dependencies[@]}"
}

# 检查单个依赖项的 pod 状态
check_dependency_status() {
    local dep_name=$1
    local namespace=$2

    if [ "$VERBOSE" = "true" ]; then
        log_info "  [DEBUG] Checking dependency: $dep_name in namespace: $namespace" >&2
    fi

    # 使用 app label 查找 pod
    local label_selector="app=$dep_name"

    if [ "$VERBOSE" = "true" ]; then
        log_info "  [DEBUG] Using label selector: $label_selector" >&2
    fi

    # 获取该依赖项的所有 pod 名称
    local pod_names=$(kubectl get pods -n "$namespace" -l "$label_selector" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")

    if [ "$VERBOSE" = "true" ]; then
        log_info "  [DEBUG] Found pod names: '$pod_names'" >&2
    fi

    # 检查是否有 pod
    if [ -z "$pod_names" ] || [ "$pod_names" = " " ]; then
        if [ "$VERBOSE" = "true" ]; then
            log_info "  No pods found with label: $label_selector" >&2
        fi
        echo "NO_PODS"
        return 1
    fi

    # 统计 pod 数量
    local pod_count=$(echo "$pod_names" | wc -w | tr -d ' ')
    log_info "  Found $pod_count pod(s) for dependency '$dep_name'" >&2

    # 检查所有 pod 的状态
    local all_ready=true
    local status_summary=""
    local ready_count=0

    # 解析每个 pod 的状态
    for pod_name in $pod_names; do
        if [ -z "$pod_name" ]; then
            continue
        fi

        local phase=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
        local ready=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "False")
        local container_ready=$(kubectl get pod "$pod_name" -n "$namespace" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")

        # 始终显示 pod 状态，方便调试
        log_info "    Pod: $pod_name | Phase: $phase | Ready: $ready | ContainerReady: $container_ready" >&2

        # 必须同时满足：Phase=Running 且 Ready=True 且 ContainerReady=true
        if [ "$phase" != "Running" ] || [ "$ready" != "True" ] || [ "$container_ready" != "true" ]; then
            all_ready=false
            status_summary="${status_summary}${pod_name}(Phase=$phase,Ready=$ready,ContainerReady=$container_ready) "
        else
            ready_count=$((ready_count + 1))
        fi
    done

    log_info "  Ready pods: $ready_count/$pod_count" >&2

    if [ "$all_ready" = true ] && [ "$ready_count" -gt 0 ]; then
        echo "RUNNING"
        return 0
    else
        echo "NOT_READY: $status_summary"
        return 1
    fi
}

# 等待所有依赖项就绪
wait_for_dependencies() {
    local dependencies=($@)
    
    if [ ${#dependencies[@]} -eq 0 ]; then
        log_success "No dependencies to wait for, proceeding..."
        return 0
    fi

    log_info "Starting dependency check for: ${dependencies[*]}"
    
    local retry_count=0
    local all_ready=false

    while [ $retry_count -lt $MAX_RETRIES ]; do
        retry_count=$((retry_count + 1))
        all_ready=true
        local pending_deps=()

        log_info "Check attempt $retry_count/$MAX_RETRIES"

        for dep in "${dependencies[@]}"; do
            log_info "Checking dependency: $dep"
            
            # 先执行函数并捕获输出，然后立即获取退出码
            local status
            status=$(check_dependency_status "$dep" "$NAMESPACE")
            local exit_code=$?

            if [ $exit_code -eq 0 ]; then
                log_success "✓ Dependency '$dep' is ready (all pods running)"
            else
                all_ready=false
                pending_deps+=("$dep")
                
                if [ "$status" = "NO_PODS" ]; then
                    log_warning "✗ Dependency '$dep' has no pods yet"
                else
                    log_warning "✗ Dependency '$dep' is not ready: $status"
                fi
            fi
        done

        if [ "$all_ready" = true ]; then
            log_success "All dependencies are ready!"
            return 0
        fi

        log_info "Pending dependencies: ${pending_deps[*]}"
        log_info "Waiting ${CHECK_INTERVAL}s before next check..."
        sleep "$CHECK_INTERVAL"
    done

    log_error "Timeout: Dependencies not ready after $MAX_RETRIES attempts"
    log_error "Failed dependencies: ${pending_deps[*]}"
    return 1
}

# 主函数
main() {
    log_info "=========================================="
    log_info "Dependency Checker Starting"
    log_info "=========================================="

    # 检查前置条件
    check_prerequisites

    # 解析依赖项
    local dependencies=($(parse_dependencies "$RELEASE_NAME"))

    # 等待依赖项就绪
    if wait_for_dependencies "${dependencies[@]}"; then
        log_success "=========================================="
        log_success "All dependencies are ready!"
        log_success "Release '$RELEASE_NAME' can proceed"
        log_success "=========================================="
        exit 0
    else
        log_error "=========================================="
        log_error "Dependency check failed"
        log_error "Release '$RELEASE_NAME' cannot proceed"
        log_error "=========================================="
        exit 1
    fi
}

# 执行主函数
main
