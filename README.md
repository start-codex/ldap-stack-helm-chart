# LDAP Stack Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/ldap-stack)](https://artifacthub.io/packages/helm/ldap-stack/ldap-stack)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

OpenLDAP + phpLDAPadmin + Keycloak stack for centralized identity management on Kubernetes.

## Features

- **OpenLDAP 2.6.x** - Directory service with `startcodex/openldap` image
- **phpLDAPadmin** - Web-based LDAP administration
- **Keycloak** - Identity Provider with SSO (OAuth2, OIDC, SAML)
- **LDAP Federation** - Auto-configure Keycloak to use LDAP as user store
- **Bootstrap** - Automatic creation of OUs (users, groups, services)
- **Production Ready** - NetworkPolicy, PodDisruptionBudget, ServiceMonitor
- **Flexible Services** - ClusterIP, NodePort, LoadBalancer support

## Quick Start

```bash
# Add repository
helm repo add ldap-stack https://start-codex.github.io/ldap-stack-helm-chart
helm repo update

# Install
helm install my-ldap ldap-stack/ldap-stack \
  --set openldap.config.organisation="My Company" \
  --set openldap.config.domain="mycompany.com" \
  --set openldap.config.adminPassword="secure-password" \
  --set keycloak.admin.username="admin" \
  --set keycloak.admin.password="secure-password"
```

## Installation Examples

### Basic Installation

```bash
helm install ldap ldap-stack/ldap-stack \
  --namespace identity --create-namespace \
  --set openldap.config.organisation="ACME Corp" \
  --set openldap.config.domain="acme.com" \
  --set openldap.config.adminPassword="ldap-secret" \
  --set keycloak.admin.username="admin" \
  --set keycloak.admin.password="keycloak-secret"
```

### With LDAP Bootstrap (Auto-create OUs)

```bash
helm install ldap ldap-stack/ldap-stack \
  --set openldap.config.organisation="ACME Corp" \
  --set openldap.config.domain="acme.com" \
  --set openldap.config.adminPassword="ldap-secret" \
  --set openldap.bootstrap.enabled=true \
  --set openldap.bootstrap.createDefaultOUs=true \
  --set keycloak.admin.username="admin" \
  --set keycloak.admin.password="keycloak-secret"
```

### With Auto LDAP Federation in Keycloak

```bash
helm install ldap ldap-stack/ldap-stack \
  --set openldap.config.organisation="ACME Corp" \
  --set openldap.config.domain="acme.com" \
  --set openldap.config.adminPassword="ldap-secret" \
  --set keycloak.admin.username="admin" \
  --set keycloak.admin.password="keycloak-secret" \
  --set keycloak.realm.import.enabled=true \
  --set ldapFederation.enabled=true
```

### Production Deployment

```bash
helm install ldap ldap-stack/ldap-stack \
  --set openldap.config.organisation="ACME Corp" \
  --set openldap.config.domain="acme.com" \
  --set openldap.config.adminPassword="ldap-secret" \
  --set keycloak.admin.username="admin" \
  --set keycloak.admin.password="keycloak-secret" \
  --set keycloak.devMode=false \
  --set keycloak.production.hostname="auth.acme.com" \
  --set keycloak.production.database.host="postgres.database.svc" \
  --set keycloak.production.database.password="db-secret" \
  --set networkPolicy.enabled=true \
  --set podDisruptionBudget.enabled=true \
  --set metrics.serviceMonitor.enabled=true
```

## Configuration

### Required Parameters

| Parameter | Description |
|-----------|-------------|
| `openldap.config.organisation` | Organization name |
| `openldap.config.domain` | LDAP domain (e.g., `mycompany.com`) |
| `openldap.config.adminPassword` | LDAP admin password |
| `keycloak.admin.username` | Keycloak admin username |
| `keycloak.admin.password` | Keycloak admin password |

### OpenLDAP Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `openldap.enabled` | Enable OpenLDAP | `true` |
| `openldap.image.repository` | Image repository | `startcodex/openldap` |
| `openldap.image.tag` | Image tag | `2.0.0` |
| `openldap.service.type` | Service type | `ClusterIP` |
| `openldap.service.ldapPort` | LDAP port | `389` |
| `openldap.service.ldapsPort` | LDAPS port | `636` |
| `openldap.persistence.enabled` | Enable persistence | `true` |
| `openldap.persistence.data.size` | Data PVC size | `1Gi` |
| `openldap.bootstrap.enabled` | Enable bootstrap | `false` |
| `openldap.bootstrap.createDefaultOUs` | Create default OUs | `true` |

### phpLDAPadmin Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `phpldapadmin.enabled` | Enable phpLDAPadmin | `true` |
| `phpldapadmin.service.type` | Service type | `ClusterIP` |
| `phpldapadmin.service.port` | Service port | `80` |
| `phpldapadmin.ingress.enabled` | Enable Ingress | `false` |

### Keycloak Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `keycloak.enabled` | Enable Keycloak | `true` |
| `keycloak.devMode` | Run in dev mode | `true` |
| `keycloak.service.type` | Service type | `ClusterIP` |
| `keycloak.service.port` | Service port | `8080` |
| `keycloak.ingress.enabled` | Enable Ingress | `false` |
| `keycloak.realm.import.enabled` | Enable realm import | `false` |
| `keycloak.realm.import.realmJson` | Inline realm JSON | `""` |

### LDAP Federation Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ldapFederation.enabled` | Auto-configure LDAP federation | `false` |
| `ldapFederation.realmName` | Realm name | `master` |
| `ldapFederation.editMode` | Edit mode | `WRITABLE` |

### Production Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `networkPolicy.enabled` | Enable NetworkPolicies | `false` |
| `podDisruptionBudget.enabled` | Enable PDB | `false` |
| `podDisruptionBudget.maxUnavailable` | Max unavailable pods | `1` |
| `metrics.serviceMonitor.enabled` | Enable ServiceMonitor | `false` |

## Accessing Services

### Port Forwarding (Development)

```bash
# phpLDAPadmin
kubectl port-forward svc/<release>-phpldapadmin 8080:80

# Keycloak
kubectl port-forward svc/<release>-keycloak 8081:8080

# OpenLDAP
kubectl port-forward svc/<release>-openldap 389:389
```

### NodePort

```yaml
keycloak:
  service:
    type: NodePort
    nodePort: 30808

phpldapadmin:
  service:
    type: NodePort
    nodePort: 30080
```

### LoadBalancer

```yaml
keycloak:
  service:
    type: LoadBalancer
    loadBalancerIP: "10.0.0.100"
```

### Ingress

```yaml
keycloak:
  ingress:
    enabled: true
    className: nginx
    hosts:
      - host: auth.mycompany.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: keycloak-tls
        hosts:
          - auth.mycompany.com
```

## LDAP Federation in Keycloak

### Automatic Configuration

Enable auto-configuration:

```yaml
keycloak:
  realm:
    import:
      enabled: true

ldapFederation:
  enabled: true
  editMode: "WRITABLE"
```

### Manual Configuration

1. Access Keycloak Admin Console
2. Go to **User Federation** > **Add provider** > **LDAP**
3. Configure:

| Setting | Value |
|---------|-------|
| Connection URL | `ldap://<release>-openldap:389` |
| Bind DN | `cn=admin,dc=<domain>` |
| Users DN | `ou=users,dc=<domain>` |
| Username LDAP attribute | `uid` |
| RDN LDAP attribute | `uid` |
| UUID LDAP attribute | `entryUUID` |
| User object classes | `inetOrgPerson, posixAccount` |

## Production Deployment

### External Database for Keycloak

```yaml
keycloak:
  devMode: false
  production:
    hostname: "auth.mycompany.com"
    database:
      vendor: postgres
      host: "postgres.database.svc"
      port: 5432
      database: keycloak
      username: keycloak
      password: "db-password"
```

### Network Policies

```yaml
networkPolicy:
  enabled: true
  openldap:
    allowFromNamespaces:
      - sonarqube
      - gitea
  keycloak:
    ingressNamespace: "ingress-nginx"
    allowFromNamespaces:
      - default
```

### Prometheus Metrics

```yaml
metrics:
  serviceMonitor:
    enabled: true
    labels:
      release: prometheus
    interval: "30s"
```

## Troubleshooting

### Check pod status

```bash
kubectl get pods -n <namespace>
kubectl logs -f <pod-name>
```

### Test LDAP connection

```bash
kubectl exec -it <openldap-pod> -- ldapsearch -x -H ldap://localhost:389 \
  -b "dc=mycompany,dc=com" \
  -D "cn=admin,dc=mycompany,dc=com" \
  -w <password>
```

### Get secrets

```bash
# OpenLDAP admin password
kubectl get secret <release>-openldap-credentials -o jsonpath="{.data.admin-password}" | base64 -d

# Keycloak admin password
kubectl get secret <release>-keycloak-credentials -o jsonpath="{.data.admin-password}" | base64 -d
```

## Uninstallation

```bash
helm uninstall <release> -n <namespace>

# Remove PVCs
kubectl delete pvc -l app.kubernetes.io/instance=<release> -n <namespace>
```

## License

Apache License 2.0

## Links

- [GitHub Repository](https://github.com/start-codex/ldap-stack-helm-chart)
- [Artifact Hub](https://artifacthub.io/packages/helm/ldap-stack/ldap-stack)
- [OpenLDAP Official](https://www.openldap.org/)
- [Keycloak Official](https://www.keycloak.org/)
