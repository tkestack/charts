## v0.24.0 (2020-12-21)

### New features

- Update GitLab Runner version to 13.7.0
- add optional 'imagePullSecrets' to deployment !269 (Christian Schoofs @schoofsc)

### Other changes

- Make description configruable !229 (Matthias Baur @m.baur)

## v0.23.0 (2020-11-21)

### New features

- Update GitLab Runner version to 13.6.0
- Allow user to specify any runner configuraton !271

## v0.22.0 (2020-10-20)

### New features

- Update GitLab Runner version to 13.5.0
- Add pull secrets to service account for runner image !241 (Horatiu Eugen Vlad @hvlad)

### Maintenance

- Set allowPrivilegeEscalation to false for gitlab-runner pod !243 (Horatiu Eugen Vlad @hvlad)

### Documentation changes

- Add comment on ubuntu image & securityContext !260

## v0.21.0 (2020-09-21)

### Maintenance

- Update GitLab Runner version to 13.4.0
- Fix changelog generator config to catch all maintenance related labels !255

### Other changes

- Add scripts/security-harness script !258

## v0.20.0 (2020-08-20)

### New features

- Update GitLab Runner version to 13.3.0
- Enable custom commands !250

### Maintenance

- Add `release stable` job for security fork !252
- Update changelog generator to accept new labels !249

## v0.19.0 (2020-07-20)

### New features

- Allow user to define PodSecurityPolicy !184 (Paweł Kalemba @pkalemba)
- Update GitLab Runner version to 13.2.0

### Documentation changes

- Fix external links within values.yaml !248 (Alexandre Jardin @alexandre.jardin)

## v0.18.0 (2020-06-19)

### Maintenance

- Update GitLab Runner version to 13.1.0

### Other changes

- Fix unregister when using token secret !231 (Bernd @arabus)
- Support specifying pod security context. !219 (Chen Yufei @cyfdecyf)

## v0.17.1 (2020-06-01)

### Maintenance

- Update GitLab Runner version to 13.0.1

## v0.17.0 (2020-05-20)

### New features

- Expose settings for kubernetes resource limits and requests overwrites !220 (Alexander Petermann @lexxxel)
- Add support for setting Node Tolerations !188 (Zeyu Ye @Shuliyey)

### Maintenance

- Update GitLab Runner version to 13.0.0
- Update package name in note !234
- Pin CI jobs to gitlab-org runners !222

## v0.16.0 (2020-04-22)

### New features

- Add Service Account annotation support !211 (David Rosson @davidrosson)

### Bug fixes

- Support correct spelling of GCS secret !214 (Arthur Wiebe @arthur65)

### Maintenance

- Remove dependency of `gitlab-runner-builder` runner !221
- Fix linting for forks with a different name than "gitlab-runner" !218
- Install gitlab-changelog installation !217

### Other changes

- Update GitLab Runner version to 12.10.1
- Change listen address to not force IPv6 !213 (Fábio Matavelli @fabiomatavelli)

## v0.15.0 (2020-03-20)

### Maintenance

- Update GitLab Runner version to 12.9.0
- Update changelog generator configuration !212
- Replace changelog entries generation script !209

### Other changes

- Fix values.yaml typo !210 (Brian Choy @bycEEE)

## v0.14.0 (2020-02-22)

- Update GitLab Runner version to 12.8.0

## v0.13.0 (2020-01-20)

- Add podLabels to the deployment !198
- Mount custom-certs in configure init container !202

## v0.12.0 (2019-12-22)

- Add `apiVersion: v1` to chart.yaml !195
- Add documentation to protected Runners !193
- Make securityContext configurable !199
- Update GitLab Runner version to 12.6.0

## v0.11.0 (2019-11-20)

- Variables for RUNNER_OUTPUT_LIMIT, and KUBERNETES_POLL_TIMEOUT !50
- Add support for register protected Runners !185

## v0.10.1 (2019-10-28)

- Update GitLab Runner to 12.4.1

## v0.10.0 (2019-10-21)

- Updated GitLab Runner to 12.4.0
- Use updated project path to release helm chart !172
- Update resources API to stable verson !167
- Add support for specifying log format !170
- Use the cache.secret template to check if the secretName is set !166
- Drop need for helm force update for now !181
- Fix image version detection for old helm versions !173

## v0.9.0 (2019-09-20)

- Use updated project path to release helm chart !172
- Enabling horizontal pod auto-scaling based on custom metrics !127
- Change base image used for CI jobs !156
- Remove DJ as a listed chart maintainer !160
- Release beta version on master using Bleeding Edge image !155
- Update definition of 'release beta' CI jobs !164
- Fix certs path in the comment in values file !148
- Implement support for run-untagged option !140
- Use new location for helm charts repo !162
- Follow-up to adding run-untagged support !165

## v0.8.0 (2019-08-22)

- Add suport for graceful stop !150

## v0.7.0 (2019-07-22)

- Fix broken anchor link for gcs cache docs !135
- Allow user to set rbac roles !112
- Bump used Runner version to 12.1.0 !149

## v0.6.0 (2019-06-24)

- Allow to manually build the package for development branches !120
- When configuring cache: if no S3 secret assume IAM role !111
- Allow to define request_concurrency value !121
- Bump used Runner version to 12.0.0 !138

## v0.5.0 (2019-05-22)

- Bump used Runner version to 11.11.0 !126

## v0.4.1 (2019-04-24)

- Bump used Runner version to 11.10.1 !113

## v0.4.0 (2019-04-22)

- Bump used Runner version to 11.10.0-rc2 !108
- Fix a typo in values.yaml !101
- Add pod labels for jobs !98
- add hostAliases for pod assignment !89
- Configurable deployment annotations !44
- Add pod annotations for jobs !97
- Bump used Runner version to 11.10.0-rc1 !107

## v0.3.0 (2019-03-22)

- Change mount of secret with S3 distributed cache credentials !64
- Add environment variables to runner !48
- Replace S3_CACHE_INSECURE with CACHE_S3_INSECURE !90
- Update values.yaml to remove invalid anchor in comments !85
- Bump used Runner version to 11.9.0 !102

## v0.2.0 (2019-02-22)

- Fix the error caused by unset 'locked' value !79
- Create LICENSE file !76
- Add CONTRIBUTING.md file !81
- Add plain MIT text into LICENSE and add NOTICE !80
- Fix incorrect custom secret documentation !71
- Add affinity, nodeSelector and tolerations for pod assignment !56
- Ignore scripts directory when buildin helm chart !83
- Bump used Runner version to 11.8.0-rc1 !87
- Fix year in Changelog  - it's already 2019 !84

## v0.1.45 (2019-01-22)

- Trigger release only for tagged versions !72
- Fixes typos in values.yaml comments !60
- Update chart to bring closer to helm standard template !43
- Add nodeSelector config parameter for CI job pods !19
- Prepare CHANGELOG management !75
- Track app version in Chart.yaml !74
- Fix the error caused by unset 'locked' value !79
- Bump used Runner version to 11.7.0 !82

