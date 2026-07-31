# TODO
- [x] Add httpGet probes (liveness/readiness/startup) for API, opt-in via `api.probes.enabled`. Defaults match banjo-utils' `/healthz/live/` and `/healthz/ready/`. Worker probes still TODO (separate design — celery has no HTTP surface).
- [x] Add support for preStop in API to handle kube-proxy sync delay - to avoid kube-proxy forwarding requests to pod with SIGTERM
  ```yaml
    lifecycle:
      preStop:
        exec:
          command: ["sleep", "{{ .Values.preStopSleepSeconds }}"]
  ```
  Context
  ```
  To my understanding the preStop sleep isn't about draining in-flight requests (you're right that uvicorn handles that via SIGTERM). But they might solve a different problem: a race condition between Kubernetes sending SIGTERM and kube-proxy finishing endpoint propagation. Without the sleep, new requests can still be routed to the pod after uvicorn has already stopped accepting them, resulting in connection refused errors. The sleep runs before SIGTERM, giving kube-proxy time to remove the pod from service endpoints first. See: learnk8s.io/graceful-shutdown
  ```
- [x] Hook wave - don't run api/worker/worker-beat until hooks are good
- [x] Pod placement: `nodeSelector`/`tolerations`/`affinity`/`topologySpreadConstraints` passthrough at root, overridable per component and per queue/addon/job. Resolution is per-field and replace-only; the nearest level that mentions a field wins, so an explicitly empty value clears the inherited one. Hook jobs inherit the permissive fields (`nodeSelector`/`tolerations`) — otherwise a root toleration for a tainted pool deadlocks the ArgoCD sync at wave 20 — but not the restrictive ones, since hook pods share the `app` label and a root podAntiAffinity would strand `db-migrate` the same way.
