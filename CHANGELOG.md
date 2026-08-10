# Changelog

## [0.5.0](https://github.com/toggle-corp/banjo-helm/compare/0.4.1..0.5.0) - 2026-08-10
### Changes:

#### 🚀  Features

- *(chart)* Add per-component resource label surfaces - ([fb3ae8e](https://github.com/toggle-corp/banjo-helm/commit/fb3ae8ee55461411751c4d18c11a1b822fdc53db))
- *(chart)* Add chart-wide commonLabels for resource metadata - ([53c0575](https://github.com/toggle-corp/banjo-helm/commit/53c05752e47149f17b8f103e9939e5296f8c19a8))
- *(chart)* Guard inert sync-waves on every pod-level annotations map - ([cd3c97c](https://github.com/toggle-corp/banjo-helm/commit/cd3c97c8401fca8a591a868b5a9d6ab427422f15))
- *(chart)* Add chart-wide commonAnnotations for resource metadata - ([6c37dbc](https://github.com/toggle-corp/banjo-helm/commit/6c37dbcf9cfc802c5098ceb9866947c6c0d911c1))
- *(chart)* Render pod annotations, labels and serviceAccount metadata via tplAnnotations - ([7192d93](https://github.com/toggle-corp/banjo-helm/commit/7192d9312cad45e09a762b4420ea6c0eeb17e04c))
- *(chart)* [**breaking**] Rename per-component annotations to podAnnotations - ([2030622](https://github.com/toggle-corp/banjo-helm/commit/2030622702b1143c66ce29e0a3a73907c52e0aea))
- *(chart)* [**breaking**] Render resource annotation values via tplAnnotations - ([50d4a8f](https://github.com/toggle-corp/banjo-helm/commit/50d4a8fa373fe3875e30a2e4b322271bfd145d33))
- *(chart)* Fail on scheduling keys placed at an unread level - ([878fd10](https://github.com/toggle-corp/banjo-helm/commit/878fd10dc3f3364fb262e71822619ba451bc8ff6))
- *(cronjobs)* [**breaking**] Apply CronJobs at ArgoCD sync-wave 30 - ([1d01567](https://github.com/toggle-corp/banjo-helm/commit/1d015676d7eb5699a83a1db0e1d143c77d580dfe))
- *(hooks)* [**breaking**] Split hook annotations into jobAnnotations and podAnnotations - ([5fb60af](https://github.com/toggle-corp/banjo-helm/commit/5fb60af7af2d7b98c7f8e7fb0e1ed9ce36a7011a))
- *(scheduling)* Add nodeSelector/tolerations/affinity/topologySpreadConstraints passthrough - ([5d1df05](https://github.com/toggle-corp/banjo-helm/commit/5d1df05d9d3ed05f2d5fd0fb4d04697d2bb8747f))

#### 🐛 Bug Fixes

- *(chart)* Guard reserved label keys on the Ingress - ([0616b2d](https://github.com/toggle-corp/banjo-helm/commit/0616b2d40f271003496ed30617f20544f028c0d5))
- *(chart)* Render non-string extraEnv values via toJson - ([b513e8a](https://github.com/toggle-corp/banjo-helm/commit/b513e8aa1aac914fb6bc96f6074067320689ee89))
- *(chart)* Let a per-item extraEnv null unset a component default - ([ecca577](https://github.com/toggle-corp/banjo-helm/commit/ecca5774621aac56e491fabe6d5c3b8604d1f9fc))
- *(chart)* Withhold root affinity from hook pods, allow clearing - ([7b34482](https://github.com/toggle-corp/banjo-helm/commit/7b34482b72aaed85d2789a636aa70f46ad293697))
- *(config)* Render non-string env/secret values via toJson - ([2bff10e](https://github.com/toggle-corp/banjo-helm/commit/2bff10efab715faea80580a5e9ddad34a4cf4de1))
- *(config)* Coerce non-string env/secret values and skip nil - ([94a93ca](https://github.com/toggle-corp/banjo-helm/commit/94a93ca4bb5fa7b31f28be49ac1a294bc01f944c))
- *(hooks)* Use jobAnnotations in linter_values - ([549f97e](https://github.com/toggle-corp/banjo-helm/commit/549f97eeeb3f858b6b8dab813d5b8e175dad6109))

#### 📚 Documentation

- *(config)* State the env/secrets value contract, including null - ([e5137b2](https://github.com/toggle-corp/banjo-helm/commit/e5137b257c47224dc9816ddbf270879f1023da2b))
- *(migration)* Retarget to 0.5.0 and add the annotation-interface delta - ([8474a21](https://github.com/toggle-corp/banjo-helm/commit/8474a21a2dce0b81f16cd80b4f0ba131029803c0))
- *(readme)* Add a chart README - ([6ccf384](https://github.com/toggle-corp/banjo-helm/commit/6ccf384a868e220105dc05264debcf21a89e7f95))


## [0.4.1](https://github.com/toggle-corp/banjo-helm/compare/0.4.0..0.4.1) - 2026-07-09
### Changes:

#### 🚀  Features

- *(ingress)* Tpl-evaluate api.ingress.annotation values - ([2e63b12](https://github.com/toggle-corp/banjo-helm/commit/2e63b12153153b9e14bc09b5d17314e290541a4e))

#### ⚙️ Miscellaneous Tasks

- *(helm)* Pin setup-helm to v4.2.0 and regenerate snapshots - ([1190e7f](https://github.com/toggle-corp/banjo-helm/commit/1190e7f524d30b9e6ce6e1b1e8866fda2ab534d4))


## [0.4.0](https://github.com/toggle-corp/banjo-helm/compare/0.3.0..0.4.0) - 2026-07-08
### Changes:

#### 🚀  Features

- *(api)* Add opt-in httpGet probes with banjo-utils defaults - ([6e04f5e](https://github.com/toggle-corp/banjo-helm/commit/6e04f5efd2f3789c6ab100a23d1f742880d07fe4))
- *(api)* [**breaking**] PreStop sleep + computed terminationGracePeriodSeconds for graceful shutdown - ([bb1aa05](https://github.com/toggle-corp/banjo-helm/commit/bb1aa05fe5e4e3752db49e302240c2460b1e348d))
- *(chart)* [**breaking**] Hooks restructure with regression guard for inert annotation - ([080eca5](https://github.com/toggle-corp/banjo-helm/commit/080eca5d3c5c0b11fa4e2a4f3c86fce3ace510a4))
- *(chart)* [**breaking**] Cronjobs restructure (defaults sibling + dict-or-array) - ([298799b](https://github.com/toggle-corp/banjo-helm/commit/298799b4c6ef7cb1de17da367b1e371c471f773e))
- *(chart)* [**breaking**] Worker addons replace beat + flower as first-class - ([4fa8b60](https://github.com/toggle-corp/banjo-helm/commit/4fa8b60488b16f5edfd1bf2544bbd17b7743b375))
- *(chart)* [**breaking**] Worker queues restructure (queueDefaults + dict-or-array) - ([19d7253](https://github.com/toggle-corp/banjo-helm/commit/19d7253b9c501bb8f0ed4523224874494cd443cf))
- *(chart)* ExtraEnvVars supports both dict and array forms - ([68ab350](https://github.com/toggle-corp/banjo-helm/commit/68ab3505b527fc88626960bdde6f529f7ab6a5f9))
- *(chart)* [**breaking**] Restructure api block; add banjo.extraEnvBlock helper - ([efc1d24](https://github.com/toggle-corp/banjo-helm/commit/efc1d24d74f13f2fa11c1bf77323d17a0f37e503))
- *(chart)* Add chart-wide revisionHistoryLimit: 1 - ([288208c](https://github.com/toggle-corp/banjo-helm/commit/288208c16d943a3d1031db6f0f031f97965ba36b))
- *(cronjobs)* Add ttlSecondsAfterFinished with 7-day default - ([90ce011](https://github.com/toggle-corp/banjo-helm/commit/90ce0111bea04afa386aabb33cab3b4dd3516208))
- *(hooks)* Mount inline files as a ConfigMap for stdin scripts - ([9faa683](https://github.com/toggle-corp/banjo-helm/commit/9faa68300660c969d39b956e0cf5f96ca23b7c3f))
- *(hooks)* [**breaking**] Gate api/worker behind Sync-phase hooks via sync-wave - ([bd20a73](https://github.com/toggle-corp/banjo-helm/commit/bd20a734881872bc96bcb8a9e0f4681387bfa046))
- *(ingress)* [**breaking**] Make api.ingress.className optional, omit when unset - ([156dccf](https://github.com/toggle-corp/banjo-helm/commit/156dccff518ba22e11f750ac332ad61faccfa988))
- *(ingress)* [**breaking**] Move ingress.* -> api.ingress.* - ([093870f](https://github.com/toggle-corp/banjo-helm/commit/093870f14ab0b12a6ba12863df8099548d9b7bd5))
- *(worker)* TerminationGracePeriodSeconds passthrough - ([20c243a](https://github.com/toggle-corp/banjo-helm/commit/20c243a383e1424155b1559cc732738f8db69ee4))
- *(worker)* Strategy passthrough (Recreate for beat singleton) - ([aa89751](https://github.com/toggle-corp/banjo-helm/commit/aa89751ddb960b4da911f41b7bef5048cb03eae4))
- *(worker)* Celery liveness/startup probes passthrough for queues + addons - ([f4b3ea9](https://github.com/toggle-corp/banjo-helm/commit/f4b3ea98b216bed0f7a9bab4c59a62e60af69e38))
- *(worker)* Per-workload volumes/volumeMounts (dict-or-array) - ([f0e2328](https://github.com/toggle-corp/banjo-helm/commit/f0e2328f21b9b8a308647b52e5137b44409e062e))

#### 🐛 Bug Fixes

- Fixup! feat(chart)!: hooks restructure with regression guard for inert annotation - ([6070378](https://github.com/toggle-corp/banjo-helm/commit/60703785ac3a1a1a59c552082e4670a06e1126bd))

#### 🚜 Refactor

- Breaking changes ([#10](https://github.com/toggle-corp/banjo-helm/issues/10)) - ([eaeac88](https://github.com/toggle-corp/banjo-helm/commit/eaeac881176063165ee198092f471a3ea4a80a2f))

#### 📚 Documentation

- *(migration)* Note ingress restructure and optional className - ([f7973ec](https://github.com/toggle-corp/banjo-helm/commit/f7973eced65bfb992790e4af8b7f3703ca8d8592))
- *(worker)* Complete copy-paste celery probe examples in values.yaml - ([20c656b](https://github.com/toggle-corp/banjo-helm/commit/20c656bdf00b8db54dd0b8724894e4a85166e33b))
- CHANGELOG entry + Claude-optimized MIGRATION.md for new release - ([4a51b59](https://github.com/toggle-corp/banjo-helm/commit/4a51b59cfdc580172051102901c616dbd2ff1a93))

#### ⚙️ Miscellaneous Tasks

- *(chart)* Regenerate render snapshots for 0.4.0-dev1 shape - ([5fc7a79](https://github.com/toggle-corp/banjo-helm/commit/5fc7a79fa42670a25d99e462b2656e80d24598d1))
- Bump to 0.4.0-dev1, drop bundled subcharts, rename django-app.* → banjo.* - ([4ca0bec](https://github.com/toggle-corp/banjo-helm/commit/4ca0bec832e60e55db46ddde7c3638e72a304ce9))

### 🍻 Pull Requests (1)
- (#10) [Refactor: breaking changes](https://github.com/toggle-corp/banjo-helm/pull/10)


## [0.3.0](https://github.com/toggle-corp/banjo-helm/compare/0.2.8..0.3.0) - 2026-04-30
### Changes:

#### 🚀  Features

- *(ci)* Add helm unit test ci check - ([7b43ccc](https://github.com/toggle-corp/banjo-helm/commit/7b43cccf63777cac594fd4d43a713e02824c320b))
- *(test)* Add extraManifests tests - ([b0602f2](https://github.com/toggle-corp/banjo-helm/commit/b0602f2a54e0e6a92587ae2519a0172053e8a81c))
- *(test)* Add unit test for secret and secretsStoreCsiDriver - ([b7cd376](https://github.com/toggle-corp/banjo-helm/commit/b7cd3760f4e43af6f3356c9a39f6d687cd418685))
- *(test)* Add unit test for configmap - ([2c92a62](https://github.com/toggle-corp/banjo-helm/commit/2c92a627f5e7e9634e27df581fa3265638f27aea))

#### 🧪 Testing

- Add tests - ([46b03cb](https://github.com/toggle-corp/banjo-helm/commit/46b03cbcc31b0f7bd5fff75b66309a66d60b6338))

#### ⚙️ Miscellaneous Tasks

- Add justfile helper for installing helm-unittest - ([2afb4e7](https://github.com/toggle-corp/banjo-helm/commit/2afb4e71bde408c4aacf86ac60a829faf11ed9b5))

#### Worker

- Add enable flag for beat and queue ([#9](https://github.com/toggle-corp/banjo-helm/issues/9)) - ([d0dedaf](https://github.com/toggle-corp/banjo-helm/commit/d0dedaf7f34ac7231476c138ba5c02b17a69463c))

### 🍻 Pull Requests (2)
- (#6) [Feature/helm unit test](https://github.com/toggle-corp/banjo-helm/pull/6)
- (#9) [Worker: Add enable flag for beat and queue](https://github.com/toggle-corp/banjo-helm/pull/9)

### :tada: New Contributors (1)

- [@susilnem](https://github.com/susilnem) made their first contribution

## [0.2.8](https://github.com/toggle-corp/banjo-helm/compare/0.2.7..0.2.8) - 2026-04-10
### Changes:

#### 🐛 Bug Fixes

- Cronjob metadata placement - ([d74154b](https://github.com/toggle-corp/banjo-helm/commit/d74154b65885c4bd59d0d0cab30304a2fbf2f83f))


## [0.2.7](https://github.com/toggle-corp/banjo-helm/compare/0.2.6..0.2.7) - 2026-04-10
### Changes:

#### 🐛 Bug Fixes

- Add missing bitnamilegacy/os-shell - ([13d3763](https://github.com/toggle-corp/banjo-helm/commit/13d3763cc61a333dfe983ca6c219a364bc9f5ef2))


## [0.2.6](https://github.com/toggle-corp/banjo-helm/compare/0.2.5..0.2.6) - 2026-04-06
### Changes:

#### 🚀  Features

- *(ci)* Add submodules true condition - ([7de8cdf](https://github.com/toggle-corp/banjo-helm/commit/7de8cdf3f34f0d03669066f1ccbc4d99e94a2481))
- *(fugit)* Add fugit submodule - ([a84eed5](https://github.com/toggle-corp/banjo-helm/commit/a84eed581ae765d895caa91e17ccdf7c835040da))
- *(replicas)* Change the replicacount condition. - ([af27a8f](https://github.com/toggle-corp/banjo-helm/commit/af27a8f0e72025625e42a88651fa3285da8c0a46))
- Update chart name to banjo-helm - ([746702f](https://github.com/toggle-corp/banjo-helm/commit/746702fcb26cf661a8b3ede97d0ba60c14b100b4))
- Integrate release with fugit - ([6f18a00](https://github.com/toggle-corp/banjo-helm/commit/6f18a007cf9712eace474d9cdafb2e69ba5a4f5d))

#### ⚙️ Miscellaneous Tasks

- *(tests)* Update the tests and values. - ([6c1af5d](https://github.com/toggle-corp/banjo-helm/commit/6c1af5d7c14ea16ecec8e5317557363c181efbf5))

### 🍻 Pull Requests (1)
- (#7) [Add fugit submodule](https://github.com/toggle-corp/banjo-helm/pull/7)

### :tada: New Contributors (1)

- [@sandeshit](https://github.com/sandeshit) made their first contribution

## [0.2.5](https://github.com/toggle-corp/banjo-helm/compare/0.2.4..0.2.5) - 2025-11-26
### Changes:

#### 🚀  Features

- Allow additional env config per hooks - ([eb8d4ef](https://github.com/toggle-corp/banjo-helm/commit/eb8d4efb34d10ae7c32fc2905c4c009999b47371))


## [0.2.4](https://github.com/toggle-corp/banjo-helm/compare/0.2.3..0.2.4) - 2025-11-19
### Changes:

#### 🚀  Features

- Remove default resources for default worker - ([f1daa41](https://github.com/toggle-corp/banjo-helm/commit/f1daa418aa55028b8100f209d135028842dbf7ed))
- Add env per worker - ([0f28a8f](https://github.com/toggle-corp/banjo-helm/commit/0f28a8ffcffab8b41dd17156481ec01d6f26d4ce))
- Support string in extra-manifests - ([092e4c3](https://github.com/toggle-corp/banjo-helm/commit/092e4c3b5d91ff06eb2b0314cbe11cfb26aa00ef))
- Add script to generate values-tests snapshot - ([2197491](https://github.com/toggle-corp/banjo-helm/commit/21974918d36b396a3d707548eb96675d256c745f))

#### 🐛 Bug Fixes

- Use bitnamilegacy images - ([8a79c58](https://github.com/toggle-corp/banjo-helm/commit/8a79c58c237f02bcc5b8f72bfe6b0077a2d1f569))

#### ⚙️ Miscellaneous Tasks

- Rename toggle-django-helm dir to chart - ([b42ffff](https://github.com/toggle-corp/banjo-helm/commit/b42ffffaac028d9411708d75b318836132bfb198))


## [0.2.3](https://github.com/toggle-corp/banjo-helm/compare/0.2.2..0.2.3) - 2025-11-14
### Changes:

#### 🚀  Features

- Fix missing ingress tls configuration - ([ece5ff7](https://github.com/toggle-corp/banjo-helm/commit/ece5ff7fe593cd660834b81135ec42f1c540960f))


## [0.2.2](https://github.com/toggle-corp/banjo-helm/compare/0.2.1..0.2.2) - 2025-11-14
### Changes:

#### 🚀  Features

- Add imagePullSecrets - ([ab45bd1](https://github.com/toggle-corp/banjo-helm/commit/ab45bd1784e114d69f5f70794f825967f47741b1))
- Add secretsStoreCsiDriver integration (usages in azure) - ([734157e](https://github.com/toggle-corp/banjo-helm/commit/734157eef9d1b0e604ef8511950a6cba27dc068f))
- Add podVolumes and podVolumeMounts - ([ad099b9](https://github.com/toggle-corp/banjo-helm/commit/ad099b9514b448689392f5b6ad807bc9f77c137c))
- Add podLabels and podAnnotations - ([97c3c97](https://github.com/toggle-corp/banjo-helm/commit/97c3c973528ee3915cc144a388bc0d1fc1c37af7))
- Add service-account - ([674052b](https://github.com/toggle-corp/banjo-helm/commit/674052b52446f20828071fb4828475564f590379))

#### 🐛 Bug Fixes

- Reloader.stakater.com annotations placement - ([16c5976](https://github.com/toggle-corp/banjo-helm/commit/16c5976c7fa78362e1ef3090c3342ae6646ec9d7))

#### 📚 Documentation

- Update comments - ([248b117](https://github.com/toggle-corp/banjo-helm/commit/248b1172704715b856b815d35af8e910fd061d96))

### 🍻 Pull Requests (1)
- (#2) [Feat/azure integration](https://github.com/toggle-corp/banjo-helm/pull/2)


## [0.2.1](https://github.com/toggle-corp/banjo-helm/compare/0.2.0..0.2.1) - 2025-11-12
### Changes:

#### 🚀  Features

- Allow object for extraManifests - ([6788496](https://github.com/toggle-corp/banjo-helm/commit/678849685143f224d03a5416d7e68afc83a88af3))

#### ⚙️ Miscellaneous Tasks

- Revamp release.sh - ([4a9a655](https://github.com/toggle-corp/banjo-helm/commit/4a9a6558abc03f8fcc852fdaae4b30631cefa14b))

### 🍻 Pull Requests (1)
- (#1) [Feat: allow object for extraManifests](https://github.com/toggle-corp/banjo-helm/pull/1)


## [0.2.0](https://github.com/toggle-corp/banjo-helm/compare/0.1.0-dev1..0.2.0) - 2025-08-20
### Changes:

#### 🚀  Features

- *(cronjob)* Add timeZone support - ([14a74d6](https://github.com/toggle-corp/banjo-helm/commit/14a74d6487a23f5bc2aaa4d580e3457cbab892df))
- *(django)* Use _helpers for same configurations - ([b4f5f3d](https://github.com/toggle-corp/banjo-helm/commit/b4f5f3d7d79b92f7f80e060575dcc99b7268624b))
- Add extraManifests - ([19e2bca](https://github.com/toggle-corp/banjo-helm/commit/19e2bca73ed3e3da9c393682fe729e8b1702da23))

#### ⚙️ Miscellaneous Tasks

- *(django-app)* Add annotation on api ingress - ([d850435](https://github.com/toggle-corp/banjo-helm/commit/d8504350574c01aa85eb08462f4be5b67b285be9))
- *(release)* Git-cliff setup - ([4a02be0](https://github.com/toggle-corp/banjo-helm/commit/4a02be0e59576f1e90a5909178434f4a84ed7278))
- Rename django-app -> toggle-django-helm - ([6ca9016](https://github.com/toggle-corp/banjo-helm/commit/6ca9016b28e27ebb43272b7ff8954a069fb18c33))
- Remove react-serve - ([9181f3e](https://github.com/toggle-corp/banjo-helm/commit/9181f3eacbc33ac8a1eca4addb879e19131d7cf1))

#### Django-app

- Add support for extraEnvVars - ([6b789f6](https://github.com/toggle-corp/banjo-helm/commit/6b789f69896f559b99be6cf4ea1acad1278e0df0))
- Use _helpers for deployment annotations - ([15f8cc0](https://github.com/toggle-corp/banjo-helm/commit/15f8cc0448fa06ceb8bdb62921fb347485488a2c))

#### React-server

- Add checksum in deployment for config change - ([baa0e01](https://github.com/toggle-corp/banjo-helm/commit/baa0e01d590923342499012b0c941c8d3ad3d8b4))

### :tada: New Contributors (1)

- [@sudip-khanal](https://github.com/sudip-khanal) made their first contribution

<!-- generated by git-cliff -->
