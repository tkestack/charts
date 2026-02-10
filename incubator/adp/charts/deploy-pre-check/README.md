# Pre-Install Check 子 Chart

## 概述

这是一个独立的 Helm 子 Chart，用于在主应用安装前执行依赖检查和资源验证。

## 功能特性

- ✅ **MySQL 数据库检查** - 验证连接性和版本
- ✅ **Elasticsearch 检查** - 验证连接性和集群状态
- ✅ **Redis 检查** - 验证连接性和版本
- ✅ **对象存储检查** - 支持 MinIO 和腾讯云 COS
- ✅ **Kubernetes 资源检查** - 验证集群是否有足够的 CPU 和内存资源
- ✅ **模块化设计** - 可独立配置和禁用各项检查
- ✅ **自动清理** - 检查成功后自动删除资源

## 目录结构

```
pre-install-check/
├── Chart.yaml              # Chart 元数据
├── values.yaml             # 默认配置
├── README.md               # 本文件
└── templates/
    ├── _helpers.tpl        # 辅助函数模板
    ├── configmap.yaml      # 检查脚本 ConfigMap
    ├── rbac.yaml           # RBAC 资源
    └── job.yaml            # Pre-install Hook Job
```

## 配置说明

### 基本配置

```yaml
# 是否启用 pre-install 检查
enabled: true

# 资源要求配置
requirements:
  cpu: 4000      # 4 cores (millicores)
  memory: 8388608  # 8Gi (Ki)
```

### 依赖服务配置

```yaml
dependencies:
  # MySQL 配置
  mysql:
    enabled: true
    host: "mysql.example.com"
    port: 3306
    user: "root"
    password: "password"
  
  # Elasticsearch 配置
  elasticsearch:
    enabled: true
    host: "es.example.com"
    port: 9200
    user: "elastic"
    password: "password"
  
  # Redis 配置
  redis:
    enabled: true
    host: "redis.example.com"
    port: 6379
    password: "password"
  
  # 对象存储配置
  objectStorage:
    enabled: true
    provider: "minio"  # minio 或 cos
    
    minio:
      host: "minio.example.com"
      port: 9000
    
    cos:
      secretId: "your-secret-id"
      secretKey: "your-secret-key"
      region: "ap-guangzhou"
      bucket: "your-bucket"
```

### Job 配置

```yaml
job:
  # 镜像配置
  image:
    repository: python
    tag: "3.11-alpine"
    pullPolicy: IfNotPresent
  
  # 资源限制
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 100m
      memory: 128Mi
  
  # 超时时间（秒）
  activeDeadlineSeconds: 300
  
  # 重试次数
  backoffLimit: 3
```

### RBAC 配置

```yaml
rbac:
  # 是否创建 RBAC 资源
  create: true
  
  # ServiceAccount 名称
  serviceAccountName: pre-install-check
```

### Hook 配置

```yaml
hook:
  # Hook 权重
  weight: "0"
  
  # 删除策略
  deletePolicy: "before-hook-creation,hook-succeeded"
```

## 在父 Chart 中使用

### 1. 在父 Chart 的 values.yaml 中配置

```yaml
# 子 Chart 配置
pre-install-check:
  enabled: true
  
  requirements:
    cpu: 4000
    memory: 8388608
  
  dependencies:
    mysql:
      enabled: true
      host: "{{ .Values.tad.global.db.host }}"
      port: "{{ .Values.tad.global.db.port }}"
      user: "{{ .Values.tad.global.db.user }}"
      password: "{{ .Values.tad.global.db.password }}"
    
    elasticsearch:
      enabled: true
      host: "{{ index .Values.tad.global.es.hosts 0 }}"
      port: "{{ .Values.tad.global.es.port }}"
      user: "{{ .Values.tad.global.es.user }}"
      password: "{{ .Values.tad.global.es.password }}"
    
    redis:
      enabled: true
      host: "{{ index .Values.tad.global.redis.hosts 0 }}"
      port: "{{ .Values.tad.global.redis.port }}"
      password: "{{ .Values.tad.global.redis.password }}"
    
    objectStorage:
      enabled: true
      provider: "{{ .Values.tad.global.objectstorage.provider }}"
      minio:
        host: "{{ .Values.tad.global.objectstorage.minio.host }}"
        port: "{{ .Values.tad.global.objectstorage.minio.port }}"
```

### 2. 安装父 Chart

```bash
helm install my-release ./parent-chart -n namespace
```

子 Chart 会自动作为 pre-install hook 执行。

## 禁用检查

### 禁用整个 pre-install 检查

```yaml
pre-install-check:
  enabled: false
```

### 禁用特定检查项

```yaml
pre-install-check:
  dependencies:
    mysql:
      enabled: false  # 禁用 MySQL 检查
    elasticsearch:
      enabled: true
    redis:
      enabled: true
    objectStorage:
      enabled: false  # 禁用对象存储检查
```

## 查看检查日志

```bash
# 查看 Job
kubectl get jobs -n namespace | grep pre-install-check

# 查看 Pod
kubectl get pods -n namespace | grep pre-install-check

# 查看日志
kubectl logs -n namespace <pod-name>
```

## 故障排查

### 检查失败

如果检查失败，Job 和 Pod 会保留以便查看日志：

```bash
# 查看 Job 状态
kubectl describe job <job-name> -n namespace

# 查看 Pod 日志
kubectl logs <pod-name> -n namespace

# 查看事件
kubectl get events -n namespace --sort-by='.lastTimestamp'
```

### 手动清理

如果需要手动清理失败的资源：

```bash
# 删除 Job
kubectl delete job <job-name> -n namespace

# 删除 ConfigMap
kubectl delete configmap <configmap-name> -n namespace

# 删除 RBAC 资源
kubectl delete clusterrole <clusterrole-name>
kubectl delete clusterrolebinding <clusterrolebinding-name>
kubectl delete serviceaccount <serviceaccount-name> -n namespace
```

## 自定义检查脚本

如需自定义检查逻辑，编辑 `templates/configmap.yaml` 中的 `check.sh` 脚本。

## 最佳实践

1. ✅ **在生产环境使用** - 确保依赖服务可用后再安装
2. ✅ **根据实际需求调整资源要求** - 修改 `requirements` 配置
3. ✅ **禁用不需要的检查** - 提高检查速度
4. ✅ **保留失败日志** - 便于问题排查
5. ✅ **定期更新检查脚本** - 适应新的需求

## 版本历史

- **v1.0.0** - 初始版本
  - 支持 MySQL、ES、Redis、对象存储检查
  - 支持 Kubernetes 资源检查
  - 模块化设计

## 许可证

本 Chart 遵循与父 Chart 相同的许可证。
