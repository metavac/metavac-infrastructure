{{- define "metavac-db.mongo.conf.mongos" -}}
storage:
  dbPath: {{ tpl .Values.global.db_dir . }}
systemLog:
  destination: file
  verbosity: 0
  traceAllExceptions: false
  logAppend: true
  logRotate: reopen
  timeStampFormat: iso8601-utc
  path: {{ tpl .Values.global.log_path . }}
sharding:
  configDB: metavac/
  {{- range $i, $_ := until (.Values.configsvr.replicas | int) }}
  {{- get $.Values.configsvr.podLabels "pod-name" }}-{{ $i }}.{{ $.Values.global.cluster_domain }}:27019
   {{- if not (eq $i (sub ($.Values.configsvr.replicas | int) 1)) }}
    {{- "," }}
   {{- end }}
  {{- end }}
net:
  bindIpAll: true
  unixDomainSocket:
    enabled: true
    pathPrefix: {{ tpl .Values.global.mount . }}/run
  tls:
    mode: requireTLS
    certificateKeyFile: {{ include "metavac-db.mongo.key_file_path" . }}
    #certificateKeyFilePassword: "" - TODO
    clusterFile: {{ include "metavac-db.mongo.key_file_path" . }}
    CAFile: {{ include "metavac-db.mongo.ca_cert_file_path" . }}
    clusterCAFile: {{ include "metavac-db.mongo.ca_cert_file_path" . }}
    allowInvalidCertificates: true
{{- end -}}