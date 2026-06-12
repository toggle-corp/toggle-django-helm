# MIGRATION — banjo-helm 0.3.x → 0.4.0

**Audience:** Claude (or a human) migrating a downstream `values.yaml` from `banjo-helm` 0.3.x to 0.4.0-devN.

**Format:** rename table → section-by-section before/after → behavioral changes → verification protocol.

---

## How to use this doc

1. Read the **rename table** below to spot every breaking key path change in the consumer's `values.yaml`.
2. For each section that changed, apply the **before / after** transformation literally.
3. Read **behavioral changes** for things that aren't just renames (replicaCount semantics, hook lifecycle, ttl defaults).
4. Run the **verification protocol** at the bottom — `helm template` against 0.3.x and 0.4.0, diff the raw output, confirm the diff matches the **expected diff** list.

If anything in the consumer's values.yaml doesn't match a row in this doc, **stop and ask** — the consumer may have a custom field this migration doesn't cover.

---

## Rename table

Every breaking path change in one table. Left → right.

| 0.3.x path | 0.4.0 path | Notes |
|---|---|---|
| `global.security.allowInsecureImages` | _(removed)_ | Bitnami-only; subcharts dropped. |
| `redis:` (whole block) | _(removed)_ | Use separate infrastructure chart. |
| `postgresql:` (whole block) | _(removed)_ | Use separate infrastructure chart. |
| `rabbitmq:` (whole block) | _(removed)_ | Use separate infrastructure chart. |
| `minio:` (whole block) | _(removed)_ | Use separate infrastructure chart. |
| `api.replicaCount: 1` | _(remove the default; set only if needed)_ | KEDA owns scaling. |
| `api.command: [...]` | `api.command: []` (or your entrypoint) | Default emptied. |
| `argoHook` | `hooks` | Top-level rename. |
| `argoHook.hooks` | `hooks.jobs` | |
| `argoHook.image` | `hooks.defaults.image` | |
| `argoHook.resources` | `hooks.defaults.resources` | |
| `argoHook.hooks.<X>.hook` | `hooks.jobs.<X>.annotations["argocd.argoproj.io/hook"]` | No shortcut; write the annotation. |
| `argoHook.hooks.<X>.preserveHistory` | `hooks.jobs.<X>.useGenerateName` | Renamed. |
| `argoHook.hooks.<X>.env` | `hooks.jobs.<X>.extraEnv` | Renamed. |
| `worker.beat` (block) | `worker.addons.beat` (entry) | Now an addon, not a first-class field. |
| `worker.flower` (block) | `worker.addons.flower` (entry, with `service: {enabled, port, targetPort}`) | Addon + optional service sub-block. |
| `worker.queueCommandPrefix` | `worker.queueDefaults.commandPrefix` | Moved into defaults block. |
| `worker.queueDefaultResources` | `worker.queueDefaults.resources` | Moved into defaults block. |
| `worker.queues.<X>.env` | `worker.queues.<X>.extraEnv` | Renamed. |
| `worker.queues.<X>.replicaCount` | _(remove unless you need a static count)_ | KEDA owns scaling. |
| `cronjobs.image` | `cronjobs.defaults.image` | Moved into defaults. |
| `cronjobs.defaultResources` | `cronjobs.defaults.resources` | Moved into defaults. |
| `cronjobs.jobs.<X>.env` | `cronjobs.jobs.<X>.extraEnv` | Renamed. |
| `ingress:` (whole block) | `api.ingress:` | Nested under api (its only consumer). Sub-keys unchanged. |
| `ingress.className` (required) | `api.ingress.className` (optional) | Drop unset to use the cluster's default IngressClass. |
| _(N/A)_ | `revisionHistoryLimit: 1` (top-level) | New chart-wide default; can override. |

The `django-app.*` → `banjo.*` rename is internal — it does not affect `values.yaml`, only template helpers.

---

## Section-by-section migration

### `api:`

**Before (0.3.x):**
```yaml
api:
  enabled: true
  replicaCount: 1
  containerPort: 80
  command: ["/code/deploy/run_prod.sh"]
  resources:
    requests:
      cpu: "2"
      memory: 0.5Gi
    limits:
      cpu: "2"
      memory: 1Gi
```

**After (0.4.0):**
```yaml
api:
  enabled: true
  # Drop replicaCount unless you need a static count (KEDA owns scaling).
  containerPort: 80
  command: ["/code/deploy/run_prod.sh"]   # keep your entrypoint
  # annotations: {}     # new; per-pod annotations
  # extraEnv: {}        # new; tpl-evaluated inline env
  resources:
    requests:
      cpu: "2"
      memory: 0.5Gi
    limits:
      # CPU limit dropped by chart convention; restore here if you really want it
      memory: 1Gi
```

---

### `ingress:` → `api.ingress:`

**Before (0.3.x):**
```yaml
ingress:
  enabled: true
  host: myapp.example.com
  className: nginx          # required — render failed if missing
  tls:
    enabled: true
    secretName: my-tls

api:
  enabled: true
  # ...
```

**After (0.4.0):**
```yaml
api:
  enabled: true
  # ...
  ingress:
    enabled: true
    host: myapp.example.com
    # className is now optional — omit to use the cluster's default IngressClass.
    # If your cluster has a single default IngressClass set, drop this line.
    className: nginx
    tls:
      enabled: true
      secretName: my-tls
```

Sub-keys (`enabled`, `host`, `className`, `tls.*`, `annotations`, `labels`) are unchanged — only the parent path moves.

---

### `worker:` — queues

**Before (0.3.x):**
```yaml
worker:
  enabled: true
  queueDefaultResources:
    requests: { cpu: "1", memory: 1Gi }
    limits:   { cpu: "1", memory: 2Gi }
  queueCommandPrefix: ["celery", "-A", "myapp", "worker", "-l", "INFO"]
  queues:
    default:
      enabled: true
      replicaCount: 1
      celeryArgs: ["-Q", "celery", "--concurrency", "4"]
      env:
        FOO: bar
      resources: {}
```

**After (0.4.0):**
```yaml
worker:
  enabled: true
  queueDefaults:
    commandPrefix: ["celery", "-A", "myapp", "worker", "-l", "INFO"]
    # extraEnv: {}
    # annotations: {}
    resources:
      requests: { cpu: "1", memory: 1Gi }
      limits:   { memory: 2Gi }     # NO CPU limit
  queues:
    default:
      enabled: true
      # replicaCount removed — KEDA scales. Add back if you need a static count.
      celeryArgs: ["-Q", "celery", "--concurrency", "4"]
      extraEnv:
        FOO: bar
      resources: {}
```

---

### `worker:` — beat and flower → addons

**Before (0.3.x):**
```yaml
worker:
  beat:
    enabled: true
    command: ["celery", "-A", "myapp", "beat", "-l", "INFO"]
    resources: { requests: { cpu: "1", memory: 0.5Gi }, limits: { cpu: "1", memory: 1Gi } }
  flower:
    enabled: true
    command: ["celery", "-A", "myapp", "flower", "--port=8000"]
    resources: { requests: { cpu: "0.1", memory: 0.5Gi }, limits: { cpu: "1", memory: 1Gi } }
```

**After (0.4.0):**
```yaml
worker:
  addonDefaults:
    resources:
      requests: { cpu: "50m", memory: "128Mi" }
      limits:   { memory: "256Mi" }
  addons:
    beat:
      enabled: true
      command: ["celery", "-A", "myapp", "beat", "-l", "INFO"]
      replicaCount: 1                       # beat MUST be singleton
      resources:
        requests: { cpu: "1", memory: 0.5Gi }
        limits:   { memory: 1Gi }
    flower:
      enabled: true
      command: ["celery", "-A", "myapp", "flower", "--port=8000"]
      service:
        enabled: true                       # creates ClusterIP Service
        port: 80
        targetPort: 8000
      resources:
        requests: { cpu: "0.1", memory: 0.5Gi }
        limits:   { memory: 1Gi }
```

For a celery-exporter or any new auxiliary process: just add another entry under `addons:`. No chart change needed.

---

### `cronjobs:`

**Before (0.3.x):**
```yaml
cronjobs:
  enabled: true
  image:
    name: ghcr.io/example/cronjob
    tag: v1
  defaultResources:
    requests: { cpu: "1", memory: 1Gi }
    limits:   { cpu: "1", memory: 2Gi }
  jobs:
    dummy:
      enabled: true
      schedule: "0 0 * * *"
      command: ["./manage.py", "run-dummy"]
      env:
        FOO: bar
```

**After (0.4.0):**
```yaml
cronjobs:
  enabled: true
  defaults:
    image:
      name: ghcr.io/example/cronjob
      tag: v1
    successfulJobsHistoryLimit: 1           # new (k8s default is 3)
    failedJobsHistoryLimit: 1               # new
    resources:
      requests: { cpu: "1", memory: 1Gi }
      limits:   { memory: 2Gi }             # NO CPU limit
  jobs:
    dummy:
      enabled: true
      schedule: "0 0 * * *"
      command: ["./manage.py", "run-dummy"]
      extraEnv:
        FOO: bar
      # successfulJobsHistoryLimit: 3       # optional per-job override
      # failedJobsHistoryLimit: 2
```

---

### `argoHook:` → `hooks:`

**Before (0.3.x):**
```yaml
argoHook:
  enabled: true
  image: {...}
  resources: {...}
  hooks:
    db-migrate:
      enabled: true
      hook: PostSync
      preserveHistory: true
      command: ["./manage.py", "migrate"]
    collect-static:
      enabled: true
      hook: PostSync
      command: ["./manage.py", "collectstatic", "--noinput"]
```

**After (0.4.0):**
```yaml
hooks:
  enabled: true
  defaults:
    image: {...}                            # was argoHook.image
    resources: {...}                        # was argoHook.resources
  jobs:                                     # was argoHook.hooks
    # The chart already seeds db-migrate, collect-static, and wait-for-resources.
    # Consumers usually inherit these and only add/override what they need.
    db-migrate:
      enabled: true
      useGenerateName: true                 # was preserveHistory
      activeDeadlineSeconds: 3600
      ttlSecondsAfterFinished: 604800       # 7 days; k8s-native cleanup
      annotations:
        argocd.argoproj.io/hook: "PostSync"
        argocd.argoproj.io/sync-wave: "20"
        # NO hook-delete-policy — inert with generateName. See behavioral notes.
      command: ["./manage.py", "migrate"]
    collect-static:
      enabled: true
      annotations:
        argocd.argoproj.io/hook: "PostSync"
        argocd.argoproj.io/sync-wave: "20"
        argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
      command: ["./manage.py", "collectstatic", "--noinput"]
```

**For Helm-only consumers (not ArgoCD):** the same `hooks.jobs.<X>.annotations` block works. Substitute the annotation namespace:
```yaml
annotations:
  helm.sh/hook: post-install,post-upgrade
  helm.sh/hook-weight: "0"
  helm.sh/hook-delete-policy: before-hook-creation
```

---

### Subcharts: removed

**Before (0.3.x):**
```yaml
redis:    {enabled: true, ...}
postgresql: {enabled: true, ...}
rabbitmq: {enabled: true, ...}
minio:    {enabled: true, ...}
secrets:
  POSTGRES_HOST: "{{ include \"postgresql.v1.primary.fullname\" $.Subcharts.postgresql }}"
```

**After (0.4.0):** delete all four blocks. Rewrite `secrets:` using plain references — the consumer is expected to provision Redis/Postgres/RabbitMQ/Minio via a separate infrastructure chart or external service.

```yaml
secrets:
  POSTGRES_HOST: "my-app-postgres"          # plain hostname from your infra chart
  POSTGRES_DB: "my-app"
  POSTGRES_USER: "postgres"
  # POSTGRES_PASSWORD comes from an ExternalSecret or extraSecretsName
  REDIS_URL: "redis://my-app-redis-master:6379/0"
```

---

## Behavioral changes (not just renames)

### 1. `replicaCount` removal semantics

In 0.3.x, `api.replicaCount: 1` was the chart default. The template always rendered `spec.replicas: 1`, which ArgoCD would set on every sync — fighting KEDA's autoscaler.

In 0.4.0, the api template is nil-guarded. If `api.replicaCount` is absent, `spec.replicas` is omitted from the rendered Deployment. K8s defaults to 1, and KEDA can own the value at runtime without ArgoCD reverting it.

**Migration:** delete `api.replicaCount` and `worker.queues.<X>.replicaCount` unless you specifically want a static count or are temporarily bumping for a load surge.

### 2. db-migrate hook lifecycle correction (THIS IS A REAL BUG FIX)

The 0.3.x chart's `db-migrate` hook shipped with both:
- `metadata.generateName` (via `preserveHistory: true`)
- `argocd.argoproj.io/hook-delete-policy: BeforeHookCreation`

This combination is **inert**. Per ArgoCD docs, `BeforeHookCreation` does name-based lookup. With `generateName`, every Job gets a unique name, so the lookup never matches, so nothing gets deleted. Jobs accumulate forever ([argoproj/argo-cd#4295](https://github.com/argoproj/argo-cd/issues/4295)).

The 0.4.0 chart fixes this by:
- Dropping the misleading annotation (the regression test in `chart/tests/hooks/job_test.yaml` asserts it stays absent)
- Adding `spec.ttlSecondsAfterFinished: 604800` (7 days) — k8s-native cleanup, independent of ArgoCD

**Migration:** the chart's seeded `db-migrate` already has the correct shape. Don't add `argocd.argoproj.io/hook-delete-policy` back to db-migrate. If you want different retention, change `ttlSecondsAfterFinished`.

### 3. CPU limits removed from defaults

CFS quota-based CPU throttling causes p99 latency spikes without preventing harm — `requests` already provides scheduling fairness. The 0.4.0 chart ships requests + memory-limit-only defaults.

**Migration:** if you actively want CPU limits on your workloads, add them back per-component:
```yaml
api:
  resources:
    limits:
      cpu: "2"        # restore explicit limit
      memory: "1Gi"
```

### 4. Sync-wave ordering (new)

Seeded hooks now have explicit sync-waves to give consumers room to inject custom hooks between them:

- `wait-for-resources`: wave 10 (runs first; opt-in)
- `db-migrate`: wave 20
- `collect-static`: wave 20 (runs in parallel with db-migrate; collectstatic is independent of DB)

Custom hooks should use wave numbers with gaps (e.g., 15, 25) so future chart-shipped hooks don't collide.

### 5. `extraEnvVars` dict-or-array (new)

If you used `extraEnvVars: [{name: X, valueFrom: {...}}]` (array form), it still works unchanged. The dict form (keyed by env-var name) is now also supported:

```yaml
extraEnvVars:
  MY_KEY:
    valueFrom:
      secretKeyRef: { name: my-secret, key: my-key }
```

Dict form merges via `-f`; array form replaces wholesale.

The same dict-or-array pattern applies to `worker.queues`, `worker.addons`, `cronjobs.jobs`, and `hooks.jobs`.

### 6. `api.ingress.className` is now optional

In 0.3.x, `ingress.className` was wrapped with Helm's `required` — `helm template` failed loudly when missing. In 0.4.0, the template uses `{{- with .Values.api.ingress.className }}`: if unset (or empty string), `spec.ingressClassName` is omitted from the rendered Ingress entirely.

Kubernetes then routes the Ingress to the cluster's **default IngressClass** (the IngressClass resource annotated `ingressclass.kubernetes.io/is-default-class: "true"`).

**Migration:**
- If your target clusters have a single default IngressClass set, you can drop `className` from your values.yaml.
- If they don't, **keep `className` explicit** — otherwise the Ingress will be created without a controller and traffic will silently not route. The chart no longer warns about this; it's a cluster-side contract.
- `className: ""` is treated the same as unset (both fall into the `with` block's falsy branch).

---

## Verification protocol

Run this **before and after** the migration to prove the diff matches the expected changes.

```bash
# 1. Capture the rendered manifests under 0.3.x (assuming your old chart + values are still checked in)
helm template <release> <old-chart-path> -f <old-values.yaml> > /tmp/before.yaml

# 2. Apply the migration to <old-values.yaml> per this guide

# 3. Render with the 0.4.0 chart
helm template <release> <new-chart-path> -f <new-values.yaml> > /tmp/after.yaml

# 4. Diff
diff /tmp/before.yaml /tmp/after.yaml | less
```

### Expected diff (these changes SHOULD appear)

- `spec.revisionHistoryLimit: 1` on every Deployment.
- `argocd.argoproj.io/sync-wave: "10"|"20"` annotations on hook Jobs.
- `spec.ttlSecondsAfterFinished: 604800` on the db-migrate Job.
- `spec.activeDeadlineSeconds: 3600` on the db-migrate Job.
- **Absent**: `argocd.argoproj.io/hook-delete-policy` annotation on the db-migrate Job (regression guard).
- **Absent**: `spec.replicas:` on api and worker-queue Deployments (unless replicaCount was explicitly kept).
- **Absent**: `resources.limits.cpu` on Deployments using chart defaults (unless explicitly restored).
- **Absent**: `spec.ingressClassName` on the Ingress, if `api.ingress.className` was dropped to rely on the cluster default.
- Image refs and labels using `banjo-helm-*` naming (was `django-app-*`).
- The hook Job's `metadata.annotations` block now contains everything from `hooks.jobs.<X>.annotations` verbatim.

### Suspicious diff (investigate if you see these)

- Pod images changed unintentionally (a `worker.image` or `cronjobs.image` migration was wrong).
- ConfigMap/Secret data changed unexpectedly (an env-var rename was applied to the wrong key).
- Fewer Deployments than expected (a queue or addon was lost; check if `worker.queues.default.enabled: true` was preserved).
- Hook Jobs use `metadata.name` when they should use `metadata.generateName` (or vice versa) — `useGenerateName` migration failed.
- Worker-beat or celery-flower Deployments still present with old labels — the migration to `worker.addons` was missed.

### CI gate

After migrating, run the chart's helm-unittest suite to catch shape errors. Existing snapshots may need regeneration if the chart was extended downstream:

```bash
helm unittest <new-chart-path> -f "tests/**/*_test.yaml"
```

---

## Versioning

This is a `0.4.0-devN` release — pre-stable. Iterate dev tags on a real cluster against downstream apps until no `-devN` cycle introduces a change in two consecutive dogfooding rounds, then cut `0.4.0` (no suffix).
