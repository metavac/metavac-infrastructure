{{- define "metavac-db.mongo.bootstrap.mongos.js" -}}
{{- $servers := list -}}
{{- $shardsvr := (get .Values "mongodb-sharded").shardsvr -}}
{{- $replicas := int (sub ($shardsvr.replicas | int) 1) -}}
{{- range $i, $_ := until ($shardsvr.replicas | int) -}}
    {{- $servers = append $servers (cat (get $shardsvr.podLabels "pod-name") "-" $i ".cluster.local:27018" | nospace) -}}
{{- end -}}

return 0;

sh.addShard("metavac/{{- range $j, $val := $servers }}{{- $val }}{{- not (eq $j $replicas) | ternary "," "" }}{{- end }}")
sh.enableSharding("{{ .Values.db.name }}")
{{- end -}}

{{- define "metavac-db.mongo.bootstrap.volume_mounts.mongos" -}}
- name: {{ include "metavac-db.fullname" . }}-mongos-bootstrap-vol
  mountPath: /docker-entrypoint-initdb.d/bootstrap
{{- end -}}

{{- define "metavac-db.mongo.bootstrap.volumes.mongos" -}}
- name: {{ include "metavac-db.fullname" . }}-mongos-bootstrap-vol
  configMap:
    name: {{ include "metavac-db.fullname" . }}-mongos-bootstrap
    defaultMode: 0755
{{- end -}}


{{- define "metavac-db.mongo.bootstrap.mongos.configmap" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "metavac-db.fullname" . }}-mongos-bootstrap
  namespace: {{ include "metavac-db.namespace" . }}
data:
  bootstrap-mongos.js: |
    {{- printf "\n" }}
    {{- include "metavac-db.mongo.bootstrap.mongos.js" . | indent 4 }}
{{- end }}

{{ include "metavac-db.mongo.bootstrap.mongos.configmap" . }}