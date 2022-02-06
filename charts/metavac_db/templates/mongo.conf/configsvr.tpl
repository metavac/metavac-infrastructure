{{- define "metavac-db.mongo.conf.configsvr" -}}
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
  clusterRole: configsvr
replication:
  replSetName: metavac
net:
  bindIp: 0.0.0.0,/tmp/mongod.sock
{{- end -}}