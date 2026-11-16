# Changelog
All notable changes to this project will be documented in this file.

## 1.4.0
### ADDED
- `gha_sa_refs`: limits who may act as the default service account to workflows running for the given git refs (e.g. `refs/heads/main`), so a pull request's workflow can't. Empty (the default) keeps every ref allowed, as before.
- `gha_plan_sa_id`, `gha_plan_sa_roles`, output `plan_sa_email`: an optional second, read-only service account for `terraform plan` on pull requests, with read access to the state bucket.
- Identity providers also map `attribute.repository_ref` (`<owner>/<repo>@<ref>`). Existing callers see an in-place update of each provider's attribute mapping and nothing else.

## 1.3.1
### FIXED
- Workload Identity Federation for a repository whose name starts with `gcp-`, is shorter than 4 characters or holds characters other than lowercase letters, digits and hyphens: the provider's id is adjusted to one Google accepts (`aka-org/gcp-infra` -> `gh-gcp-infra`) instead of failing at plan. Names that were already valid keep their provider id, so existing callers see no change.
### ADDED
- Tests (`tests/`, `terraform test`) that plan and apply the module against mocked providers; CI runs them on the lowest and newest supported Google provider.
- CI also runs weekly, and lints with TFLint's Google ruleset.
- Releases are made by CI from the changelog's newest version (`.github/workflows/release.yml`).
- The checks and the release step are aka-org/gcp-infra's shared workflows, called from this repository's.

## 1.3.0
### CHANGED
- The Google provider constraint is a range, `>= 6.8, < 8` (was exactly `6.8.0`); validated on 6.8.0 and 7.46.2.
- `google_project_service` sets `disable_on_destroy = false`, so provider 6.x and 7.x behave the same: an API removed from the list stays enabled. Existing callers see an in-place change on each API (`true -> false`), with no API call.
- The state bucket has uniform bucket-level access and enforced public access prevention by default. Existing callers see an in-place update of the bucket; set `bucket_uniform_access = false` / `bucket_public_access_prevention = "inherited"` to keep it as it was.
### ADDED
- The `random` and `local` providers are declared in `required_providers`; every submodule declares the providers it uses.
- `remove_editor_members` (default `true`, the behaviour so far) makes the `roles/editor` binding optional. The resource's address gains `[0]`; a `moved` block carries existing state over, so no caller sees a change.
- `bucket_uniform_access`, `bucket_public_access_prevention`.
- Output `project_number`.
- The GitHub Actions identity providers map the token's `ref` (`attribute.ref`). Existing callers see an in-place update of each provider; no existing binding changes meaning.
- CI: `terraform fmt`, `validate` on the lowest and newest supported provider, TFLint, and a check that the README's Inputs and Outputs tables match the code (generated with terraform-docs).
- README: "Behaviour worth knowing" and "Development".
### FIXED
- README: `bucket_name_prefix`'s default (`""`) and the provider requirement.

## 1.2.0
### ADDED
- Add `roles/serviceusage.serviceUsageAdmin` to default SA.

## 1.1.0
### CHANGED
- Google API enabling now happen directly after project creation even for togglable features.
- Togglable features no longer use a data source to get access to default SA attributes.
### Added
- Added lifecycle policy to ignore changes to members of `roles/editor` after initially apply.
### REMOVED
- Removes `roles/compute.admin` from default Service Account, add to `sa_roles` if you need it.

## 1.0.0
1.0.0 is a major backwards incompatible release.
### ADDED
- Remove default service account from editors.
- Add README.
### CHANGED
- Create only one default service account with default roles.
- Each togglable feature of the module enables necesasry gcloud apis and assigns necessary roles to default sa.
- Create only one bucket if enabled for terraform states.
- Allow multiple providers corresponding to different repos to be configured for the github identity pool if enabled.

## 0.3.0
### ADDED
- Allow gha provider partially match repo based on `gha_wif_org` when `gha_wif_repo` is an empty string.
- Allow state bucket to be created even if `gcs_backend` is set to false. 

## 0.2.0
### ADDED
- Introduces support for Github Actions identity provider.

### Fixed
- Missing condition check for feature toggle in bucket outputs.
 
## 0.1.0
### ADDED
- Initial release of the terraform-google-project module.
