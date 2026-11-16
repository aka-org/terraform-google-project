# terraform-google-project

A Terraform module to automate the creation and configuration of a Google Cloud project, including project-scoped resources such as Service Accounts, Buckets, VPC, API enablement, and optional GitHub Actions Workload Identity Federation.

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Usage](#usage)
- [Module Variables](#module-variables)
- [Outputs](#outputs)
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

## Module Variables

| Name                  | Description                                                                 | Type           | Default                                      |
|-----------------------|-----------------------------------------------------------------------------|----------------|----------------------------------------------|
| project_name          | A human-readable name for the project                                        | string         | n/a (required)                               |
| project_labels        | Labels to add to project                                                     | map(string)    | `{}`                                         |
| project_deletion_policy | Project deletion policy (e.g. PREVENT or DELETE)                           | string         | `PREVENT`                                    |
| billing_account_id    | Billing account ID to associate with the project                             | string         | n/a (required)                               |
| enable_apis           | List of additional Google APIs to be enabled                                 | list(string)   | `[]`                                         |
| bucket_name_prefix    | Prefix for the state bucket name (enables bucket if non-empty)                | string         | `""`                                         |
| bucket_location       | Location of the bucket                                                       | string         | `us-east1`                                   |
| bucket_force_destroy  | Allow bucket destroy even if not empty                                       | bool           | `false`                                      |
| bucket_versioning     | Enable versioning for bucket contents                                        | bool           | `true`                                       |
| bucket_uniform_access | Control access to the bucket through IAM only (no per-object ACLs)           | bool           | `true`                                       |
| bucket_public_access_prevention | `enforced` (the bucket can never be made public) or `inherited`     | string         | `enforced`                                   |
| bucket_labels         | Labels to add to the created bucket                                          | map(string)    | `{}`                                         |
| gcs_backend           | If true, writes a `backend.tf` into the directory Terraform runs in (see [The generated backend.tf](#the-generated-backendtf)) | bool | `false`                             |
| sa_id                 | ID of the default service account                                            | string         | `terraform-sa`                               |
| sa_description        | Description of the default service account                                   | string         | `Default service account used by Terraform`   |
| sa_roles              | List of roles to assign to the default service account                      | list(string)   | See below                                    |
| remove_editor_members | Remove every member of `roles/editor` once at creation (see [The roles/editor binding](#the-roleseditor-binding)) | bool | `true`                              |
| gha_wif_enabled       | Enable GitHub Actions Workload Identity Federation                           | bool           | `false`                                      |
| gha_owner_id          | GitHub owner ID for WIF                                                      | string         | `""`                                         |
| gha_allowed_repos     | List of GitHub repos allowed for WIF                                         | list(string)   | `[]`                                         |
| vpc_create            | Set to true to create a default VPC (see [The VPC toggle](#the-vpc-toggle))  | bool           | `false`                                      |
| vpc_name              | Name of the VPC                                                              | string         | `""`                                         |

#### Default Service Account Roles
- `roles/resourcemanager.projectIamAdmin`
- `roles/iam.serviceAccountUser`
- `roles/iam.serviceAccountAdmin`
- `roles/serviceusage.serviceUsageAdmin`

---

## Outputs

- `project_name`: The name of the project
- `project_id`: The id of the project
- `project_number`: The numeric identifier of the project
- `project_labels`: The labels of the project
- `bucket_name`: The name of the bucket (if created)
- `bucket_labels`: The labels of the bucket
- `sa_name`: Default service fully-qualified name
- `sa_email`: Default service account email
- `sa_id`: Default service account id
- `identity_provider_github_ids`: Workload identity provider for Github Actions (if enabled)
- `identity_provider_github_full_ids`: Full path of workload identity provider for Github Actions (if enabled)
- `vpc_name`: Name of the project VPC (if created)
- `vpc_self_link`: Self link to the project VPC (if created)

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

## Development

What a machine needs to work on this module:

| Tool | Version | Used for |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.11.4 | `fmt`, `validate` |
| [TFLint](https://github.com/terraform-linters/tflint) | >= 0.50 | lint (`.tflint.hcl`) |
| git | any | |

Nothing here needs Google Cloud credentials: `validate` and `tflint` read only the configuration.

The checks CI runs (`.github/workflows/ci.yml`), from the repository root:

```sh
terraform fmt -check -recursive -diff
terraform init -backend=false && terraform validate
tflint --init && tflint --recursive
```

CI validates twice: on the lowest supported Google provider (6.8.0) and on the newest release the constraint allows. To validate on the lowest locally, change the `google` constraint in every `versions.tf` to `6.8.0`, run `terraform init -backend=false -upgrade && terraform validate`, and revert.

An untracked `testing/` directory is ignored by git, for a caller configuration and its `terraform.tfvars` when trying the module against a real project. `terraform fmt -recursive` and `tflint --recursive` walk into it.

Releasing: add the version's section to `CHANGELOG.md`, merge, tag `vX.Y.Z` on `main`. The Terraform Registry publishes the tag.

---

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## License
Apache 2.0 - See [LICENSE](LICENSE)
