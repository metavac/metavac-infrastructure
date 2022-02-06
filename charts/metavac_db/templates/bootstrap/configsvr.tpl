{{- define "metavac-db.mongo.bootstrap.configsvr.js" -}}
{{- $servers := list -}}
{{- $configsvr := (get .Values "mongodb-sharded").configsvr -}}
{{- range $i, $_ := until ($configsvr.replicas | int) -}}
    {{- $servers = append $servers (cat (get $configsvr.podLabels "pod-name") "-" $i ".cluster.local:27019" | nospace) -}}
{{- end -}}

return 0;

rs.initiate(
    {
        _id: "metavac",
        configsvr: true,
        members: [
            {{- range $j, $server := $servers }}
            { _id: {{ $j }}, host: {{ $server }} },
            {{- end }}
        ]
    }
);
{{- end -}}

{{- define "metavac-db.mongo.bootstrap.volume_mounts.configsvr" -}}
- name: {{ include "metavac-db.fullname" . }}-configsvr-bootstrap-vol
  mountPath: /docker-entrypoint-initdb.d/bootstrap
{{- end -}}

{{- define "metavac-db.mongo.bootstrap.volumes.configsvr" -}}
- name: {{ include "metavac-db.fullname" . }}-configsvr-bootstrap-vol
  configMap:
    name: {{ include "metavac-db.fullname" . }}-configsvr-bootstrap
    defaultMode: 0755
{{- end -}}


{{- define "metavac-db.mongo.bootstrap.configsvr.configmap" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "metavac-db.fullname" . }}-configsvr-bootstrap
  namespace: {{ include "metavac-db.namespace" . }}
data:
  bootstrap-configsvr.js: |
    {{- printf "\n" }}
    {{- include "metavac-db.mongo.bootstrap.configsvr.js" . | indent 4 }}
{{- end }}

{{ include "metavac-db.mongo.bootstrap.configsvr.configmap" . }}