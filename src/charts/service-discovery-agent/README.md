# service-discovery-agent

Helm chart that provisions the ServiceAccount and RBAC required by the Harness
service discovery agent when the agent is configured to run with a custom
(pre-provisioned) service account.

When `kubernetes.serviceAccount` is set on the agent configuration, the
server-side manifest skips creating the ServiceAccount, ClusterRole,
ClusterRoleBinding, Role and RoleBinding — they must exist before the agent is
installed. This chart creates exactly those resources.

## What it renders

- `Namespace` (optional, `namespace.create=true`)
- `ServiceAccount` (`serviceAccount.create=true`, or reference an existing one
  via `serviceAccount.name`)
- `ClusterRole` `<fullname>-view` — read-only discovery permissions
  (get/list/watch on workloads, pods, services, nodes, namespaces, jobs,
  HPAs, ingresses, istio resources)
- `ClusterRoleBinding` `<fullname>-view` — only when `discovery.scope=cluster`
- `RoleBinding` `<fullname>-view` in each of `discovery.namespaces` — only when
  `discovery.scope=namespaced`; binds the same ClusterRole with
  namespace-scoped effect
- `Role` `<fullname>-mgmt` — write permissions in the agent namespace
  (pods/secrets/configmaps/deployments management, pods/log read)
- `RoleBinding` `<fullname>-mgmt` — binds the mgmt Role to the service account

## Usage

Cluster-wide discovery:

```sh
helm install sd-agent-rbac ./chart/service-discovery-agent \
  --namespace discovery-agent \
  --set namespace.create=true \
  --set serviceAccount.name=discovery-agent
```

Multi-namespace discovery (no cluster-wide grants):

```sh
helm install sd-agent-rbac ./chart/service-discovery-agent \
  --namespace discovery-agent \
  --set namespace.create=true \
  --set serviceAccount.name=discovery-agent \
  --set discovery.scope=namespaced \
  --set 'discovery.namespaces={team-a,team-b}'
```

Bring your own service account:

```sh
helm install sd-agent-rbac ./chart/service-discovery-agent \
  --namespace discovery-agent \
  --set serviceAccount.create=false \
  --set serviceAccount.name=my-existing-sa
```

Then set the same name on the agent so the server manifest uses it:

```yaml
kubernetes:
  namespace: discovery-agent
  serviceAccount: discovery-agent
  disableNamespaceCreation: true   # when the chart owns the namespace
```

## Values

| Key | Default | Description |
|-----|---------|-------------|
| `agentNamespace` | release namespace | namespace the agent runs in |
| `namespace.create` | `false` | create the agent namespace |
| `serviceAccount.create` | `true` | create the service account |
| `serviceAccount.name` | release fullname | SA name; must match agent `kubernetes.serviceAccount` |
| `discovery.scope` | `cluster` | `cluster` or `namespaced` |
| `discovery.namespaces` | `[]` | target namespaces for namespaced scope |
| `rbac.extraClusterRoleRules` | `[]` | extra rules on the view ClusterRole |
| `rbac.extraRoleRules` | `[]` | extra rules on the mgmt Role |
| `commonLabels` / `commonAnnotations` | `{}` | applied to all resources |
