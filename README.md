# terraform-google-project

A Terraform module to automate the creation and configuration of a Google Cloud project, including project-scoped resources such as Service Accounts, Buckets, VPC, API enablement, and optional GitHub Actions Workload Identity Federation.

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Usage](#usage)
- [Inputs and outputs](#inputs-and-outputs)
- [APIs Enabled](#apis-enabled)
- [Service Account Roles](#service-account-roles)
- [Development](#development)
- [Changelog](#changelog)
- [License](#license)

---

## Features

- **Google Cloud Project Creation**: Creates a new GCP project with custom name, labels, and billing account.
- **API Enablement**: Enables core and user-specified Google APIs.
- **Service Account Management**: Removes role editor from default gcloud service account and creates a default service account with configurable roles.
- **State Bucket**: Optionally creates a GCS bucket for Terraform state with configurable location, versioning, and force-destroy.
- **VPC Creation**: Optionally creates a VPC network with required roles and API enablement.
- **GitHub Actions Workload Identity Federation (WIF)**: Optionally configures WIF for GitHub Actions with fine-grained repo access.

### Optional Features and Toggles
- **State Bucket**: Controlled by `bucket_name_prefix` (non-empty to enable) and `gcs_backend` (to generate backend config).
- **VPC**: Controlled by `vpc_create` (set to `true` to enable).
- **GitHub Actions WIF**: Controlled by `gha_wif_enabled` (set to `true` to enable), with further configuration via `gha_owner_id` and `gha_allowed_repos`.
- **API Enablement**: Add APIs to `enable_apis` to enable them in the project.

---

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) >= 1.11.4
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) >= 6.8, < 8 (checked on 6.8.0 and the latest 7.x)
- The `random` (>= 3.0) and `local` (>= 2.0) providers
- Google Cloud billing account and permissions to create projects and resources

---

## Usage

```hcl
module "project" {
  source  = "aka-org/project/google"
  version = "1.3.0"

  project_name            = var.project_name
  billing_account_id      = var.billing_account_id
}
```

---

## Inputs and outputs

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| billing\_account\_id | Billing account ID to associate with the project | `string` | n/a | yes |
| project\_name | A human-readable name for the project | `string` | n/a | yes |
| bucket\_force\_destroy | Set to true to allow the bucket to be destroyed even if it is storing content | `bool` | `false` | no |
| bucket\_labels | Labels to add to the created bucket | `map(string)` | `{}` | no |
| bucket\_location | Location of the bucket corresponding to google regions | `string` | `"us-east1"` | no |
| bucket\_name\_prefix | The prefix of the name of the bucket that will store the tf states | `string` | `""` | no |
| bucket\_public\_access\_prevention | Public access prevention of the bucket: enforced (it can never be made public) or inherited (the organization's policy decides) | `string` | `"enforced"` | no |
| bucket\_uniform\_access | Set to true to control access to the bucket through IAM only (no per-object ACLs) | `bool` | `true` | no |
| bucket\_versioning | Set to true to enable versioning of bucket contents | `bool` | `true` | no |
| enable\_apis | Lists of additional Google APIs to be enabled | `list(string)` | `[]` | no |
| gcs\_backend | If true, writes a backend.tf naming the state bucket into the directory Terraform runs in (suits a one-off apply from a workstation, not CI: see the README) | `bool` | `false` | no |
| gha\_allowed\_repos | List of repos allowed to authenticate via identity provider | `list(string)` | `[]` | no |
| gha\_owner\_id | ID of the owner of the github repos allowed to authenticate via identity provider | `string` | `""` | no |
| gha\_wif\_enabled | Set to true to setup Workload Identity Federation for Github Actions | `bool` | `false` | no |
| project\_deletion\_policy | Project deletion policy (e.g. PREVENT or DELETE) | `string` | `"PREVENT"` | no |
| project\_labels | Labels to add to project | `map(string)` | `{}` | no |
| remove\_editor\_members | If true, removes every member of roles/editor once at creation (the default Compute Engine service account and the Google APIs Service Agent included). Set to false to leave the role's members as Google grants them | `bool` | `true` | no |
| sa\_description | Description of the default service account | `string` | `"Default service account used by Terraform"` | no |
| sa\_id | The id of the default service account | `string` | `"terraform-sa"` | no |
| sa\_roles | List of roles to be assigned to the default service account | `list(string)` | <pre>[<br/>  "roles/resourcemanager.projectIamAdmin",<br/>  "roles/iam.serviceAccountUser",<br/>  "roles/iam.serviceAccountAdmin"<br/>]</pre> | no |
| vpc\_create | Set to true to create a default project vpc | `bool` | `false` | no |
| vpc\_name | Name of the project vpc | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| bucket\_labels | The labels of the bucket |
| bucket\_name | The name of the bucket |
| identity\_provider\_github\_full\_ids | Full path of workload identity provider for Github Actions |
| identity\_provider\_github\_ids | Workload identity provider for Github Actions |
| project\_id | The id of the project |
| project\_labels | The labels of the project |
| project\_name | The name of the project |
| project\_number | The numeric identifier of the project (used in Workload Identity principals and Google-managed service agent emails) |
| sa\_email | Default service account email |
| sa\_id | Default service account id |
| sa\_name | Default service account fully-qualified name |
| vpc\_name | Name of the project vpc |
| vpc\_self\_link | Self link to the project vpc |
<!-- END_TF_DOCS -->

---

## APIs Enabled

### Always Enabled by Default
- `serviceusage.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `cloudbilling.googleapis.com`
- `iam.googleapis.com`

### By Feature
- **VPC**: `compute.googleapis.com` (if `vpc_create` is `true`)
- **State Bucket**: `storage.googleapis.com` (if `bucket_name_prefix` is non-empty)
- **GitHub Actions WIF**: No additional APIs required
- **Custom APIs**: Any APIs listed in `enable_apis`

---

## Service Account Roles

### Default Service Account
- Always assigned:
  - `roles/resourcemanager.projectIamAdmin`
  - `roles/iam.serviceAccountUser`
  - `roles/iam.serviceAccountAdmin`
  - `roles/serviceusage.serviceUsageAdmin`
- **VPC** (if enabled):
  - `roles/compute.networkAdmin`
- **State Bucket** (if enabled):
  - `roles/storage.admin`
- **GitHub Actions WIF** (if enabled):
  - `roles/iam.workloadIdentityPoolAdmin` (on project)

---

## Behaviour worth knowing

### The roles/editor binding
With `remove_editor_members = true` (the default) the module creates an authoritative, empty binding for `roles/editor`. It removes every member the role has at that moment and ignores members added later. Because the project's APIs are enabled first, that includes more than the default Compute Engine service account: when `compute.googleapis.com` is among the enabled APIs, Google has by then granted Editor to the Google APIs Service Agent (`<project number>@cloudservices.gserviceaccount.com`), and it is removed too. Google's documentation advises against removing that agent's role. Destroying the binding (also by switching the variable to `false` later) removes every member of the role again. Set `remove_editor_members = false` on a new project to leave the role as Google grants it.

### The generated backend.tf
`gcs_backend = true` writes `backend.tf` into the directory Terraform runs in (`path.cwd`), through a `local_file` resource. It suits a one-off apply from a workstation. Avoid it where Terraform runs in CI: a fresh runner doesn't have the file, so every plan proposes to create it again, and setting the variable back to `false` deletes the file. There, leave it `false` and commit your own `backend.tf` naming the `bucket_name` output.

### APIs stay enabled
Removing an API from `enable_apis` (or destroying the module without destroying the project) leaves the API enabled (`disable_on_destroy = false`), on every supported provider version.

### The VPC toggle
`vpc_create` creates a bare VPC, enables the Compute Engine API and grants the default service account `roles/compute.networkAdmin`. For subnets, firewall rules or NAT use [terraform-google-network](https://github.com/aka-org/terraform-google-network) instead, with `vpc_create = false`, `compute.googleapis.com` in `enable_apis` and the network roles in `sa_roles`.

### GitHub Actions identities
Each repo in `gha_allowed_repos` gets its own identity provider, and any workflow of that repo, on any branch, may act as the default service account. The token's `ref` is mapped (`attribute.ref`), so your own IAM bindings can limit other service accounts to one branch (`.../attribute.ref/refs/heads/main`).

---

### GitHub identity provider ids
Each repository in `gha_allowed_repos` gets a Workload Identity provider named after the repository, adjusted where Google would refuse the name: one starting with `gcp-` (reserved) or shorter than 4 characters gets the prefix `gh-` (`aka-org/gcp-infra` becomes `gh-gcp-infra`), characters other than lowercase letters, digits and hyphens become hyphens, and the result is cut to 32 characters. The outputs `identity_provider_github_ids` and `identity_provider_github_full_ids` carry the result.

## Development

What a machine needs to work on this module:

| Tool | Version | Used for |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.11.4 | `fmt`, `validate`, `test` |
| [TFLint](https://github.com/terraform-linters/tflint) | >= 0.50 | lint (`.tflint.hcl`) |
| [terraform-docs](https://terraform-docs.io/user-guide/installation/) | >= 0.25 | the README's Inputs and Outputs tables (`.terraform-docs.yml`) |
| git | any | |

Nothing here needs Google Cloud credentials: `validate` and `tflint` read only the configuration, and the tests (`tests/`) run the module against mocked providers, creating nothing.

The checks CI runs (aka-org/gcp-infra's `terraform-module-ci.yml`, called from `.github/workflows/ci.yml`), from the repository root:

```sh
terraform fmt -check -recursive -diff
terraform init -backend=false && terraform validate && terraform test
tflint --init && tflint --recursive
terraform-docs --output-check .
```

After changing a variable or an output, run `terraform-docs .` to rewrite the README's tables.

CI validates and tests twice: on the lowest supported Google provider (6.8.0, read from `versions.tf`) and on the newest release the constraint allows. It runs on every pull request and once a week, so a new provider release that breaks the module shows up without a change here. To validate on the lowest locally, change the `google` constraint in every `versions.tf` to `6.8.0`, run `terraform init -backend=false -upgrade && terraform validate`, and revert.

An untracked `testing/` directory is ignored by git, for a caller configuration and its `terraform.tfvars` when trying the module against a real project. `terraform fmt -recursive` and `tflint --recursive` walk into it.

Releasing: add the version's section to `CHANGELOG.md`, merge, tag `vX.Y.Z` on `main`. The Terraform Registry publishes the tag.

---

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## License
Apache 2.0 - See [LICENSE](LICENSE)

### Releasing

A release is a merge to `main` whose `CHANGELOG.md` starts with a new `## X.Y.Z` heading: `.github/workflows/release.yml` runs the checks again, pushes the annotated tag `vX.Y.Z` (the Terraform Registry publishes from it) and creates the GitHub release with that changelog section as its notes (aka-org/gcp-infra's `changelog-release.yml`). A merge that adds no new version releases nothing; keep changes that aren't released yet under a `## Unreleased` heading above the newest version.
