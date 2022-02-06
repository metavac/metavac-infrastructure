{{- define "metavac-db.mongo.bootstrap.mongos" -}}

{{ $servers := list }}
{{- range $i, $_ := until (.Values.mongos.replicas | int) }}
    {{- append $servers (cat (get $.Values.mongos.podLabels "pod-name") $i ".cluster.local:27018" | nospace) }}
{{- end }}

sh.addShard("metavac/{{- range $j, $val := until $servers }}{{ $val }}{{- end }}")
sh.enableSharding({{ .Values.db.name }})

{{- end -}}