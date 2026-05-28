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
  {{- fail "agent.reuseContainerdContentStore=true 仅支持 trackerType=ntracker，请修改 agent.trackerType" -}}
{{- end -}}
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
{{ toYaml $root.Values.tolerations.agent | indent 8 }}
      affinity:
        {{- $effectiveRole := $roleName | default $root.Values.global.deployMode -}}
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
    metrics:
      enable_layer_p2p_metrics: {{ $root.Values.agent.enableLayerP2PMetrics }}
    pprof:
      path: "/app/agent/pprof"
      interval: 120
      max_record_time: 172800
    registry:
      username: {{ $root.Values.agent.registryAuth.username | quote }}
      password: {{ $root.Values.agent.registryAuth.password | quote }}
    watcher:
      watcher_url: "{{ $root.Values.agent.watcherUrl }}"
      watcher_heartbeat_interval: {{ $root.Values.agent.heartbeatInterval }}
      watcher_heartbeat_timeout: {{ $root.Values.agent.heartbeatTimeout }}
      watcher_max_failed_heartbeats: {{ $root.Values.agent.maxFailedHeartbeats }}
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
      gc:
        expire_time: {{ $root.Values.agent.expireTime }}
        detection_interval: {{ $root.Values.agent.detectionInterval }}
        protection_time: {{ $root.Values.agent.protectionTime }}
        max_files_num: {{ $root.Values.agent.maxFilesNum }}
        disk_min_remain_ratio: {{ $root.Values.agent.diskMinRemainRatio }}
        max_gc_num_when_disk_clear: {{ $root.Values.agent.maxGcNumWhenDiskClear }}
      update_check_interval: {{ $root.Values.agent.configCheckInterval }}
{{- end -}}
