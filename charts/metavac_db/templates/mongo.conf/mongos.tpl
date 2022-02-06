{{- define "metavac-db.mongo.conf.mongos" -}}
storage:
   dbPath: {{ .Values.global.mongoMount }}
systemLog:
   destination: file
   path: {{ tpl .Values.global.logDir . }}
   logAppend: true
storage:
   journal:
      enabled: true
sharding:
  configDB: metavac/
  {{- range $i, $_ := until (.Values.configsvr.replicas | int) }}
  {{- get $.Values.configsvr.podLabels "pod-name" }}-{{ $i }}.cluster.local:27019
   {{- if not (eq $i (sub ($.Values.configsvr.replicas | int) 1)) }}
    {{- "," }}
   {{- end }}
  {{- end }}
net:
  bindIp: 0.0.0.0,/tmp/mongod.sock
  tls:
    mode: requireTLS
    certificateKeyFile: {{  include "metavac-db.mongo.key_file_path" . }}
    CAFile: {{ include "metavac-db.mongo.ca_cert_file_path" . }}
{{- end -}}