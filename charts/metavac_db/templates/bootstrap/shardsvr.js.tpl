{{- define "metavac-db.mongo.bootstrap.shardsvr.js" -}}
{{- $servers := list -}}
{{- $shardsvr := (get .Values "mongodb-sharded").shardsvr -}}
{{- range $i, $_ := until ($shardsvr.replicas | int) -}}
    {{- $servers = append $servers (cat (get $shardsvr.podLabels "pod-name") "-" $i ".cluster.local:27018" | nospace) -}}
{{- end -}}

return 0;

rs.initiate(
    {
        _id: "metavac",
        members: [
            {{- range $j, $server := $servers }}
            { _id: {{ $j }}, host: {{ $server }} },
            {{- end }}
        ]
    }
);
{{- end -}}

{{- define "metavac-db.mongo.bootstrap.volume_mounts.shardsvr" -}}
- name: {{ include "metavac-db.fullname" . }}-shardsvr-bootstrap-vol
  mountPath: /docker-entrypoint-initdb.d/bootstrap
{{- end -}}

{{- define "metavac-db.mongo.bootstrap.volumes.shardsvr" -}}
- name: {{ include "metavac-db.fullname" . }}-shardsvr-bootstrap-vol
  configMap:
    name: {{ include "metavac-db.fullname" . }}-shardsvr-bootstrap
    defaultMode: 0755
{{- end -}}


{{- define "metavac-db.mongo.bootstrap.shardsvr.configmap" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "metavac-db.fullname" . }}-shardsvr-bootstrap
  namespace: {{ include "metavac-db.namespace" . }}
data:
  bootstrap-shardsvr.js: |
    {{- printf "\n" }}
    {{- include "metavac-db.mongo.bootstrap.shardsvr.js" . | indent 4 }}
{{- end }}

{{ include "metavac-db.mongo.bootstrap.shardsvr.configmap" . }}