#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pre-install 检查脚本
检查 MySQL、Elasticsearch、Redis、对象存储和 Kubernetes 集群资源
"""

import os
import sys
import json
import subprocess
from typing import Dict, Any, Tuple

# 颜色定义
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'

# 全局检查失败标记
check_failed = False

def print_header(text: str):
    """打印标题"""
    print("\n" + "=" * 50)
    print(text)
    print("=" * 50)

def print_success(text: str):
    """打印成功信息"""
    print(f"{Colors.GREEN}✓ {text}{Colors.NC}")

def print_error(text: str):
    """打印错误信息"""
    global check_failed
    print(f"{Colors.RED}✗ {text}{Colors.NC}")
    check_failed = True

def print_warning(text: str):
    """打印警告信息"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.NC}")

def print_info(text: str):
    """打印信息"""
    print(f"{Colors.BLUE}ℹ {text}{Colors.NC}")

def check_mysql() -> bool:
    """检查 MySQL 连接"""
    print_header("检查 MySQL 连接")
    host = os.getenv('DB_HOST', '')
    if not host:
        print_warning("未配置 MySQL，跳过检查")
        return True

    port = int(os.getenv('DB_PORT', '3306'))
    user = os.getenv('DB_USER', '')
    password = os.getenv('DB_PASSWORD', '')

    print_info(f"MySQL 地址: {host}:{port}")
    print_info(f"MySQL 用户: {user}")

    try:
        import pymysql

        # 测试连接
        connection = pymysql.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            connect_timeout=10
        )

        print_success("MySQL 连接成功")

        # 获取版本信息
        with connection.cursor() as cursor:
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()[0]
            print_info(f"MySQL 版本: {version}")

        connection.close()
        return True

    except Exception as e:
        print_error(f"MySQL 连接失败: {e}")
        return False

def check_elasticsearch() -> bool:
    """检查 Elasticsearch 连接"""
    print_header("检查 Elasticsearch 连接")

    host = os.getenv('ES_HOST', '')
    if not host:
        print_warning("未配置 Elasticsearch！")
        return False

    port = int(os.getenv('ES_PORT', '9200'))
    user = os.getenv('ES_USER', '')
    password = os.getenv('ES_PASSWORD', '')

    print_info(f"Elasticsearch 地址: {host}:{port}")
    print_info(f"Elasticsearch 用户: {user}")
    print_info(f"使用认证: {'是' if user and password else '否'}")

    try:
        import requests
        
        # 使用 HTTP 请求检查 Elasticsearch 可用性
        auth = (user, password) if user and password else None
        response = requests.get(f"http://{host}:{port}", timeout=5, auth=auth)
        
        print_info(f"HTTP 响应状态码: {response.status_code}")
        print_info(f"HTTP 响应内容: {response.text[:200]}")
        
        if response.status_code == 200:
            print_success("Elasticsearch 连接成功")
            return True
        else:
            print_error(f"Elasticsearch 返回非 200 状态码: {response.status_code}")
            return False
            
    except Exception as e:
        print_error(f"Elasticsearch 连接失败: {type(e).__name__}: {e}")
        print_error(f"连接地址: http://{host}:{port}")
        return False

def check_redis() -> bool:
    """检查 Redis 连接"""
    print_header("检查 Redis 连接")

    host = os.getenv('REDIS_HOST', '')
    if not host:
        print_warning("未配置 Redis，跳过检查")
        return True

    port = int(os.getenv('REDIS_PORT', '6379'))
    password = os.getenv('REDIS_PASSWORD', '')

    print_info(f"Redis 地址: {host}:{port}")

    try:
        import redis

        # 创建连接
        r = redis.Redis(
            host=host,
            port=port,
            password=password if password else None,
            socket_connect_timeout=10,
            decode_responses=True
        )

        # 测试连接
        if r.ping():
            print_success("Redis 连接成功")

            # 获取 Redis 信息
            info = r.info('server')
            print_info(f"Redis 版本: {info.get('redis_version', '未知')}")

            return True
        else:
            print_error("Redis 连接失败")
            return False

    except Exception as e:
        print_error(f"Redis 连接失败: {e}")
        return False

def check_vectordb() -> bool:
    """检查腾讯云 VectorDB 连接"""
    print_header("检查腾讯云 VectorDB 连接")

    vdb_addr = os.getenv('VDB_ADDR', '')
    if not vdb_addr:
        print_warning("未配置 VectorDB!")
        return False

    vdb_account = os.getenv('VDB_ACCOUNT', '')
    vdb_apikey = os.getenv('VDB_APIKEY', '')

    print_info(f"VectorDB 地址: {vdb_addr}")
    print_info(f"VectorDB 账号: {vdb_account}")

    if not vdb_account:
        print_error("VectorDB 配置无效（account 未设置）")
        return False

    if not vdb_apikey:
        print_error("VectorDB 配置无效（apikey 未设置）")
        return False

    try:
        import requests
        from requests.adapters import HTTPAdapter
        from requests.packages.urllib3.util.retry import Retry

        # 构建 API 请求 URL
        # 腾讯云 VectorDB 通常使用 /database/list 接口来验证连接
        api_url = f"{vdb_addr.rstrip('/')}/database/list"
        print_info(f"测试连接: {api_url}")

        # 设置请求头
        headers = {
            'Authorization': f'Bearer account={vdb_account}&api_key={vdb_apikey}',
            'Content-Type': 'application/json',
            'Connection': 'close'  # 避免连接复用问题
        }

        # 创建会话并配置重试策略
        session = requests.Session()
        retry_strategy = Retry(
            total=3,  # 最多重试3次
            backoff_factor=1,  # 重试间隔
            status_forcelist=[500, 502, 503, 504],  # 这些状态码会触发重试
            allowed_methods=["GET", "POST"]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)

        # 发送请求
        response = session.get(
            api_url,
            headers=headers,
            timeout=(5, 15),  # (连接超时, 读取超时)
            verify=True  # 验证 SSL 证书
        )

        if response.status_code == 200:
            print_success("VectorDB 连接成功")
            
            # 尝试解析响应
            try:
                data = response.json()
                if 'databases' in data:
                    db_count = len(data['databases'])
                    print_info(f"数据库数量: {db_count}")
            except Exception as e:
                print_info("响应解析成功但无法获取详细信息")
            return True
        elif response.status_code == 401:
            print_error("VectorDB 认证失败（HTTP 401），请检查 account 和 apikey 是否正确")
            return False
        elif response.status_code == 403:
            print_error("VectorDB 权限不足（HTTP 403），请检查账号权限")
            return False
        elif response.status_code == 404:
            print_error("VectorDB API 端点不存在（HTTP 404），请检查地址是否正确")
            return False
        else:
            print_error(f"VectorDB 连接失败（HTTP {response.status_code}）")
            print_info(f"响应内容: {response.text[:200]}")
            return False

    except requests.exceptions.ConnectionError as e:
        error_msg = str(e)
        if 'Connection aborted' in error_msg or 'RemoteDisconnected' in error_msg:
            print_error(f"VectorDB 连接被远程服务器中断")
            print_info("可能原因: 1) 服务器主动关闭连接 2) 网络不稳定 3) 防火墙拦截")
        else:
            print_error(f"VectorDB 连接失败: 无法连接到服务器 {vdb_addr}")
        print_info(f"错误详情: {error_msg[:200]}")
        return False
    except requests.exceptions.Timeout:
        print_error(f"VectorDB 连接超时: 服务器响应时间过长")
        return False
    except requests.exceptions.SSLError as e:
        print_error(f"VectorDB SSL 证书验证失败")
        print_info(f"错误详情: {str(e)[:200]}")
        return False
    except Exception as e:
        print_error(f"VectorDB 连接失败: {e}")
        import traceback
        traceback.print_exc()
        return False

def check_object_storage() -> bool:
    """检查对象存储连接"""
    print_header("检查对象存储连接")
    
    cos_secret_id = os.getenv('COS_SECRET_ID', '')
    cos_secret_key = os.getenv('COS_SECRET_KEY', '')
    cos_region = os.getenv('COS_REGION', '')
    cos_bucket = os.getenv('COS_BUCKET', '')
    cos_subpath = os.getenv('COS_SUBPATH', '')
    
    print_info("对象存储类型: 腾讯云 COS")
    print_info(f"COS 区域: {cos_region}")
    print_info(f"COS 存储桶: {cos_bucket}")
    print_info(f"COS 子路径: {cos_subpath}")

    if not cos_secret_id or cos_secret_id == 'xxx':
        print_error("COS 配置无效（secret_id 未设置）")
        return False

    if not cos_bucket:
        print_error("COS 配置无效（bucket 未设置）")
        return False

    if not cos_region:
        print_error("COS 配置无效（region 未设置）")
        return False

    if not cos_subpath:
        print_error("COS 配置无效（subpath 未设置，这是必填项）")
        return False

    # 验证COS配置
    try:
        import requests

        # 1. 验证桶是否存在且可访问
        bucket_url = f"https://{cos_bucket}.cos.{cos_region}.myqcloud.com/"
        print_info(f"检查COS桶是否存在: {bucket_url}")

        try:
            response = requests.head(bucket_url, timeout=10, allow_redirects=True)

            if response.status_code in [200, 403]:
                # 200: 桶存在且可访问
                # 403: 桶存在但无权限（这是正常的，说明桶存在）
                print_success(f"COS 桶 '{cos_bucket}' 存在且可正常访问")
            elif response.status_code == 404:
                print_error(f"COS 桶 '{cos_bucket}' 不存在（HTTP 404）")
                return False
            else:
                print_warning(f"COS 桶访问返回状态码: {response.status_code}")

        except requests.exceptions.RequestException as e:
            print_error(f"COS 桶连接失败: {e}")
            return False

        # 2. 验证subpath是否为公有读
        subpath_clean = cos_subpath.strip('/')
        subpath_url = f"https://{cos_bucket}.cos.{cos_region}.myqcloud.com/{subpath_clean}/"

        print_info(f"检查子路径公有读权限: {subpath_url}")

        try:
            # 使用GET请求测试公有读权限
            response = requests.get(subpath_url, timeout=10, allow_redirects=True)

            if response.status_code == 200:
                print_success(f"COS 子路径 '{cos_subpath}' 配置为公有读，验证通过")
                return True
            elif response.status_code == 404:
                # 404可能是路径不存在，但如果是公有读的话应该能看到404页面
                # 再次用HEAD请求确认
                head_response = requests.head(subpath_url, timeout=10, allow_redirects=True)
                if head_response.status_code == 404:
                    print_success(f"COS 子路径 '{cos_subpath}' 配置为公有读（路径暂时为空）")
                    return True
                elif head_response.status_code == 403:
                    print_error(f"COS 子路径 '{cos_subpath}' 不是公有读（HTTP 403 Forbidden）")
                    print_error("请在腾讯云控制台将该子路径设置为公有读权限")
                    return False
                else:
                    print_warning(f"COS 子路径访问返回状态码: {head_response.status_code}")
                    return False
            elif response.status_code == 403:
                print_error(f"COS 子路径 '{cos_subpath}' 不是公有读（HTTP 403 Forbidden）")
                print_error("请在腾讯云控制台将该子路径设置为公有读权限")
                return False
            else:
                print_error(f"COS 子路径访问返回异常状态码: {response.status_code}")
                return False

        except requests.exceptions.RequestException as e:
            print_error(f"COS 子路径连接失败: {e}")
            return False

    except Exception as e:
        print_error(f"COS 验证失败: {e}")
        return False

def check_k8s_resources() -> bool:
    """检查 Kubernetes 集群资源"""
    print_header("检查 Kubernetes 集群资源")

    required_cpu_millicores = int(float(os.getenv('REQUIRED_CPU', '0')))
    required_memory_ki = int(float(os.getenv('REQUIRED_MEMORY', '0')))

    print_info(f"所需资源: {required_cpu_millicores // 1000} Core CPU, {required_memory_ki // 1048576} Gi Memory")
    print()

    try:
        from kubernetes import client, config

        # 加载 Kubernetes 配置
        config.load_incluster_config()

        v1 = client.CoreV1Api()

        # 获取所有节点
        nodes = v1.list_node()

        print_info("集群节点列表:")
        for node in nodes.items:
            node_name = node.metadata.name
            node_status = "Ready" if any(
                condition.type == "Ready" and condition.status == "True"
                for condition in node.status.conditions
            ) else "NotReady"
            print(f"  - {node_name}: {node_status}")

        print()

        # 计算总的可分配资源
        total_allocatable_cpu = 0
        total_allocatable_memory = 0

        for node in nodes.items:
            allocatable = node.status.allocatable

            # CPU (转换为 millicores)
            cpu_str = allocatable.get('cpu', '0')
            if cpu_str.endswith('m'):
                cpu_value = int(cpu_str[:-1])
            else:
                try:
                    cpu_value = int(float(cpu_str) * 1000)
                except (ValueError, TypeError):
                    cpu_value = 0
            total_allocatable_cpu += cpu_value

            # Memory (转换为 Ki)
            mem_str = allocatable.get('memory', '0')
            if mem_str.endswith('Ki'):
                mem_value = int(mem_str[:-2])
            elif mem_str.endswith('Mi'):
                mem_value = int(mem_str[:-2]) * 1024
            elif mem_str.endswith('Gi'):
                mem_value = int(mem_str[:-2]) * 1048576
            elif mem_str.endswith('M'):
                # 处理 M 后缀（等同于 Mi）
                mem_value = int(mem_str[:-1]) * 1024
            elif mem_str.endswith('G'):
                # 处理 G 后缀（等同于 Gi）
                mem_value = int(mem_str[:-1]) * 1048576
            elif mem_str.endswith('K'):
                # 处理 K 后缀（等同于 Ki）
                mem_value = int(mem_str[:-1])
            else:
                # 假设是字节，转换为 Ki
                mem_value = int(mem_str) // 1024 if mem_str.isdigit() else 0
            total_allocatable_memory += mem_value

        # 获取所有 Pod 的资源请求
        pods = v1.list_pod_for_all_namespaces()

        total_requested_cpu = 0
        total_requested_memory = 0

        for pod in pods.items:
            if pod.status.phase not in ['Running', 'Pending']:
                continue

            for container in pod.spec.containers:
                if container.resources and container.resources.requests:
                    requests = container.resources.requests

                    # CPU
                    cpu_str = requests.get('cpu', '0')
                    if cpu_str:
                        if cpu_str.endswith('m'):
                            cpu_value = int(cpu_str[:-1])
                        else:
                            cpu_value = int(float(cpu_str) * 1000)
                        total_requested_cpu += cpu_value

                    # Memory
                    mem_str = requests.get('memory', '0')
                    if mem_str:
                        if mem_str.endswith('Ki'):
                            mem_value = int(mem_str[:-2])
                        elif mem_str.endswith('Mi'):
                            mem_value = int(mem_str[:-2]) * 1024
                        elif mem_str.endswith('Gi'):
                            mem_value = int(mem_str[:-2]) * 1048576
                        elif mem_str.endswith('M'):
                            # 处理 M 后缀（等同于 Mi）
                            mem_value = int(mem_str[:-1]) * 1024
                        elif mem_str.endswith('G'):
                            # 处理 G 后缀（等同于 Gi）
                            mem_value = int(mem_str[:-1]) * 1048576
                        elif mem_str.endswith('K'):
                            # 处理 K 后缀（等同于 Ki）
                            mem_value = int(mem_str[:-1])
                        else:
                            mem_value = int(mem_str) // 1024
                        total_requested_memory += mem_value

        # 计算可用资源
        available_cpu = total_allocatable_cpu - total_requested_cpu
        available_memory = total_allocatable_memory - total_requested_memory

        print_info("CPU 资源统计:")
        print(f"  可分配: {total_allocatable_cpu // 1000} cores ({total_allocatable_cpu} millicores)")
        print(f"  已请求: {total_requested_cpu // 1000} cores ({total_requested_cpu} millicores)")
        print(f"  剩余可用: {available_cpu // 1000} cores ({available_cpu} millicores)")

        print()
        print_info("内存资源统计:")
        print(f"  可分配: {total_allocatable_memory // 1048576} Gi ({total_allocatable_memory} Ki)")
        print(f"  已请求: {total_requested_memory // 1048576} Gi ({total_requested_memory} Ki)")
        print(f"  剩余可用: {available_memory // 1048576} Gi ({available_memory} Ki)")

        print()

        # 检查 CPU 资源
        cpu_ok = available_cpu >= required_cpu_millicores
        if cpu_ok:
            print_success(f"CPU 资源充足 (需要: {required_cpu_millicores // 1000} cores, 可用: {available_cpu // 1000} cores)")
        else:
            print_error(f"CPU 资源不足 (需要: {required_cpu_millicores // 1000} cores, 可用: {available_cpu // 1000} cores)")

        # 检查内存资源
        memory_ok = available_memory >= required_memory_ki
        if memory_ok:
            print_success(f"内存资源充足 (需要: {required_memory_ki // 1048576} Gi, 可用: {available_memory // 1048576} Gi)")
        else:
            print_error(f"内存资源不足 (需要: {required_memory_ki // 1048576} Gi, 可用: {available_memory // 1048576} Gi)")

        return cpu_ok and memory_ok

    except Exception as e:
        print_error(f"检查 Kubernetes 资源失败: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """主函数"""
    global check_failed

    print_header("开始执行 Pre-Install 检查")

    # 执行各项检查
    check_mysql()
    check_elasticsearch()
    check_redis()
    check_vectordb()
    check_object_storage()
    check_k8s_resources()

    # 最终结果
    print_header("检查结果汇总")

    if not check_failed:
        print_success("所有检查通过，可以继续安装")
        print()
        sys.exit(0)
    else:
        print_error("部分检查失败，退出安装。")
        sys.exit(1)

if __name__ == '__main__':
    main()