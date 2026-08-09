# banjo-helm

Helm chart for deploying a Django application: an API Deployment, Celery worker
queues and addons, scheduled CronJobs, and migration/bootstrap hook Jobs — with
an ArgoCD sync-wave contract wired in by default.

Requires **Kubernetes ≥ 1.30** (the chart uses the native `lifecycle.preStop.sleep`
action, GA in 1.30).

## Install

The chart is published as an OCI artifact to GHCR:

```bash
helm install <release> oci://ghcr.io/toggle-corp/banjo-helm --version <version> -f values.yaml
```

Minimum viable `values.yaml` — everything else has a default:

```yaml
image:
  name: ghcr.io/your-org/your-app
  tag: v1.0.0

api:
  command: ["/code/deploy/run_prod.sh"]   # your entrypoint

env:
  DJANGO_SETTINGS_MODULE: myapp.settings

secrets:
  SECRET_KEY: "..."
```

Migrating from an older chart version? See [MIGRATION.md](MIGRATION.md).

## What it renders

| Component | Values key | Renders |
|---|---|---|
| API | `api` | Deployment, Service, optional Ingress |
| Worker queues | `worker.queues` | one Deployment per enabled queue |
| Worker addons | `worker.addons` | one Deployment per addon (beat, flower, …), optional Service |
| CronJobs | `cronjobs.jobs` | one CronJob per enabled job |
| Hooks | `hooks.jobs` | one Job per enabled hook, plus a files ConfigMap when `files` is set |
| Config | `env`, `secrets` | ConfigMap and Secret (or a SecretProviderClass under `secretsStoreCsiDriver`) |
| Extra | `extraManifests` | rendered verbatim |

`worker.queues`, `worker.addons`, `cronjobs.jobs` and `hooks.jobs` each accept
**either a map or a list**. Use a map to merge with the chart defaults through a
`-f` overlay; use a list to replace them wholesale.

## ArgoCD sync-wave contract

Shared with the `banjo-alpha-deps` repo — keep the two in sync.

| Wave | What |
|---|---|
| 0 | deps (`tcpg`, `dragonfly`, `minio`) — in `banjo-alpha-deps`, gated by their own readiness probes |
| 10 | `wait-for-resources` — config and connectivity validation |
| 20 | `db-migrate`, `collect-static` |
| 30 | api, worker queues, worker addons, ingress, cronjobs |

Hooks run in the `Sync` phase, not `PreSync` (which precedes deps and deadlocks
bootstrap) or `PostSync` (which runs after the app is already serving).

Under plain `helm install` the sync-wave annotations are inert.

`wait-for-resources` is enabled by default and needs the `wait_for_resources`
management command from [banjo-utils](https://github.com/toggle-corp/banjo-utils).
If your image doesn't ship it, set `hooks.jobs.wait-for-resources.enabled: false`
or the sync hangs on a failing wave-10 hook.

## Metadata: annotations and labels

Every key is named for **what it lands on**. This is the chart's central
distinction, and getting it wrong is a render error rather than a silent no-op.

| Scope | Annotations | Labels |
|---|---|---|
| Every resource, chart-wide | `commonAnnotations` | `commonLabels` |
| Every pod, chart-wide | `podAnnotations` | `podLabels` |
| One Deployment | `api.deploymentAnnotations`, `worker.*.deploymentAnnotations` | `*.deploymentLabels` |
| One CronJob | `cronjobs.*.cronjobAnnotations` | `cronjobs.*.cronjobLabels` |
| One hook Job | `hooks.*.jobAnnotations` | `hooks.*.jobLabels` |
| One Ingress / ServiceAccount | `api.ingress.annotations`, `serviceAccount.annotations` | `.labels` |
| That component's pods | `<component>.podAnnotations` | — |

Resource-level maps layer chart-wide → component defaults → per-item, with the
per-item map winning. Labels never reach a pod template: `spec.selector.matchLabels`
is immutable, so a changed label would break the next upgrade.

### Value contract

Applies to every annotation and label map, and to every `extraEnv`:

- A **string** is `tpl`-evaluated against the root context, so
  `"{{ .Release.Namespace }}"` resolves. A literal `{{` that isn't a valid
  template fails the render.
- Any **other value** renders as JSON — `8080` becomes `"8080"`, a nested map
  becomes `{"a":"b"}`. k8s requires strings here.
- **`KEY: null` drops the key.** At a per-item level that unsets an inherited
  default rather than shadowing it. A block left with nothing in it is omitted.

Note `-f` overlays and `--set` deep-merge into these maps rather than replacing
them, so `cronjobAnnotations: {}` does **not** clear the chart's sync-wave
default — null the key instead.

### Render-time guards

The chart fails fast rather than rendering something that quietly does nothing:

- A scheduling key (`nodeSelector`, `tolerations`, `affinity`,
  `topologySpreadConstraints`) at a level the chart never reads.
- An `argocd.argoproj.io/sync-wave` in any pod-level map — ArgoCD reads the wave
  off the resource, never off a pod template.
- A `commonLabels`/`*Labels` key that collides with a label the chart sets itself.
- A pre-0.5.0 annotation key name (see [MIGRATION.md](MIGRATION.md)).

## Pod scheduling

`nodeSelector`, `tolerations`, `affinity` and `topologySpreadConstraints` are
passthrough at the root and overridable per component and per queue/addon/job.
Resolution is **per field and replace-only** — the nearest level that mentions a
field wins, so `tolerations: []` under `cronjobs.defaults` clears an inherited
root value.

Hook Jobs inherit only `nodeSelector` and `tolerations`. The restrictive fields
are withheld deliberately: hook pods carry the same `app` label as the app pods,
so a root podAntiAffinity rule would strand `db-migrate` and deadlock the sync at
wave 20. Set either field under `hooks.defaults` to opt in.

## Development

```bash
./run_tests.sh                # helm-unittest suite
helm lint ./chart             # lint
./chart/update-snapshots.sh   # regenerate snapshots after an intentional change
```

Tests live in `chart/tests/**/*_test.yaml`; the full-render snapshots in
`chart/snapshots/` are generated from the `chart/tests/values-*.yaml` fixtures
listed in `chart/tests.yaml`.

Releases are cut with `./release.sh`, which bumps `chart/Chart.yaml` and
regenerates `CHANGELOG.md` from the commit history via `git-cliff`. **Don't edit
`CHANGELOG.md` by hand** — it's generated output. Commits follow
[Conventional Commits](https://www.conventionalcommits.org/); append `!` for a
user-facing breaking change.
