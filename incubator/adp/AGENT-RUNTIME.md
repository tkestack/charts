# 专有云 - Agent Runtime 配置指南

> 本文档独立维护 ADP 专有云中 **Agent Runtime（沙箱）** 的配置流程。
>
> [ADP 主 README](./README.md) 中仅保留概要介绍与 `values.yaml` 配置项说明，详细的沙箱创建、CFS/COS 前置初始化、控制台操作截图等内容集中在本文档。

- **腾讯云控制台入口**：<https://console.cloud.tencent.com/ags/sandbox/sandbox>

---

## 目录

- [1. 前置依赖](#1-前置依赖)
- [2. CFS 配置说明](#2-cfs-配置说明)
- [3. COS 配置说明](#3-cos-配置说明)
- [4. Agent Runtime 沙箱配置](#4-agent-runtime-沙箱配置)
  - [4.1 公共沙箱的配置 & 创建](#41-公共沙箱的配置--创建)
  - [4.2 智能工作台沙箱](#42-智能工作台沙箱)
  - [4.3 Claw 模式沙箱](#43-claw-模式沙箱)
- [5. values.yaml 配置](#5-valuesyaml-配置)

---

## 1. 前置依赖

Agent Runtime 作为 ADP **智能工作台** 和 **Claw 模式** 的运行环境，需要提前完成如下依赖的准备：

| 依赖 | 用途 | 控制台链接 |
|------|------|-----------|
| **CFS 文件系统** | 沙箱之间共享用户工作目录 `/users` | <https://console.cloud.tencent.com/cfs/fs> |
| **COS 对象存储** | 存放系统与用户的 Skills 资源（复用 ADP 主 COS 桶即可） | <https://cloud.tencent.com/product/cos> |
| **agent-sandbox 镜像** | 沙箱运行镜像 | 由 ADP 官方提供：`adp-iaas.tencentcloudcr.com/adp-public/agent-sandbox` |

---

## 2. CFS 配置说明

需要先在 CFS 中初始化一个目录给沙箱使用。请在**同 VPC 的腾讯云 CVM Linux 机器**上执行以下命令：

```bash
# 下面的命令在腾讯云购买的 CVM Linux 机器上执行
# 挂载 NFS
mount -t nfs -o vers=4.0,noresvport <cfs ip>:/ /mnt
# 创建 /users 目录
mkdir -p /mnt/users
# 取消挂载
umount /mnt
```

> **注意**：CFS 挂载目录信息可在 CFS 控制台 → 文件系统详情 → 挂载点信息 查看。

---

![沙箱控制台入口 - 主入口](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/console-entry-primary.png)

![沙箱控制台入口 - 交互页](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/console-entry-secondary.png)

## 3. COS 配置说明

COS 对象存储需要完成 `/skills/system` 和 `/skills/users` 两个目录的初始化：

1. 选择 ADP 环境使用的 COS 存储桶，进入文件列表：

   ![COS 存储桶文件列表](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-bucket-file-list.png)

2. 在存储桶根目录下创建 `/skills/system` 和 `/skills/users` 目录（如已存在可跳过）：

   ![创建 skills 目录](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-skills-dirs-created.png)

---

## 4. Agent Runtime 沙箱配置

Agent Runtime 需要创建 **3 个** 沙箱工具，规格与用途如下：

| 沙箱工具 | 资源建议 | 说明 |
|----------|----------|------|
| 公共沙箱 | 2C 4G | 用于初始化智能工作台使用的工作目录 |
| 智能工作台 | 4C 8G | 智能工作台功能下沙箱运行的环境 |
| Claw 模式 | 2C 4G | Claw 模式下沙箱运行的环境 |

**创建 Agent 沙箱入口**：<https://console.cloud.tencent.com/ags/sandbox/sandbox>

![新建沙箱工具入口](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/new-sandbox-entry.png)

---

### 4.1 公共沙箱的配置 & 创建

进入「Agent Runtime → 沙箱工具」页面，点击 **新建沙箱工具**，选择"创建自定义沙箱"。

#### 基本信息

| 名称 | 说明 | 示例 |
|------|------|------|
| 工具名称 | 可自定义，建议：`adp-<name>-public-sandbox` | `adp-stress-public-sandbox` |
| 生命周期 | **必须选择「常驻沙箱」** | 常驻沙箱 |
| 描述 | 备注说明 | `adp-<name> 的公共沙箱` |

如图：

![公共沙箱-基本信息](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-basic-info.png)

#### 资源与健康

| 名称 | 说明 | 示例 |
|------|------|------|
| 资源规格 | CPU / 内存 / 系统盘大小 | `2C 4Gi 4Gi`（系统盘可用默认值） |
| 健康检查 | 沙箱运行环境启动后的健康检查 | 检查路径 `/health`，检查端口 `63232` |

如图：

![公共沙箱-资源与健康](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-resource-health.png)

#### 存储配置

公共沙箱需要挂载 **CFS**，配置如下：

- 名称：`users`
- 文件系统：`<选相应的 CFS 文件存储>`
- CFS 路径：`/users`
- 挂载路径：`/users`
- 读写权限：读写

![公共沙箱-存储配置项](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-storage-cfs-form.png)

如图：

![公共沙箱-存储配置总览](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-storage-cfs-overview.png)

#### 镜像与启动

| 名称 | 说明 | 示例 |
|------|------|------|
| 镜像 | 沙箱运行的镜像 | `adp-iaas.tencentcloudcr.com/adp-public/agent-sandbox` |
| 镜像版本 (Tag) | ADP 官方提供的对应版本 | `stable_iaas_4.0.3.0_4df788c_private` |
| 启动命令 | 固定值 | `/usr/local/bin/start-services` |
| 启动参数 | 无 | 不需要填写 |

![公共沙箱-镜像选择](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-image-select.png)

**环境变量**：环境变量会自动根据 agent-sandbox 镜像填充，需要修改/新增以下三个：

```
CODETOOL_PORT=63232
ADP_PLUGIN_GW_SCHEME=https              # 与 global.scheme 保持一致
ADP_PLUGIN_GW_HOST=<ADP 平台 CLB 域名>   # 与 global.clb 保持一致
```

![公共沙箱-环境变量](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-env-vars.png)

如图：

![公共沙箱-镜像与启动总览](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-image-startup-overview.png)

#### 网络与权限

| 名称 | 说明 |
|------|------|
| 网络策略 | 选择 **VPC 网络** |
| VPC 网络 | 选择相应的私有网络，无则新建 |
| 子网选择 | 建议新建一个独立的子网给沙箱使用 |
| 安全组 | 选择子网相应的安全组策略 |
| CAM 角色 | 沙箱工具访问 COS、镜像仓库等云资源的权限 |

**端口配置**：

```
名称: 63232, 端口: 63232, 协议: TCP
名称: 49983, 端口: 49983, 协议: TCP
```

![公共沙箱-端口配置](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-ports-config.png)

如图：

![公共沙箱-网络与权限总览](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-network-permission-overview.png)

#### 高级配置

| 名称 | 说明 |
|------|------|
| 开启日志采集 | 按需开启 |
| 日志集 / 日志主题 | 按需选择 |
| 采集路径 | 删除默认路径，仅采集控制台日志 |
| 腾讯云标签 | `tke-clusterId：<集群名称>` |

如图：

![公共沙箱-高级配置](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-advanced-log-collect.png)

#### 配置完成 & 创建实例

配置完毕后，先点击「**一键预检**」，通过后再点击「**确定**」。

创建成功后，进入 **沙箱工具详情 → 实例列表**，创建公共沙箱实例：

![公共沙箱-实例列表创建](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-instance-list-create.png)

**实例配置信息**：

| 名称 | 说明 |
|------|------|
| 基本信息-AuthMode | 选择 **Token 认证** |
| 高级配置-存储配置 | 存储配置 `users`；挂载路径 `/users`；子路径为空；读写权限：读写 |

如图：

![公共沙箱-实例配置-基本信息](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-instance-config-basic.png)

![公共沙箱-实例配置-存储挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-instance-config-storage.png)

#### 启动完成后校验

登录实例，检查 `/users` 目录是否存在：

![公共沙箱-登录实例](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-instance-login.png)
![公共沙箱-/users 目录检查](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-instance-users-dir-check.png)

**记录以下三个信息**，后续填入 [`values.yaml`](#5-valuesyaml-配置)：

- **沙箱工具 ID** → `agentRuntime.instances.commonAgs.toolID`

  ![公共沙箱-工具ID](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-record-tool-id.png)

- **实例 ID** → `agentRuntime.instances.commonAgs.instanceID`

  ![公共沙箱-实例ID](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-record-instance-id.png)

- **实例 Token** → `agentRuntime.instances.commonAgs.token`

  ![公共沙箱-Token](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/public-record-token.png)

---

### 4.2 智能工作台沙箱

智能工作台沙箱的配置流程与公共沙箱基本一致，**推荐直接"克隆"公共沙箱工具**再修改差异部分。

![智能工作台-克隆入口](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/clone-sandbox-entry.png)

克隆之后需要调整以下参数：

| 名称 | 说明 |
|------|------|
| 基本信息-工具名称 | 建议：`adp-<name>-assistant-sandbox` |
| 资源与健康-资源规格 | `4C 8Gi 10Gi` |
| 资源与健康-存储配置 | 见下方 |

**存储配置**（4 项）：

- **对象存储 COS 的系统 skills 配置**
  - 名称：`adp-system-skills`
  - 存储桶：`<选相应的 COS 存储桶>`
  - 存储路径：`/skills/system`
  - 挂载路径：`/.system`
  - 读写权限：只读

  ![智能工作台-系统 skills 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-system-skills-mount.png)

- **对象存储 COS 的用户 skills 配置**
  - 名称：`adp-custom-skills`
  - 存储桶：`<选相应的 COS 存储桶>`
  - 存储路径：`/skills/users`
  - 挂载路径：`/.custom`
  - 读写权限：只读

  ![智能工作台-用户 skills 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-user-skills-mount.png)

- **对象存储 COS 的用户共享 skills 配置**
  - 名称：`adp-custom-share-skills`
  - 存储桶：`<选相应的 COS 存储桶>`
  - 存储路径：`/skills/users`
  - 挂载路径：`/.custom_share`
  - 读写权限：只读

  ![智能工作台-共享 skills 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-share-skills-mount.png)

- **文件存储 CFS 的配置**
  - 名称：`users`
  - 文件系统：`<选相应的 CFS 文件存储>`
  - CFS 路径：`/users`
  - 挂载路径：`/.users`
  - 读写权限：读写

  ![智能工作台-CFS 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/smartdesk-cfs-mount.png)

配置完成后，记录**沙箱工具 ID**，用于填入 `agentRuntime.instances.smartDeskAgs.toolID`。

---

### 4.3 Claw 模式沙箱

Claw 模式沙箱与智能工作台沙箱的配置基本一致，**推荐直接"克隆"智能工作台沙箱工具**再修改差异部分。

![Claw 模式-克隆入口](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/clone-sandbox-entry.png)

克隆之后需要调整以下参数：

| 名称 | 说明 |
|------|------|
| 基本信息-工具名称 | 建议：`adp-<name>-claw-sandbox` |
| 资源与健康-资源规格 | `2C 4Gi 2Gi` |
| 资源与健康-存储配置 | 见下方（**不挂载 CFS**） |

**存储配置**（3 项，仅 COS）：

- **对象存储 COS 的系统 skills 配置**
  - 名称：`adp-system-skills`
  - 存储桶：`<选相应的 COS 存储桶>`
  - 存储路径：`/skills/system`
  - 挂载路径：`/.system`
  - 读写权限：只读

  ![Claw-系统 skills 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-system-skills-mount.png)

- **对象存储 COS 的用户 skills 配置**
  - 名称：`adp-custom-skills`
  - 存储桶：`<选相应的 COS 存储桶>`
  - 存储路径：`/skills/users`
  - 挂载路径：`/.custom`
  - 读写权限：只读

  ![Claw-用户 skills 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-user-skills-mount.png)

- **对象存储 COS 的用户共享 skills 配置**
  - 名称：`adp-custom-share-skills`
  - 存储桶：`<选相应的 COS 存储桶>`
  - 存储路径：`/skills/users`
  - 挂载路径：`/.custom_share`
  - 读写权限：只读

  ![Claw-共享 skills 挂载](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/cos-share-skills-mount.png)

配置完成后，记录**沙箱工具 ID**，用于填入 `agentRuntime.instances.clawAgs.toolID`。

---

## 5. values.yaml 配置

将上述三次配置得到的 ID / Token / CFS IP 填入 [`global-values.yaml`](./global-values.yaml)：

```yaml
global:
  # ============================
  # Agent Runtime 配置
  # ============================
  agentRuntime:
    # 是否禁用 Agent Runtime（禁用后智能工作台与 Claw 模式不可用）
    disabled: false
    vendor: tencent
    # 申请沙箱时配置的角色 RoleArn
    stsRoleArn: "qcs::cam::uin/100000000000:roleName/xxx"
    # 沙箱实例配置
    instances:
      # Claw 模式沙箱
      clawAgs:
        # 工具 ID（4.3 记录）
        toolID: "<Claw 模式的工具ID>"
      # 智能工作台沙箱
      smartDeskAgs:
        # 工具 ID（4.2 记录）
        toolID: "<智能工作台的工具ID>"
      # 公共沙箱（常驻实例）
      commonAgs:
        # 工具 ID（4.1 记录）
        toolID: "<公共沙箱的工具ID>"
        # 实例 ID（4.1 记录）
        instanceID: "<公共沙箱的实例ID>"
        # 实例 Token（4.1 记录）
        token: "<公共沙箱的Token>"
    # 沙箱挂载的 CFS 配置
    cfs:
      # CFS IP
      ip: "<cfs ip>"
      # CFS 挂载 path
      path: "/users"
```

配置完成后的效果如下：

![values.yaml 配置示例](https://adp-iaas-aio-1406902593.cos.ap-beijing.myqcloud.com/agent-runtime/values-yaml-example.png)

---

## 附录

| 相关文档 | 链接 |
|---------|------|
| ADP 主 README | [./README.md](./README.md) |
| 完整 `global-values.yaml` 示例 | [./global-values.yaml](./global-values.yaml) |
| `values.yaml` 模板 | [./values.yaml](./values.yaml) |
