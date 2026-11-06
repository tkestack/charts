{{/*
Fail helm install/upgrade when Ready eligible nodes < ntracker.replicaCount.
Eligible: tke.cloud.tencent.com/p2p-ntracker=true OR tke.cloud.tencent.com/p2p-role=seeder.
lookup is empty for `helm template` / no API access; the check is skipped then.
*/}}
{{- define "p2pagent.ntracker.validateEligibleNodes" -}}
{{- $replicas := int .Values.ntracker.replicaCount -}}
{{- $nodes := lookup "v1" "Node" "" "" -}}
{{- if $nodes -}}
{{- $eligible := 0 -}}
{{- range $nodes.items -}}
{{- $labels := default dict .metadata.labels -}}
{{- if or (eq (index $labels "tke.cloud.tencent.com/p2p-ntracker") "true") (eq (index $labels "tke.cloud.tencent.com/p2p-role") "seeder") -}}
{{- $ready := false -}}
{{- range .status.conditions -}}
{{- if and (eq .type "Ready") (eq .status "True") -}}
{{- $ready = true -}}
{{- end -}}
{{- end -}}
{{- if and $ready (not .spec.unschedulable) -}}
{{- $eligible = add $eligible 1 -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if lt $eligible $replicas -}}
{{- fail (printf "ntracker.replicaCount=%d exceeds eligible Ready nodes=%d (need tke.cloud.tencent.com/p2p-ntracker=true or tke.cloud.tencent.com/p2p-role=seeder)" $replicas $eligible) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Generates DaemonSet and ConfigMap for a p2p-agent role.
Context:
  - .root: The top-level chart context ($)
  - .role: A map with "name" and "leecherMode"
*/}}
{{- define "p2pagent.agent-resources" -}}
{{- $root := .root -}}
{{- $role := .role -}}
{{- $httpsRegistries := dict -}}
{{- $registryHttp := list -}}
{{- range $registry := splitList "," (default "" $root.Values.agent.registryHttps) -}}
  {{- $registry = trim $registry -}}
  {{- if $registry -}}
    {{- $_ := set $httpsRegistries $registry true -}}
  {{- end -}}
{{- end -}}
{{- range $registry := splitList "," (default "" $root.Values.agent.registryHttp) -}}
  {{- $registry = trim $registry -}}
  {{- if and $registry (not (hasKey $httpsRegistries $registry)) -}}
    {{- $registryHttp = append $registryHttp $registry -}}
  {{- end -}}
{{- end -}}
{{- $registryHttp = join "," $registryHttp -}}
{{- if and $root.Values.agent.reuseContainerdContentStore (ne $root.Values.agent.trackerType "ntracker") -}}
  {{- fail "agent.reuseContainerdContentStore=true only supports trackerType=ntracker" -}}
{{- end -}}
{{- if and (gt (int $root.Values.ntracker.originMaxConcurrentPerSlice) 0) (ne $root.Values.agent.trackerType "ntracker") -}}
  {{- fail "ntracker.originMaxConcurrentPerSlice>0 only supports trackerType=ntracker" -}}
{{- end -}}
{{- if and $root.Values.spread.enabled (not $root.Values.watcher.enabled) -}}
  {{- fail "spread.enabled=true requires watcher.enabled=true: spread reports hot layers to watcher" -}}
{{- end -}}
{{- $roleName := $role.name -}}
{{- $daemonSetName := ( eq $roleName "" ) | ternary "p2p-agent" (printf "p2p-agent-%s" $roleName) -}}
{{- $configMapName := ( eq $roleName "" ) | ternary "p2p-agent-config" (printf "p2p-agent-config-%s" $roleName) -}}
{{/*
effectiveRole is the actual role of these pods: the per-role name in mixed mode,
otherwise the deployMode itself. It labels the pods so that the seeder/leecher
headless services select the right nodes in every deploy mode (see 04-agent.yaml).
It is NOT added to the DaemonSet selector: selectors are immutable, so adding it
would break `helm upgrade` on an already installed non-mixed release.
*/}}
{{- $effectiveRole := $roleName | default $root.Values.global.deployMode -}}

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ $daemonSetName }}
  namespace: {{ $root.Values.global.namespace }}
spec:
  selector:
    matchLabels:
      app: p2p-agent
      {{- if $roleName }}
      role: {{ $roleName }}
      {{- end }}
  template:
    metadata:
      labels:
        app: p2p-agent
        role: {{ $effectiveRole }}
    spec:
      tolerations:
{{ toYaml $root.Values.tolerations.agent | indent 8 }}
      affinity:
        {{- if eq $effectiveRole "seeder" }}
{{ toYaml $root.Values.affinity.seeder | indent 8 }}
        {{- else if eq $effectiveRole "leecher" }}
{{ toYaml $root.Values.affinity.leecher | indent 8 }}
        {{- end }}
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      shareProcessNamespace: true
      restartPolicy: Always
{{- if or (eq $root.Values.agent.trackerType "ntracker") $root.Values.agent.containerdProxyAutoConfig }}
      initContainers:
{{- if eq $root.Values.agent.trackerType "ntracker" }}
        - name: wait-ntracker
          image: {{ $root.Values.images.agent.image }}:{{ $root.Values.images.agent.tag}}
          imagePullPolicy:  {{ $root.Values.global.imagePullPolicy }}
          command: ["/app/init-wait-ntracker.sh"]
          env:
            - name: NTRACKER_URL
              value: "{{ $root.Values.agent.ntrackerDNS }}"
            - name: NTRACKER_PORT
              value: "{{ $root.Values.ntracker.port }}"
{{- end }}
{{- if $root.Values.agent.containerdProxyAutoConfig }}
        - name: p2p-mirror-setup
          image: {{ $root.Values.images.mirrorSetup.image }}:{{ $root.Values.images.mirrorSetup.tag }}
          imagePullPolicy: {{ $root.Values.global.imagePullPolicy }}
          command: ["/usr/local/bin/p2p-mirror-setup.sh"]
          env:
            - name: REGISTRIES
              value: "{{ $root.Values.agent.registryHttps }}"
            - name: REGISTRIES_HTTP
              value: "{{ $registryHttp }}"
            - name: AGENT_PORT
              value: "{{ $root.Values.agent.portHTTP }}"
          securityContext:
            privileged: true
          volumeMounts:
            - name: host-containerd-etc
              mountPath: /host/etc/containerd
            - name: host-run-systemd
              mountPath: /run/systemd
            - name: host-dbus
              mountPath: /var/run/dbus
{{- end }}
{{- end }}
      containers:
        - name: p2p-agent
          image: {{ $root.Values.images.agent.image }}:{{ $root.Values.images.agent.tag}}
          imagePullPolicy: {{ $root.Values.global.imagePullPolicy }}
{{- if $root.Values.agent.containerdProxyAutoConfig }}
          lifecycle:
            preStop:
              exec:
                command:
                  - /bin/sh
                  - -c
                  - |
                    REGISTRIES="{{ $root.Values.agent.registryHttps }}" \
                    REGISTRIES_HTTP="{{ $registryHttp }}" \
                    AGENT_PORT="{{ $root.Values.agent.portHTTP }}" \
                    /app/p2p-mirror-cleanup.sh
{{- end }}
{{- with $root.Values.resources.agent }}
          resources:
            {{- toYaml . | nindent 12 }}
{{- end }}
          ports:
            - containerPort: {{ $root.Values.agent.portHTTP }}
              hostPort: {{ $root.Values.agent.portHTTP }}
              protocol: TCP
            - containerPort: {{ $root.Values.agent.adminPort }}
              name: admin-http
              protocol: TCP

          volumeMounts:
            - name: socket-dir
              mountPath: {{ $root.Values.agent.socketDir }}
            - name: config-volume
              mountPath: /app/config
            - name: certs-dir
              mountPath: /app/certs
{{- if $root.Values.agent.agentDataDir }}
            - name: agent-data
              mountPath: /app/agent
{{- end }}
{{- if or $role.leecherMode $root.Values.agent.reuseContainerdContentStore }}
            - name: tmpfs-data
              mountPath: /app/agent/data
{{- end }}
{{- if and $root.Values.agent.reuseContainerdContentStore (not $role.leecherMode) }}
            - name: containerd-content
              mountPath: {{ $root.Values.agent.containerdContentDir }}
              readOnly: true
{{- end }}
{{- if $root.Values.agent.containerdProxyAutoConfig }}
            - name: host-containerd-etc
              mountPath: /host/etc/containerd
{{- end }}
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            - name: NODE_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: P2P_REGISTRIES
              value: "{{ $root.Values.agent.registryHttps }}"
      volumes:
        - name: socket-dir
          hostPath:
            path: {{ $root.Values.agent.hostSocketDir }}
            type: DirectoryOrCreate
        - name: config-volume
          configMap:
            name: {{ $configMapName }}
        - name: certs-dir
          emptyDir: {}
{{- if $root.Values.agent.agentDataDir }}
        - name: agent-data
          hostPath:
            path: {{ $root.Values.agent.agentDataDir }}
            type: DirectoryOrCreate
{{- end }}
{{- if or $role.leecherMode $root.Values.agent.reuseContainerdContentStore }}
        - name: tmpfs-data
          emptyDir:
            medium: Memory
            sizeLimit: {{ mulf $root.Values.agent.maxMemoryUsageMB 1.2 | ceil }}Mi
{{- end }}
{{- if and $root.Values.agent.reuseContainerdContentStore (not $role.leecherMode) }}
        - name: containerd-content
          hostPath:
            path: {{ $root.Values.agent.containerdContentDir }}
            type: Directory
{{- end }}
{{- if $root.Values.agent.containerdProxyAutoConfig }}
        - name: host-containerd-etc
          hostPath:
            path: /etc/containerd
            type: DirectoryOrCreate
        - name: host-run-systemd
          hostPath:
            path: /run/systemd
            type: Directory
        - name: host-dbus
          hostPath:
            path: /var/run/dbus
            type: Directory
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $configMapName }}
  namespace: {{ $root.Values.global.namespace }}
data:
  config.yml: |
    server:
      service:
        - name: admin_http_service
          protocol: http
          addr: 0.0.0.0
          port: {{ $root.Values.agent.adminPort }}

        - name: data_unit_http_service
          protocol: http
          addr: 127.0.0.1
          port: {{ $root.Values.agent.dataUnitPort }}

        - name: preheat_http_service
          protocol: http
          addr: 0.0.0.0
          port: {{ $root.Values.agent.preheatPort }}

    p2p:
      feature_mode: "{{ $root.Values.agent.featureMode }}"
      leecher_mode: {{ $role.leecherMode }}
      {{/* storage_mode: "memory" when leecherMode or SliceStore seeder (tmpfs buffer) */}}
      {{- $useMemory := or $role.leecherMode $root.Values.agent.reuseContainerdContentStore -}}
      storage_mode: {{ ternary "memory" "disk" $useMemory | quote }}
      max_memory_usage_mb: {{ $root.Values.agent.maxMemoryUsageMB }}
      trackers: "{{ $root.Values.agent.trackersAddr }}"
      tracker_type: "{{ $root.Values.agent.trackerType }}"
      ntracker_dns: "{{ $root.Values.agent.ntrackerDNS }}"
      ntrackers_addr: "{{ $root.Values.agent.ntrackersAddr }}"
      ntracker_port: {{ $root.Values.ntracker.port }}
      ntracker_unreachable_window: {{ $root.Values.ntracker.unreachableWindow }}
      peer_port_range: "{{ $root.Values.agent.peerPortRange }}"
      meta_manager_polaris: "{{ $root.Values.agent.metaManagerAddr }}"
      min_p2p_timeout: {{ $root.Values.agent.minP2PTimeout }}
      min_p2p_download_speed: {{ $root.Values.agent.minP2PDownloadSpeed }}
      root_dir: "/app/agent"
      {{- if and $root.Values.agent.reuseContainerdContentStore (not $role.leecherMode) }}
      enable_slice_store: true
      containerd_blob_dir: "{{ $root.Values.agent.containerdContentDir }}/blobs/sha256"
      containerd_ingest_dir: "{{ $root.Values.agent.containerdContentDir }}/ingest"
      {{- end }}

      http_addr: "0.0.0.0:{{ $root.Values.agent.portHTTP }}"
      https_addr: "0.0.0.0:{{ $root.Values.agent.portHTTPS }}"

      cert_file: "./certs/p2p_domain.crt"
      key_file: "./certs/p2p_domain.key"
      uds_file: "{{ $root.Values.agent.socketDir }}/agent.sock"

      https_registry: "{{ $root.Values.agent.registryHttps }}"
      http_registry: "{{ $registryHttp }}"
      default_registry: "{{ $root.Values.agent.defaultRegistry }}"
      remote_mirror_cidr: "{{ $root.Values.agent.remoteMirrorCIDR }}"
      enable_proxy_protocol: {{ $root.Values.agent.enableProxyProtocol }}
      trusted_proxy_cidr: "{{ $root.Values.agent.trustedProxyCIDR }}"
      enable_blob_redirect: {{ $root.Values.agent.enableBlobRedirect }}

      # torrent file piecesize, default 1MB
      piece_size: 1

      torrent_server: "{{ $root.Values.agent.torrentServerAddr }}"
      torrent_storage_prefix: "tj-common"

      max_concurrent: {{ $root.Values.agent.maxConcurrent }}
      global_max_concurrent: {{ $root.Values.agent.globalMaxConcurrent }}
      origin_max_concurrent_per_slice: {{ $root.Values.ntracker.originMaxConcurrentPerSlice }}
      head_slices: {{ default 0 $root.Values.agent.headSlices }}
      {{- if or $role.leecherMode $root.Values.agent.reuseContainerdContentStore }}
      shuffle_size: 0
      {{- else }}
      shuffle_size: {{ $root.Values.agent.shuffleSize }}
      {{- end }}
      min_slice_size: {{ $root.Values.agent.minSliceSize }}
      max_slice_size: {{ $root.Values.agent.maxSliceSize }}
      slice_size_rate: {{ $root.Values.agent.sliceSizeRate }}
      {{- if $role.leecherMode }}
      read_rate_limit: {{ $root.Values.agent.leecherReadRateLimit }}
      write_rate_limit: {{ $root.Values.agent.leecherWriteRateLimit }}
      {{- else }}
      read_rate_limit: {{ $root.Values.agent.seederReadRateLimit }}
      write_rate_limit: {{ $root.Values.agent.seederWriteRateLimit }}
      {{- end }}
      min_layer_download_speed: {{ $root.Values.agent.minLayerDownloadSpeed }}
      registry_retry_times: {{ $root.Values.agent.registryRetryTimes }}
      degrade_ttl: "{{ $root.Values.agent.degradeTTL }}"
      origin_stall_timeout: {{ default 60 $root.Values.agent.originStallTimeout }}
      layer_download_min_timeout: {{ default 120 $root.Values.agent.layerDownloadMinTimeout }}
      lru_size_gb: {{ $root.Values.agent.LRUSizeGB }}
      eviction_window_factor: {{ $root.Values.agent.evictionWindowFactor }}
      eviction_min_slack_window: {{ $root.Values.agent.evictionMinSlackWindow }}
      eviction_max_slack_window: {{ $root.Values.agent.evictionMaxSlackWindow }}
      namespace_whitelist: "{{ $root.Values.agent.namespaceWhitelist }}"
      namespace_blacklist: "{{ $root.Values.agent.namespaceBlacklist }}"
      repo_whitelist: "{{ $root.Values.agent.repoWhitelist }}"
      repo_blacklist: "{{ $root.Values.agent.repoBlacklist }}"

      bt_config:
        addrs: "eth0"
        port: "{{ $root.Values.agent.btPortRange }}"
        max_peer_connection: {{ $root.Values.agent.maxPeerConnection }}
        request_block_size: {{ $root.Values.agent.requestBlockSize }}
    log:
      debug: {{ $root.Values.agent.debug }}
      level: "{{ $root.Values.agent.logLevel }}"
      path: {{ $root.Values.agent.logPath }}
      max_size: {{ $root.Values.agent.logMaxSize }}
      max_num: {{ $root.Values.agent.logMaxNum }}
    spread:
      enabled: {{ $root.Values.spread.enabled }}
      hot_layer_window: {{ $root.Values.spread.agent.hotLayerWindow }}
      hot_layer_threshold: {{ $root.Values.spread.agent.hotLayerThreshold }}
    metrics:
      enable_layer_p2p_metrics: {{ $root.Values.agent.enableLayerP2PMetrics }}
    pprof:
      path: "/app/agent/pprof"
      interval: 120
      max_record_time: 172800
    registry:
      username: {{ $root.Values.agent.registryAuth.username | quote }}
      password: {{ $root.Values.agent.registryAuth.password | quote }}
    {{- if $root.Values.watcher.enabled }}
    watcher:
      watcher_url: "{{ $root.Values.agent.watcherUrl }}"
      watcher_heartbeat_interval: {{ $root.Values.agent.heartbeatInterval }}
      watcher_heartbeat_timeout: {{ $root.Values.agent.heartbeatTimeout }}
      watcher_max_failed_heartbeats: {{ $root.Values.agent.maxFailedHeartbeats }}
    {{- end }}
    runtime:
      work_flow:
        limiter:
          max_bt_concurrent_flow: {{ $root.Values.agent.maxBtConcurrentFlow }}
          max_cpu_percentage: {{ $root.Values.agent.maxCpuPercentage }}
          max_memory_percentage: {{ $root.Values.agent.maxMemoryPercentage }}
          max_cpu_upper_bound: {{ $root.Values.agent.maxCpuUpperBound }}
          max_memory_upper_bound: {{ $root.Values.agent.maxMemoryUpperBound }}
          overload_strategy: {{ $root.Values.agent.overloadStrategy }}
      bittorrent:
        max_peer_connection: {{ $root.Values.agent.maxPeerConnection }}
        max_concurrent_uploads: {{ $root.Values.agent.maxConcurrentUploads }}
      gc:
        expire_time: {{ $root.Values.agent.expireTime }}
        detection_interval: {{ $root.Values.agent.detectionInterval }}
        protection_time: {{ $root.Values.agent.protectionTime }}
        max_files_num: {{ $root.Values.agent.maxFilesNum }}
        disk_min_remain_ratio: {{ $root.Values.agent.diskMinRemainRatio }}
        max_gc_num_when_disk_clear: {{ $root.Values.agent.maxGcNumWhenDiskClear }}
      update_check_interval: {{ $root.Values.agent.configCheckInterval }}
{{- end -}}

{{/* Shared by the ConfigMap and the DaemonSet checksum so a config edit rolls HAProxy. */}}
{{- define "p2pagent.haproxyConfig" -}}
global
    log stdout format raw local0 info
    maxconn 20000
    stats socket /tmp/haproxy.sock mode 600 level admin
    stats timeout 30s

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5s
    timeout client  300s
    timeout server  300s
    retries 3

# 通过 Pod 的 /etc/resolv.conf 读取 CoreDNS 地址进行动态解析。
# 依赖 dnsPolicy: ClusterFirstWithHostNet（hostNetwork 下必须显式设置，
# 否则 Pod 用宿主机 resolv.conf，无法解析 *.svc.cluster.local）。
# parse-resolv-conf 需要 HAProxy >= 2.1。
resolvers kube
    parse-resolv-conf
    resolve_retries 3
    timeout resolve 1s
    timeout retry  1s
    hold valid    10s
    hold obsolete  5s
    hold nx        5s
    hold timeout   5s
    hold refused   5s

# 运维观测：HAProxy stats 页面。仅监听回环地址，不对节点网络开放
# 查看方式：kubectl exec 进 Pod 后 curl http://127.0.0.1:<statsPort>/stats，
frontend stats
    bind 127.0.0.1:{{ .Values.haproxy.statsPort }}
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    # HAProxy >= 3.0 only reports server addresses (CSV addr column) with show-legends.
    stats show-legends

# 集群A的 registry_mirror 指向 <haproxy节点IP>:<registryPort>
frontend registry_in
    bind *:{{ .Values.haproxy.registryPort }}
    mode tcp
    option tcplog
    default_backend p2p_agents

backend p2p_agents
    mode tcp
    balance source
    hash-type consistent    # 一致性哈希，节点变动时只影响 1/N 的映射
    # 说明：
    #  - send-proxy-v2  ：数据连接前发送 PROXY v2 头，携带集群A真实源IP
    #  - check-send-proxy：健康检查连接也带 PROXY 头，满足 agent 端 REQUIRE 策略
    #                      （否则健康检查会被 agent 拒绝、后端全部被判 down）
    #  - hash-key addr  ：按 seeder IP 落哈希环而非 DNS 填槽顺序，多副本对同一客户端选出同一 seeder，
    #                      集群A可配置多个 HAProxy 地址做故障切换，切换后仍命中同一 seeder 的缓存
    #  - check inter/fall/rise：TCP 健康检查，自动摘除/恢复故障 agent 节点
    default-server check check-send-proxy send-proxy-v2 hash-key addr inter 3s fall 3 rise 2
    # 动态发现：解析 seeder headless service 的 A 记录（= seeder 节点IP）。
    # 只选 seeder：leecher 用 tmpfs 且不做种，作为跨集群入口没有缓存收益。
    # 节点数超过 maxBackendServers 时调大该值。init-addr none 保证 DNS 未就绪时也能启动。
    server-template agent {{ .Values.haproxy.maxBackendServers }} p2p-agent-seeder-service.{{ .Values.global.namespace }}.svc.cluster.local:{{ .Values.agent.portHTTP }} resolvers kube init-addr none
{{- end }}
