{{- define "metavac-db.mongo.conf.shardsvr" -}}
storage:
   dbPath: {{ tpl .Values.global.db_dir . }}
   directoryPerDB: true
   journal:
      enabled: true
systemLog:
  destination: file
  verbosity: 0
  traceAllExceptions: false
  logAppend: true
  logRotate: reopen
  timeStampFormat: iso8601-utc
  path: {{ tpl .Values.global.log_path . }}
sharding:
    clusterRole: shardsvr
replication:
    replSetName: metavac
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