## 简介
[GooseFS](https://cloud.tencent.com/document/product/436/56412) 是由腾讯云推出的高可靠、高可用、弹性的数据湖加速服务。依靠对象存储（Cloud Object Storage，COS）作为数据湖存储底座的成本优势，为数据湖生态中的计算应用提供统一的数据湖入口，可加速海量数据分析、机器学习、人工智能等业务访问的存储性能；采用了分布式集群架构，具备弹性、高可靠、高可用等特性，为上层计算应用提供统一的命名空间和访问协议，可方便用户在不同的存储系统管理和流转数据。GooseFS 提供的功能可概括如下：
- **缓存加速和数据本地化（Locality）：** GooseFS 可以与计算节点混合部署提高数据本地性，利用高速缓存功能解决存储性能问题，提高写入对象存储 COS 的带宽。

- **融合存储语义：** GooseFS 提供 UFS（Unified FileSystem）的语义，可以支持 COS、Hadoop、S3、K8S CSI、 FUSE 等多个存储语义，使用于多种生态和应用场景。

- **统一的腾讯云相关生态服务：** 包括日志、鉴权、监控，实现了与 COS 操作统一。

- **多命名空间管理支持** 用户可以创建和管理不同 namespace 的数据集。

- **感知元数据 Table 功能：** 对于大数据场景下数据 Table，提供 GooseFS Catalog 用于感知元数据 Table ，提供 Table 级别的 Cache 预热。

## 重要概念
GooseFS应用的部署和使用借助了开源组件 [Fluid](https://github.com/fluid-cloudnative/fluid)，相关重要概念如下：
- **Dataset**: 数据集是逻辑上相关的一组数据的集合，会被运算引擎使用，比如大数据的 Spark，AI 场景的 TensorFlow。而这些数据智能的应用会创造工业界的核心价值。Dataset 的管理实际上也有多个维度，比如安全性，版本管理和数据加速。我们希望从数据加速出发，对于数据集的管理提供支持。

- **Runtime**: 实现数据集安全性，版本管理和数据加速等能力的执行引擎，定义了一系列生命周期的接口。可以通过实现这些接口，支持数据集的管理和加速。

GooseFSRuntime: 来源于腾讯云 COS 团队GooseFS，是基于 Java 实现的支撑 Dataset 数据管理和缓存的执行引擎实现，支持的底层存储类型包括：COS、CHDFS、Ceph、HDFS、NFS等。GooseFS 是腾讯云的产品，有专门的产品级支持，但是代码不开源。Fluid通过管理和调度GooseFS Runtime实现数据集的可见性，弹性伸缩， 数据迁移。


## 部署
*当前版本的 GooseFS 依赖 Kubernetes 集群（version >= 1.14）, 并且支持 CSI 功能。*
在 Helm 部署过程中，所有配置项都集中于 `values.yaml`，相关自定义的字段展示如下：

| 参数     | 描述     | 默认值     |
| ------- | -------- | --------- |
| `workdir` | 缓存引擎备份元数据地址 | `/tmp`
| `dataset.controller.image.repository` | Dataset Controller 镜像所在仓库  | `ccr.ccs.tencentyun.com/fluid/dataset-controller` |
| `dataset.controller.image.tag`        | Dataset Controller 镜像的版本    | `"v0.6.0-0bfc552"` |
| `csi.registrar.image.repository`   | CSI registrar 镜像所在仓库 | `"ccr.ccs.tencentyun.com/fluid/csi-node-driver-registrar"` |
| `csi.registrar.image.tag`   | CSI registrar 镜像的版本 | `"v1.2.0"` |
| `csi.plugins.image.repository`   | CSI plugins 镜像所在仓库 | `"ccr.ccs.tencentyun.com/fluid/fluid-csi"` |
| `csi.plugins.image.tag`   | CSI plugins 镜像的版本 | `"v0.6.0-def5316"` |
| `csi.kubelet.rootDir`   | kubelet root 文件夹 | `"/var/lib/kubelet"` |
| `runtime.mountRoot`   | 缓存引擎 fuse mount 点的 Root 地址 | `"/var/lib/kubelet"` |
| `runtime.goosefs.enable`   | 开启 GooseFS 缓存引擎支持 | `"true"` |
| `runtime.goosefs.init.image.repository`   | GooseFS 缓存引擎初始化镜像所在仓库 | `"ccr.ccs.tencentyun.com/fluid/init-users"` |
| `runtime.goosefs.init.image.tag`   | GooseFS 缓存引擎初始化镜像的版本 | `"v0.6.0-0cd802e"` |
| `runtime.goosefs.controller.image.repository`   | GooseFS 缓存引擎控制器镜像所在仓库 | `"ccr.ccs.tencentyun.com/fluid/goosefsruntime-controller"` |
| `runtime.goosefs.controller.image.tag`   | GooseFS 缓存引擎控制器镜像的版本 | `"v0.6.0-bbf4ea0"` |
| `runtime.goosefs.runtime.image.repository`   | GooseFS 缓存引擎镜像所在仓库 | `"ccr.ccs.tencentyun.com/fluid/goosefs"` |
| `runtime.goosefs.runtime.image.tag`   | GooseFS 缓存引擎镜像的版本 | `"v1.1.10"` |
| `runtime.goosefs.fuse.image.repository`   | GooseFS 缓存引擎 Fuse 组件镜像所在仓库 | `"ccr.ccs.tencentyun.com/fluid/goosefs-fuse"` |
| `runtime.goosefs.fuse.image.tag`   | GooseFS 缓存引擎 Fuse 组件镜像的版本 | `"v1.1.10"` |


## 最佳实践
- GooseFS on TKE [使用文档](https://cloud.tencent.com/document/product/436/59358)

