{{/*
Generates DaemonSet and ConfigMap for a p2p-agent role.
Context:
  - .root: The top-level chart context ($)
  - .role: A map with "name" and "leecherMode"
*/}}
{{- define "p2pagent.agent-resources" -}}
{{- $root := .root -}}
{{- $role := .role -}}
{{- $roleName := $role.name -}}
{{- $daemonSetName := ( eq $roleName "" ) | ternary "p2p-agent" (printf "p2p-agent-%s" $roleName) -}}
{{- $configMapName := ( eq $roleName "" ) | ternary "p2p-agent-config" (printf "p2p-agent-config-%s" $roleName) -}}

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
        {{- if $roleName }}
        role: {{ $roleName }}
        {{- end }}
    spec:
      tolerations:
        - operator: "Exists"
          effect: "NoSchedule"
      affinity:
        {{- $effectiveRole := $roleName | default $root.Values.global.deployMode -}}
        {{- if eq $effectiveRole "seeder" }}
{{ toYaml $root.Values.affinity.seeder | indent 8 }}
        {{- else if eq $effectiveRole "leecher" }}
{{ toYaml $root.Values.affinity.leecher | indent 8 }}
        {{- end }}
      # hostNetwork: true
      # dnsPolicy: ClusterFirstWithHostNet
      shareProcessNamespace: true
      restartPolicy: Always
      containers:
        - name: p2p-agent
          image: {{ $root.Values.images.agent.image }}:{{ $root.Values.images.agent.tag}}
          imagePullPolicy: {{ $root.Values.global.imagePullPolicy }}
{{- if $root.Values.resources.agent.enabled }}
          resources:
            requests:
              cpu: {{ $root.Values.resources.agent.requests.cpu }}
              memory: {{ $root.Values.resources.agent.requests.memory }}
            limits:
              cpu: {{ $root.Values.resources.agent.limits.cpu }}
              memory: {{ $root.Values.resources.agent.limits.memory }}
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
{{- if $role.leecherMode }}
            - name: leecher-tmpfs-data
              mountPath: /app/agent/data
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
            type: Directory
{{- end }}
{{- if $role.leecherMode }}
        - name: leecher-tmpfs-data
          emptyDir:
            medium: Memory
            sizeLimit: {{ mulf $root.Values.agent.maxMemoryUsageMB 1.2 | ceil }}Mi
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
      leecher_mode: {{ $role.leecherMode }}
      {{/* storage_mode: set to "memory" when leecherMode is true, otherwise "disk" */}}
      storage_mode: {{ quote (ternary "memory" "disk" $role.leecherMode) }}
      max_memory_usage_mb: {{ $root.Values.agent.maxMemoryUsageMB }}
      trackers: "{{ $root.Values.agent.trackersAddr }}"
      meta_manager_polaris: ""
      gc_time: 43200
      max_seed_files_num: 200
      remain_disk_per: 0.2
      min_p2p_timeout: {{ $root.Values.agent.minP2PTimeout }}
      min_p2p_download_speed: {{ $root.Values.agent.minP2PDownloadSpeed }}
      root_dir: "/app/agent"

      http_addr: "0.0.0.0:{{ $root.Values.agent.portHTTP }}"

      cert_file: "./certs/p2p_domain.crt"
      key_file: "./certs/p2p_domain.key"
      uds_file: "{{ $root.Values.agent.socketDir }}/agent.sock"

      https_registry: "{{ $root.Values.agent.registryHttps }}"
      http_registry: "disable"
      default_registry: "{{ $root.Values.agent.defaultRegistry }}"
      watcher_url: "{{ $root.Values.agent.watcherUrl }}"

      # torrent file piecesize, default 1MB
      piece_size: 1

      torrent_server: "{{ $root.Values.agent.torrentServerAddr }}"
      torrent_storage_prefix: "tj-common"

      max_concurrent: {{ $root.Values.agent.maxConcurrent }}
      {{- if $role.leecherMode }}
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
      lru_size_gb: {{ $root.Values.agent.LRUSizeGB }}

      bt_config:
        addrs: "eth0"
        port: "{{ $root.Values.agent.btPortRange }}"
        max_peer_connection: {{ $root.Values.agent.maxPeerConnection }}
        request_block_size: {{ $root.Values.agent.requestBlockSize }}
      dynamic_config:
        path: "/app/config/p2p_dynamic.config"
    log:
      debug: {{ $root.Values.agent.debug }}
      path: {{ $root.Values.agent.logPath }}
      max_size: {{ $root.Values.agent.logMaxSize }}
      max_num: {{ $root.Values.agent.logMaxNum }}
    metrics:
      enable_layer_p2p_metrics: {{ $root.Values.agent.enableLayerP2PMetrics }}
    pprof:
      path: "/app/agent/pprof"
      interval: 120
      max_record_time: 172800
    registry:
      username: {{ $root.Values.watcher.registryUsername }}
      password: {{ $root.Values.watcher.registryPassword }}
    watcher:
      watcher_url: "{{ $root.Values.agent.watcherUrl }}"
      watcher_heartbeat_interval: {{ $root.Values.agent.heartbeatInterval }}
      watcher_heartbeat_timeout: {{ $root.Values.agent.heartbeatTimeout }}
      watcher_max_failed_heartbeats: {{ $root.Values.agent.maxFailedHeartbeats }}
  p2p_dynamic.config: |
      {
        "runtime": {
          "work_flow": {
            "limiter": {
              "max_bt_concurrent_flow": {{ $root.Values.agent.maxBtConcurrentFlow }},
              "max_cpu_percentage": {{ $root.Values.agent.maxCpuPercentage }},
              "max_memory_percentage": {{ $root.Values.agent.maxMemoryPercentage }},
              "max_cpu_upper_bound": {{ $root.Values.agent.maxCpuUpperBound }},
              "max_memory_upper_bound": {{ $root.Values.agent.maxMemoryUpperBound }},
              "overload_strategy": {{ $root.Values.agent.overloadStrategy}}
            }
          },
          "bittorrent": {
            "max_peer_connection": {{ $root.Values.agent.maxPeerConnection }}
          },
          "gc": {
            "expire_time": {{ $root.Values.agent.expireTime }},
            "detection_interval": {{ $root.Values.agent.detectionInterval }},
            "protection_time": {{ $root.Values.agent.protectionTime }},
            "max_files_num": {{ $root.Values.agent.maxFilesNum }},
            "disk_min_remain_ratio": {{ $root.Values.agent.diskMinRemainRatio }},
            "max_gc_num_when_disk_clear": {{ $root.Values.agent.maxGcNumWhenDiskClear }}
          }
        }
      }
{{- end -}}
