{{/*
Expand the name of the chart.
*/}}
{{- define "ldap-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ldap-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ldap-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ldap-stack.labels" -}}
helm.sh/chart: {{ include "ldap-stack.chart" . }}
{{ include "ldap-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ldap-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ldap-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
OpenLDAP specific helpers
*/}}
{{- define "ldap-stack.openldap.fullname" -}}
{{- printf "%s-openldap" (include "ldap-stack.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ldap-stack.openldap.labels" -}}
{{ include "ldap-stack.labels" . }}
app.kubernetes.io/component: openldap
{{- end }}

{{- define "ldap-stack.openldap.selectorLabels" -}}
{{ include "ldap-stack.selectorLabels" . }}
app.kubernetes.io/component: openldap
{{- end }}

{{/*
Generate LDAP Base DN from domain
Example: mycompany.com -> dc=mycompany,dc=com
*/}}
{{- define "ldap-stack.openldap.baseDN" -}}
{{- $domain := required "openldap.config.domain is required" .Values.openldap.config.domain -}}
{{- $parts := splitList "." $domain -}}
{{- $dn := list -}}
{{- range $parts -}}
{{- $dn = append $dn (printf "dc=%s" .) -}}
{{- end -}}
{{- join "," $dn -}}
{{- end }}

{{/*
Generate LDAP Admin DN
*/}}
{{- define "ldap-stack.openldap.adminDN" -}}
cn=admin,{{ include "ldap-stack.openldap.baseDN" . }}
{{- end }}

{{/*
Generate LDAP URL for internal use
*/}}
{{- define "ldap-stack.openldap.url" -}}
ldap://{{ include "ldap-stack.openldap.fullname" . }}:{{ .Values.openldap.service.ldapPort }}
{{- end }}

{{/*
phpLDAPadmin specific helpers
*/}}
{{- define "ldap-stack.phpldapadmin.fullname" -}}
{{- printf "%s-phpldapadmin" (include "ldap-stack.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ldap-stack.phpldapadmin.labels" -}}
{{ include "ldap-stack.labels" . }}
app.kubernetes.io/component: phpldapadmin
{{- end }}

{{- define "ldap-stack.phpldapadmin.selectorLabels" -}}
{{ include "ldap-stack.selectorLabels" . }}
app.kubernetes.io/component: phpldapadmin
{{- end }}

{{/*
Keycloak specific helpers
*/}}
{{- define "ldap-stack.keycloak.fullname" -}}
{{- printf "%s-keycloak" (include "ldap-stack.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ldap-stack.keycloak.labels" -}}
{{ include "ldap-stack.labels" . }}
app.kubernetes.io/component: keycloak
{{- end }}

{{- define "ldap-stack.keycloak.selectorLabels" -}}
{{ include "ldap-stack.selectorLabels" . }}
app.kubernetes.io/component: keycloak
{{- end }}

{{/*
Secret name for OpenLDAP credentials
*/}}
{{- define "ldap-stack.openldap.secretName" -}}
{{- printf "%s-openldap-credentials" (include "ldap-stack.fullname" .) }}
{{- end }}

{{/*
Secret name for Keycloak credentials
*/}}
{{- define "ldap-stack.keycloak.secretName" -}}
{{- printf "%s-keycloak-credentials" (include "ldap-stack.fullname" .) }}
{{- end }}

{{/*
Storage class
*/}}
{{- define "ldap-stack.storageClass" -}}
{{- if .Values.global.storageClass -}}
storageClassName: {{ .Values.global.storageClass }}
{{- end -}}
{{- end }}
