# tke-dify Helm Chart

`tke-dify` 用于在 TKE 上部署 [DIFY](https://github.com/langgenius/dify) - 一个开源的大模型应用开发平台。

## 组件说明

Chart 包含以下主要组件：

- **Proxy**: tke-dify  应用的访问入口。
- **API**: tke-dify  应用的 API Server 服务， 提供了 RESTful 接口请求处理、数据管理和任务调度。
- **worker**: tke-dify  应用的 worker 服务，启动 Celery 进程处理异步任务。
- **web**: tke-dify  应用的前端组件。
- **sandbox**: tke-dify  应用的 sandbox 服务，基于 dify 开源的安全镜像，提供了安全隔离的代码执行环境。

## 配置说明

以下是主要可配置参数及默认值：

### 依赖项配置

Chart 依赖以下服务：

| **依赖项** | **版本** | **默认启用** | **说明** |
| ---- | ---- | ---- | ---- |
| **redis** | **20.6.3** | **true** | 数据缓存 |
| **postgresql** | **12.9.0** | **true** | 核心数据存储 |
| **weaviate** | **16.1.0** | **true** | 向量数据库，用于存储和检索 Embedding 数据 |

依赖项的完整参数配置请参考：

- redis: [https://github.com/bitnami/charts/tree/main/bitnami/redis/#parameters](https://github.com/bitnami/charts/tree/main/bitnami/redis/#parameters)
- postgresql: [https://github.com/bitnami/charts/tree/main/bitnami/postgresql/#parameters](https://github.com/bitnami/charts/tree/main/bitnami/postgresql/#parameters)
- weaviate: [https://weaviate.io/developers/weaviate/installation/kubernetes#modify-valuesyaml-as-necessary](https://weaviate.io/developers/weaviate/installation/kubernetes#modify-valuesyaml-as-necessary)

### 镜像配置

| Key                             | Description                                        | Default                                             |
|----------------------------------|----------------------------------------------------|-----------------------------------------------------|
| image.api.repository            | Dify API image name. | dify-api             |
| image.api.tag                   | Dify API image tag.          | 1.1.3                                               |
| image.api.pullPolicy            | Dify API image pull policy. | IfNotPresent                                        |
| image.web.repository            | Dify web image name. | dify-web             |
| image.web.tag                   | Dify web image tag.          | 1.1.3                                               |
| image.web.pullPolicy            | Dify web image pull policy. | IfNotPresent                                        |
| image.sandbox.repository        | Dify sandbox image name. | dify-sandbox         |
| image.sandbox.tag               | Dify sandbox image tag.      | 0.2.11                                              |
| image.sandbox.pullPolicy        | Dify sandbox image pull policy. | IfNotPresent                                        |
| image.proxy.repository          | Dify proxy image name. | nginx               |
| image.proxy.tag                 | Dify proxy image tag.        | 1.27.4                                              |
| image.proxy.pullPolicy          | Dify proxy image pull policy. | IfNotPresent                                        |
| image.ssrfProxy.repository      | Dify ssrfProxy image name. | squid               |
| image.ssrfProxy.tag             | Dify ssrfProxy image tag.   | latest                                              |
| image.ssrfProxy.pullPolicy      | Dify ssrfProxy image pull policy. | IfNotPresent                                        |
| image.pluginDaemon.repository   | Dify pluginDaemon image name. | dify-plugin-daemon   |
| image.pluginDaemon.tag          | Dify pluginDaemon image tag. | 0.0.6-local                                         |
| image.pluginDaemon.pullPolicy   | Dify pluginDaemon image pull policy. | IfNotPresent                                        |


### API 配置

| Key                                | Description                                                                 | Default   |
|------------------------------------|-----------------------------------------------------------------------------|-----------|
| `api.enabled`                      | Enable or disable the API component                                          | `true`    |
| `api.replicas`                     | Number of replicas for the API service                                        | `1`       |
| `api.resources`                    | Resources configuration for the API service                                  | `{}`      |
| `api.nodeSelector`                 | Node selector for scheduling API pods                                        | `{}`      |
| `api.affinity`                     | Pod affinity for the API service                                             | `{}`      |
| `api.tolerations`                  | Tolerations for the API pods                                                 | `[]`      |
| `api.autoscaling.enabled`           | Enable or disable auto-scaling for the API component                         | `false`   |
| `api.autoscaling.minReplicas`      | Minimum number of replicas for the API service when autoscaling is enabled   | `1`       |
| `api.autoscaling.maxReplicas`      | Maximum number of replicas for the API service when autoscaling is enabled   | `100`     |
| `api.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage for autoscaling                 | `80`      |
| `api.livenessProbe.enabled`        | Enable or disable the liveness probe for API pods                            | `true`    |
| `api.livenessProbe.initialDelaySeconds` | Initial delay before performing liveness probe checks                       | `30`      |
| `api.livenessProbe.periodSeconds`  | Frequency of liveness probe checks                                           | `30`      |
| `api.livenessProbe.timeoutSeconds` | Timeout for liveness probe checks                                            | `5`       |
| `api.livenessProbe.failureThreshold` | Number of failures before considering the pod as unhealthy                  | `5`       |
| `api.livenessProbe.successThreshold` | Number of successes required to consider the pod as healthy                | `1`       |
| `api.readinessProbe.enabled`       | Enable or disable the readiness probe for API pods                           | `true`    |
| `api.readinessProbe.initialDelaySeconds` | Initial delay before performing readiness probe checks                      | `10`      |
| `api.readinessProbe.periodSeconds` | Frequency of readiness probe checks                                          | `10`      |
| `api.readinessProbe.timeoutSeconds` | Timeout for readiness probe checks                                           | `5`       |
| `api.readinessProbe.failureThreshold` | Number of failures before considering the pod as not ready                  | `5`       |
| `api.readinessProbe.successThreshold` | Number of successes required to consider the pod as ready                   | `1`       |
| `api.startupProbe.enabled`         | Enable or disable the startup probe for API pods                             | `false`   |
| `api.startupProbe.initialDelaySeconds` | Initial delay before performing startup probe checks                        | `5`       |
| `api.startupProbe.periodSeconds`   | Frequency of startup probe checks                                            | `10`      |
| `api.startupProbe.timeoutSeconds`  | Timeout for startup probe checks                                             | `5`       |
| `api.startupProbe.failureThreshold` | Number of failures before considering the pod as failed during startup      | `5`       |
| `api.startupProbe.successThreshold` | Number of successes required to consider the pod as successfully started    | `1`       |
| `api.customLivenessProbe`          | Custom liveness probe configuration that overrides the default one          | `{}`      |
| `api.customReadinessProbe`         | Custom readiness probe configuration that overrides the default one         | `{}`      |
| `api.customStartupProbe`           | Custom startup probe configuration that overrides the default one           | `{}`      |
| `api.podSecurityContext`           | Security context for the API pods                                            | `{}`      |
| `api.containerSecurityContext`     | Security context for the API container                                       | `{}`      |
| `api.extraEnv`                     | Custom environment variables for the API container                           | `[]`      |
| `api.logLevel`                     | Log level for the API application                                            | `INFO`    |
| `api.service.port`                 | Port on which the API service will be exposed                                | `5001`    |
| `api.service.annotations`          | Annotations for the API service                                              | `{}`      |
| `api.service.labels`               | Labels for the API service                                                   | `{}`      |
| `api.service.clusterIP`            | Cluster IP for the API service                                               | `""`      |
| `api.url.consoleApi`               | Backend URL for the console API                                              | `""`      |
| `api.url.consoleWeb`               | Front-end URL for the console web                                            | `""`      |
| `api.url.serviceApi`               | Service API URL for front-end communication                                  | `""`      |
| `api.url.appApi`                   | WebApp API backend URL                                                       | `""`      |
| `api.url.appWeb`                   | WebApp URL for front-end communication                                       | `""`      |
| `api.url.files`                    | File preview or download URL prefix                                          | `""`      |
| `api.url.marketplaceApi`           | Marketplace API URL                                                          | `https://marketplace.dify.ai` |
| `api.url.marketplace`              | Marketplace URL                                                              | `https://marketplace.dify.ai` |
| `api.mail.defaultSender`           | Default email sender for API-related emails                                  | `"YOUR EMAIL FROM (e.g.: no-reply <no-reply@dify.ai>)"` |
| `api.mail.type`                    | Mail service type (SMTP or Resend)                                           | `"resend"`|
| `api.mail.resend.apiKey`           | API key for Resend email service                                             | `"xxxx"`  |
| `api.mail.resend.apiUrl`           | API URL for Resend email service                                             | `"https://api.resend.com"` |
| `api.mail.smtp.server`             | SMTP server for sending emails                                               | `"smtp.server.com"` |
| `api.mail.smtp.port`               | SMTP port for sending emails                                                 | `465`     |
| `api.mail.smtp.username`           | SMTP username                                                                | `"YOUR EMAIL"` |
| `api.mail.smtp.password`           | SMTP password                                                                | `"YOUR EMAIL PASSWORD"` |
| `api.mail.smtp.tls.enabled`        | Enable or disable TLS for SMTP                                               | `true`    |
| `api.mail.smtp.tls.optimistic`     | Enable or disable optimistic TLS for SMTP                                    | `false`   |
| `api.migration`                    | Enable or disable migrations before application startup                      | `true`    |
| `api.secretKey`                    | Secret key for securely signing the session cookie and encrypting sensitive information | `"sk-9f73s3ljTXVcMT3Blb3ljTqtsKiGHXVcMT3BlbkFJLK7U"` |
| `api.persistence`                  | Persistent storage for API service                                           | `{}`      |
| `api.serviceAccount.create`        | Create a service account for the API service                                 | `false`   |
| `api.serviceAccount.name`          | Name of the service account to use for the API service                       | `""`      |
| `api.serviceAccount.automountServiceAccountToken` | Enable automatic mounting of ServiceAccountToken for the service account | `false`   |
| `api.serviceAccount.annotations`   | Custom annotations for the API service account                               | `{}`      |

### worker 配置

| Key                                | Description                                                                 | Default   |
|------------------------------------|-----------------------------------------------------------------------------|-----------|
| `worker.enabled`                   | Enable or disable the worker component                                       | `true`    |
| `worker.replicas`                  | Number of replicas for the worker service                                    | `1`       |
| `worker.resources`                 | Resources configuration for the worker service                               | `{}`      |
| `worker.nodeSelector`              | Node selector for scheduling worker pods                                     | `{}`      |
| `worker.affinity`                  | Pod affinity for the worker service                                          | `{}`      |
| `worker.tolerations`               | Tolerations for the worker pods                                              | `[]`      |
| `worker.autoscaling.enabled`       | Enable or disable auto-scaling for the worker component                      | `false`   |
| `worker.autoscaling.minReplicas`   | Minimum number of replicas for the worker service when autoscaling is enabled | `1`       |
| `worker.autoscaling.maxReplicas`   | Maximum number of replicas for the worker service when autoscaling is enabled | `100`     |
| `worker.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage for autoscaling                     | `80`      |
| `worker.customLivenessProbe`       | Custom liveness probe configuration that overrides the default one          | `{}`      |
| `worker.customReadinessProbe`      | Custom readiness probe configuration that overrides the default one         | `{}`      |
| `worker.customStartupProbe`        | Custom startup probe configuration that overrides the default one           | `{}`      |
| `worker.podSecurityContext`        | Security context for the worker pods                                          | `{}`      |
| `worker.containerSecurityContext`  | Security context for the worker container                                    | `{}`      |
| `worker.extraEnv`                  | Custom environment variables for the worker container                        | `[]`      |
| `worker.logLevel`                  | Log level for the worker | |

### web 配置

| Key                                   | Description                                                                                                                                                            | Default                |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| `web.enabled`                         | Enable or disable the web service                                                                                                                                        | true                   |
| `web.replicas`                        | Number of replicas for the web service                                                                                                                                   | 1                      |
| `web.resources`                       | Resource requests and limits for the web containers                                                                                                                      | {}                     |
| `web.nodeSelector`                    | Node selector for web pods                                                                                                                                              | {}                     |
| `web.affinity`                         | Affinity settings for the web pods                                                                                                                                      | {}                     |
| `web.tolerations`                     | Tolerations for the web pods                                                                                                                                           | []                     |
| `web.autoscaling.enabled`             | Enable or disable autoscaling for the web service                                                                                                                        | false                  |
| `web.autoscaling.minReplicas`         | Minimum replicas for autoscaling                                                                                                                                        | 1                      |
| `web.autoscaling.maxReplicas`         | Maximum replicas for autoscaling                                                                                                                                        | 100                    |
| `web.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage for autoscaling                                                                                                                        | 80                     |
| `web.livenessProbe.enabled`          | Enable liveness probe for web containers                                                                                                                                 | true                   |
| `web.livenessProbe.initialDelaySeconds` | Initial delay before the liveness probe starts                                                                                                                                 | 5                      |
| `web.livenessProbe.periodSeconds`    | Frequency of the liveness probe                                                                                                                                         | 30                     |
| `web.livenessProbe.timeoutSeconds`   | Timeout for the liveness probe                                                                                                                                          | 5                      |
| `web.livenessProbe.failureThreshold` | Number of failures before marking the pod as unhealthy                                                                                                                   | 5                      |
| `web.livenessProbe.successThreshold` | Number of successes before marking the pod as healthy                                                                                                                   | 1                      |
| `web.readinessProbe.enabled`         | Enable readiness probe for web containers                                                                                                                                 | true                   |
| `web.readinessProbe.initialDelaySeconds` | Initial delay before the readiness probe starts                                                                                                                           | 5                      |
| `web.readinessProbe.periodSeconds`   | Frequency of the readiness probe                                                                                                                                       | 10                     |
| `web.readinessProbe.timeoutSeconds`  | Timeout for the readiness probe                                                                                                                                         | 5                      |
| `web.readinessProbe.failureThreshold`| Number of failures before marking the pod as not ready                                                                                                                  | 5                      |
| `web.readinessProbe.successThreshold`| Number of successes before marking the pod as ready                                                                                                                    | 1                      |
| `web.startupProbe.enabled`           | Enable startup probe for web containers                                                                                                                                  | false                  |
| `web.customLivenessProbe`             | Custom liveness probe for overriding the default one                                                                                                                     | {}                     |
| `web.customReadinessProbe`            | Custom readiness probe for overriding the default one                                                                                                                    | {}                     |
| `web.customStartupProbe`             | Custom startup probe for overriding the default one                                                                                                                     | {}                     |
| `web.podSecurityContext`              | Security context for the pod                                                                                                                                           | {}                     |
| `web.containerSecurityContext`       | Security context for the container                                                                                                                                      | {}                     |
| `web.extraEnv`                        | Extra environment variables for the web containers                                                                                                                       | - name: EDITION<br>value: "SELF_HOSTED" |
| `web.service.port`                    | Port exposed by the web service                                                                                                                                       | 3000                   |
| `web.service.annotations`             | Annotations for the web service                                                                                                                                          | {}                     |
| `web.service.labels`                  | Labels for the web service                                                                                                                                               | {}                     |
| `web.service.clusterIP`               | Cluster IP for the web service                                                                                                                                         | ""                     |
| `web.serviceAccount.create`           | Enable or disable creation of a ServiceAccount for the web service                                                                                                       | false                  |
| `web.serviceAccount.name`             | Name of the ServiceAccount for the web service                                                                                                                           | ""                     |
| `web.serviceAccount.automountServiceAccountToken` | Enable auto mount of ServiceAccount token                                                                                                                                | false                  |
| `web.serviceAccount.annotations`      | Annotations for the ServiceAccount                                                                                                                                      | {}                     |

### sandbox 配置

| Key                                   | Description                                                                                                                                                            | Default                |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| `sandbox.enabled`                     | Enable or disable the sandbox service                                                                                                                                     | true                   |
| `sandbox.replicas`                    | Number of replicas for the sandbox service                                                                                                                                 | 1                      |
| `sandbox.resources`                   | Resource requests and limits for the sandbox containers                                                                                                                  | {}                     |
| `sandbox.nodeSelector`                | Node selector for sandbox pods                                                                                                                                          | {}                     |
| `sandbox.affinity`                    | Affinity settings for the sandbox pods                                                                                                                                     | {}                     |
| `sandbox.tolerations`                 | Tolerations for the sandbox pods                                                                                                                                         | []                     |
| `sandbox.autoscaling.enabled`         | Enable or disable autoscaling for the sandbox service                                                                                                                     | false                  |
| `sandbox.autoscaling.minReplicas`     | Minimum replicas for autoscaling                                                                                                                                         | 1                      |
| `sandbox.autoscaling.maxReplicas`     | Maximum replicas for autoscaling                                                                                                                                         | 100                    |
| `sandbox.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage for autoscaling                                                                                                                        | 80                     |
| `sandbox.livenessProbe.enabled`      | Enable liveness probe for sandbox containers                                                                                                                              | true                   |
| `sandbox.livenessProbe.initialDelaySeconds` | Initial delay before the liveness probe starts                                                                                                                                 | 1                      |
| `sandbox.livenessProbe.periodSeconds`| Frequency of the liveness probe                                                                                                                                         | 5                      |
| `sandbox.livenessProbe.timeoutSeconds` | Timeout for the liveness probe                                                                                                                                          | 5                      |
| `sandbox.livenessProbe.failureThreshold` | Number of failures before marking the pod as unhealthy                                                                                                                   | 2                      |
| `sandbox.livenessProbe.successThreshold` | Number of successes before marking the pod as healthy                                                                                                                   | 1                      |
| `sandbox.readinessProbe.enabled`     | Enable readiness probe for sandbox containers                                                                                                                             | true                   |
| `sandbox.readinessProbe.initialDelaySeconds` | Initial delay before the readiness probe starts                                                                                                                           | 10                     |
| `sandbox.readinessProbe.periodSeconds` | Frequency of the readiness probe                                                                                                                                       | 10                     |
| `sandbox.readinessProbe.timeoutSeconds` | Timeout for the readiness probe                                                                                                                                         | 5                      |
| `sandbox.readinessProbe.failureThreshold` | Number of failures before marking the pod as not ready                                                                                                                  | 2                      |
| `sandbox.readinessProbe.successThreshold` | Number of successes before marking the pod as ready                                                                                                                    | 1                      |
| `sandbox.startupProbe.enabled`       | Enable startup probe for sandbox containers                                                                                                                               | false                  |
| `sandbox.customLivenessProbe`         | Custom liveness probe for overriding the default one                                                                                                                     | {}                     |
| `sandbox.customReadinessProbe`        | Custom readiness probe for overriding the default one                                                                                                                    | {}                     |
| `sandbox.customStartupProbe`         | Custom startup probe for overriding the default one                                                                                                                     | {}                     |
| `sandbox.podSecurityContext`          | Security context for the sandbox pod                                                                                                                                    | {}                     |
| `sandbox.containerSecurityContext`   | Security context for the sandbox container                                                                                                                               | {}                     |
| `sandbox.extraEnv`                    | Extra environment variables for the sandbox containers                                                                                                                   | - name: WORKER_TIMEOUT<br>value: "15" |
| `sandbox.service.port`                | Port exposed by the sandbox service                                                                                                                                     | 8194                   |
| `sandbox.auth.apiKey`                 | API key for authentication to the sandbox service                                                                                                                       | "dify-sandbox"         |
| `sandbox.privileged`                  | Privileged flag for the sandbox pods                                                                                                                                     | false                  |
| `sandbox.serviceAccount.create`       | Enable or disable creation of a ServiceAccount for the sandbox service                                                                                                   | false                  |
| `sandbox.serviceAccount.name`         | Name of the ServiceAccount for the sandbox service                                                                                                                       | ""                     |
| `sandbox.serviceAccount.automountServiceAccountToken` | Enable auto mount of ServiceAccount token                                                                                                                                | false                  |
| `sandbox.serviceAccount.annotations`  | Annotations for the ServiceAccount                                                                                                                                      | {}                     |

### ssrfProxy 配置

| Key                                   | Description                                                                                                                                                            | Default                |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| `ssrfProxy.enabled`                   | Enable or disable the ssrf proxy service                                                                                                                                   | false                  |
| `ssrfProxy.replicas`                  | Number of replicas for the ssrf proxy service                                                                                                                              | 1                      |
| `ssrfProxy.resources`                 | Resource requests and limits for the ssrf proxy containers                                                                                                               | {}                     |
| `ssrfProxy.nodeSelector`              | Node selector for ssrf proxy pods                                                                                                                                       | {}                     |
| `ssrfProxy.affinity`                  | Affinity settings for the ssrf proxy pods                                                                                                                                   | {}                     |
| `ssrfProxy.tolerations`               | Tolerations for the ssrf proxy pods                                                                                                                                       | []                     |
| `ssrfProxy.customLivenessProbe`       | Custom liveness probe for overriding the default one                                                                                                                     | {}                     |
| `ssrfProxy.customReadinessProbe`      | Custom readiness probe for overriding the default one                                                                                                                    | {}                     |
| `ssrfProxy.customStartupProbe`        | Custom startup probe for overriding the default one                                                                                                                     | {}                     |
| `ssrfProxy.podSecurityContext`        | Security context for the ssrf proxy pod                                                                                                                                  | {}                     |
| `ssrfProxy.containerSecurityContext`  | Security context for the ssrf proxy container                                                                                                                             | {}                     |
| `ssrfProxy.log.persistence.enabled`   | Enable or disable persistence | |
### pluginDaemon 配置

| Key                                    | Description                                                                                                                                                             | Default           |
|----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------|
| `pluginDaemon.enabled`                 | Specifies whether the plugin daemon is enabled or not.                                                                                                                  | `true`            |
| `pluginDaemon.replicas`                | Number of replicas for the plugin daemon pod.                                                                                                                           | `1`               |
| `pluginDaemon.resources`               | Resource requests and limits for the plugin daemon container.                                                                                                          | `{}`              |
| `pluginDaemon.nodeSelector`            | Node selector for selecting specific nodes on which the plugin daemon pods should run.                                                                                  | `{}`              |
| `pluginDaemon.affinity`                | Affinity rules for the plugin daemon pods.                                                                                                                               | `{}`              |
| `pluginDaemon.tolerations`             | Tolerations for the plugin daemon pods.                                                                                                                                  | `[]`              |
| `pluginDaemon.customLivenessProbe`     | Custom liveness probe configuration to override the default one.                                                                                                       | `{}`              |
| `pluginDaemon.customReadinessProbe`    | Custom readiness probe configuration to override the default one.                                                                                                      | `{}`              |
| `pluginDaemon.customStartupProbe`      | Custom startup probe configuration to override the default one.                                                                                                       | `{}`              |
| `pluginDaemon.podSecurityContext`      | Security context settings for the plugin daemon pod.                                                                                                                    | `{}`              |
| `pluginDaemon.containerSecurityContext`| Security context settings for the plugin daemon container.                                                                                                              | `{}`              |
| `pluginDaemon.extraEnv`                | Additional environment variables to be applied to the plugin daemon container.                                                                                           | `[]`              |
| `pluginDaemon.service.ports.daemon`    | Port on which the plugin daemon service will be exposed.                                                                                                               | `5002`            |
| `pluginDaemon.service.ports.pluginInstall` | Port for plugin installation service. If not specified, no port will be exposed.                                                                                         | (undefined)       |
| `pluginDaemon.service.annotations`     | Custom annotations for the plugin daemon service.                                                                                                                       | `{}`              |
| `pluginDaemon.service.labels`          | Custom labels for the plugin daemon service.                                                                                                                              | `{}`              |
| `pluginDaemon.service.clusterIP`       | ClusterIP for the plugin daemon service.                                                                                                                                  | `""`              |
| `pluginDaemon.auth.serverKey`          | The key used for interactions between the `api` (`worker`) and the `pluginDaemon`.                                                                                      | (custom key)      |
| `pluginDaemon.auth.difyApiKey`         | API key for Dify API interactions.                                                                                                                                       | (custom key)      |
| `pluginDaemon.persistence.mountPath`   | Mount path for persistent volume storage used by the plugin daemon.                                                                                                    | `/app/storage`    |
| `pluginDaemon.persistence.annotations` | Custom annotations for persistent volume claim used by the plugin daemon.                                                                                              | `helm.sh/resource-policy: keep` |
| `pluginDaemon.persistence.persistentVolumeClaim.existingClaim` | Existing persistent volume claim for the plugin daemon. If set, the `existingClaim` will be used instead of creating a new one.                                           | `""`              |
| `pluginDaemon.persistence.storageClass`| Storage class for the plugin daemon's persistent volume claim.                                                                                                          | `cfs`             |
| `pluginDaemon.persistence.accessModes` | Access modes for the persistent volume claim.                                                                                                                            | `ReadWriteMany`   |
| `pluginDaemon.persistence.size`        | Size of the persistent volume.                                                                                                                                           | `10Gi`            |
| `pluginDaemon.persistence.subPath`     | Sub-path for persistent volume storage.                                                                                                                                  | `""`              |
| `pluginDaemon.marketplace.enabled`     | Specifies whether the marketplace feature is enabled.                                                                                                                  | `true`            |
| `pluginDaemon.marketplace.apiProxyEnabled` | Enables proxy for marketplace API calls routed to the built-in NGINX.                                                                                                   | `false`           |
| `pluginDaemon.serviceAccount.create`   | Specifies whether a ServiceAccount should be created for the plugin daemon.                                                                                             | `false`           |
| `pluginDaemon.serviceAccount.name`     | The name of the ServiceAccount to be used. If not set and `create` is `true`, a name will be generated automatically.                                                     | `""`              |
| `pluginDaemon.serviceAccount.automountServiceAccountToken` | Allows automatic mounting of ServiceAccountToken to the ServiceAccount created for the plugin daemon.                                                                  | `false`           |
| `pluginDaemon.serviceAccount.annotations` | Additional custom annotations for the ServiceAccount.                                                                                                                   | `{}`              |

### External 配置

#### External DB Configration

**redis Configration**

| Key                            | Description                                                                                             | Default             |
|---------------------------------|---------------------------------------------------------------------------------------------------------|---------------------|
| `externalRedis.enabled`         | Specifies whether the external Redis configuration is enabled.                                          | `false`             |
| `externalRedis.host`            | The hostname or IP address of the external Redis instance.                                              | `redis.example`     |
| `externalRedis.port`            | The port number for the external Redis instance.                                                       | `6379`              |
| `externalRedis.username`        | The username for authenticating to the Redis instance (if applicable).                                  | (empty)             |
| `externalRedis.password`        | The password for authenticating to the Redis instance.                                                  | `difyai123456`      |
| `externalRedis.useSSL`          | Specifies whether to use SSL for Redis connection.                                                     | `false`             |

---
**postgres Configration**

| Key                             | Description                                                                                             | Default             |
|----------------------------------|---------------------------------------------------------------------------------------------------------|---------------------|
| `externalPostgres.enabled`      | Specifies whether the external PostgreSQL configuration is enabled.                                      | `false`             |
| `externalPostgres.username`     | The username for authenticating to the PostgreSQL database.                                              | `postgres`          |
| `externalPostgres.password`     | The password for authenticating to the PostgreSQL database.                                              | `difyai123456`      |
| `externalPostgres.address`      | The address (hostname or IP) of the external PostgreSQL instance.                                        | `localhost`         |
| `externalPostgres.port`         | The port number for the external PostgreSQL instance.                                                   | `5432`              |
| `externalPostgres.database.api` | The name of the database used for the API.                                                              | `dify`              |
| `externalPostgres.database.pluginDaemon` | The name of the database used for the plugin daemon.                                                 | `dify_plugin`       |
| `externalPostgres.maxOpenConns` | The maximum number of open connections to the PostgreSQL instance.                                       | `20`                |
| `externalPostgres.maxIdleConns` | The maximum number of idle connections to the PostgreSQL instance.                                       | `5`                 |

#### External Storage Configration

**Tencent COS Configration**

| Key                             | Description                                                                                             | Default            |
|---------------------------------|---------------------------------------------------------------------------------------------------------|--------------------|
| `externalCOS.enabled`           | Specifies whether the external Tencent COS (Cloud Object Storage) configuration is enabled.            | `false`            |
| `externalCOS.secretKey`         | The secret key used to authenticate with Tencent COS.                                                   | `your-secret-key`  |
| `externalCOS.secretId`          | The secret ID used to authenticate with Tencent COS.                                                    | `your-secret-id`   |
| `externalCOS.region`            | The region of the Tencent COS bucket.                                                                   | `your-region`      |
| `externalCOS.bucketName`        | The name of the Tencent COS bucket to use.                                                              | `your-bucket-name` |
| `externalCOS.scheme`            | The scheme to use for the Tencent COS configuration (e.g., `https`).                                    | `your-scheme`      |

#### External VectorDB configuration

**Tencent Vector DB Configuration**

| Key                                        | Description                                                                                                                                                    | Default                     |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `externalTencentVectorDB.enabled`          | Enables or disables the use of Tencent Vector DB, takes effect only if all other external DB options are disabled.                                             | `false`                     |
| `externalTencentVectorDB.url`              | The URL for accessing the external Tencent Vector DB service.                                                                                                 | `"your-tencent-vector-db-url"` |
| `externalTencentVectorDB.apiKey`           | The API key used for authentication with the external Tencent Vector DB service.                                                                               | `"your-tencent-vector-db-api-key"` |
| `externalTencentVectorDB.timeout`          | The timeout in seconds for requests to Tencent Vector DB.                                                                                                      | `30`                        |
| `externalTencentVectorDB.username`         | The username for accessing Tencent Vector DB.                                                                                                                 | `"root"`                    |
| `externalTencentVectorDB.database`         | The database name to use in Tencent Vector DB.                                                                                                                | `"dify"`                    |
| `externalTencentVectorDB.shard`            | The number of shards for Tencent Vector DB.                                                                                                                   | `1`                         |
| `externalTencentVectorDB.replicas`         | The number of replicas for Tencent Vector DB.                                                                                                                | `2`                         |

---

**Weaviate Configuration**

| Key                                        | Description                                                                                                                                                    | Default                     |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `externalWeaviate.enabled`                 | Enables or disables the use of Weaviate as the external vector database.                                                                                       | `false`                     |
| `externalWeaviate.endpoint`                | The endpoint for accessing the external Weaviate service.                                                                                                      | `"http://weaviate:8080"`     |
| `externalWeaviate.apiKey`                  | The API key used for authentication with the external Weaviate service.                                                                                       | `"WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih"` |

---

**Qdrant Configuration**

| Key                                        | Description                                                                                                                                                    | Default                     |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `externalQdrant.enabled`                   | Enables or disables the use of Qdrant as the external vector database, takes effect only if Weaviate is disabled.                                                | `false`                     |
| `externalQdrant.endpoint`                  | The endpoint for accessing the external Qdrant service.                                                                                                       | `"https://your-qdrant-cluster-url.qdrant.tech/"` |
| `externalQdrant.apiKey`                    | The API key used for authentication with the external Qdrant service.                                                                                         | `"ak-difyai"`               |
| `externalQdrant.timeout`                   | The timeout in seconds for requests to the Qdrant service.                                                                                                      | `20`                        |
| `externalQdrant.grpc.enabled`              | Enables or disables gRPC support for Qdrant.                                                                                                                   | `false`                     |
| `externalQdrant.grpc.port`                 | The port for accessing Qdrant over gRPC.                                                                                                                       | `6334`                      |

---

**Milvus Configuration**

| Key                                        | Description                                                                                                                                                    | Default                     |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `externalMilvus.enabled`                   | Enables or disables the use of Milvus as the external vector database, takes effect only if both Weaviate and Qdrant are disabled.                             | `false`                     |
| `externalMilvus.uri`                       | The URI for accessing the external Milvus service.                                                                                                             | `"http://your-milvus.domain:19530"` |
| `externalMilvus.database`                  | The database name to use in Milvus.                                                                                                                             | `"default"`                 |
| `externalMilvus.token`                     | The authentication token for Milvus.                                                                                                                           | `""`                        |
| `externalMilvus.user`                      | The username for accessing Milvus.                                                                                                                             | `""`                        |
| `externalMilvus.password`                  | The password for accessing Milvus.                                                                                                                             | `""`                        |

---

**Pgvector Configuration**

| Key                                        | Description                                                                                                                                                    | Default                     |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `externalPgvector.enabled`                 | Enables or disables the use of Pgvector as the external vector database, takes effect only if Weaviate, Qdrant, and Milvus are disabled.                        | `false`                     |
| `externalPgvector.username`                | The username for accessing the Pgvector database.                                                                                                             | `"postgres"`                |
| `externalPgvector.password`                | The password for accessing the Pgvector database.                                                                                                             | `"difyai123456"`            |
| `externalPgvector.address`                 | The address of the Pgvector database.                                                                                                                          | `"pgvector"`                |
| `externalPgvector.port`                    | The port for accessing the Pgvector database.                                                                                                                  | `5432`                      |
| `externalPgvector.dbName`                  | The database name to use in Pgvector.                                                                                                                           | `"dify"`                    |

---

**MyScaleDB Configuration**

| Key                                        | Description                                                                                                                                                    | Default                     |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| `externalMyScaleDB.enabled`                | Enables or disables the use of MyScaleDB as the external vector database, takes effect only if all other external DB options are disabled.                      | `false`                     |
| `externalMyScaleDB.host`                   | The host address for accessing the MyScaleDB service.                                                                                                          | `"myscale"`                 |
| `externalMyScaleDB.port`                   | The port for accessing the MyScaleDB service.                                                                                                                  | `8123`                      |
| `externalMyScaleDB.user`                   | The username for accessing the MyScaleDB service.                                                                                                              | `"default"`                 |
| `externalMyScaleDB.password`               | The password for accessing the MyScaleDB service.                                                                                                              | `""`                        |
| `externalMyScaleDB.database`               | The database name to use in MyScaleDB.                                                                                                                         | `"dify"`                    |
| `externalMyScaleDB.ftsParams`              | Full-text search parameters for MyScaleDB.                                                                                                                     | `""`                        |
