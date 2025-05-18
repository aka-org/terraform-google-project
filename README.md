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
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) >= 6.8.0
- Google Cloud billing account and permissions to create projects and resources

---

## Usage

```hcl
module "project" {
  source  = "aka-org/project/google"
  version = "1.0.0"

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
| bucket_name_prefix    | Prefix for the state bucket name (enables bucket if non-empty)                | string         | `tf-states`                                  |
| bucket_location       | Location of the bucket                                                       | string         | `us-east1`                                   |
| bucket_force_destroy  | Allow bucket destroy even if not empty                                       | bool           | `false`                                      |
| bucket_versioning     | Enable versioning for bucket contents                                        | bool           | `true`                                       |
| bucket_labels         | Labels to add to the created bucket                                          | map(string)    | `{}`                                         |
| gcs_backend           | If true, creates backend config for GCS state                                | bool           | `false`                                      |
| sa_id                 | ID of the default service account                                            | string         | `terraform-sa`                               |
| sa_description        | Description of the default service account                                   | string         | `Default service account used by Terraform`   |
| sa_roles              | List of roles to assign to the default service account                      | list(string)   | See below                                    |
| gha_wif_enabled       | Enable GitHub Actions Workload Identity Federation                           | bool           | `false`                                      |
| gha_owner_id          | GitHub owner ID for WIF                                                      | string         | `""`                                         |
| gha_allowed_repos     | List of GitHub repos allowed for WIF                                         | list(string)   | `[]`                                         |
| vpc_create            | Set to true to create a default VPC                                          | bool           | `false`                                      |
| vpc_name              | Name of the VPC                                                              | string         | `""`                                         |

#### Default Service Account Roles
- `roles/resourcemanager.projectIamAdmin`
- `roles/iam.serviceAccountUser`
- `roles/iam.serviceAccountAdmin`

---

## Outputs

- `project_name`: The name of the project
- `project_id`: The id of the project
- `project_labels`: The labels of the project
- `bucket_name`: The name of the bucket (if created)
- `bucket_labels`: The labels of the bucket
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
- **VPC** (if enabled):
  - `roles/compute.networkAdmin`
  - `roles/compute.admin`
- **State Bucket** (if enabled):
  - `roles/storage.admin`
- **GitHub Actions WIF** (if enabled):
  - `roles/iam.workloadIdentityPoolAdmin` (on project)
  - `roles/iam.workloadIdentityUser` (on service account, per allowed repo)

---

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## License
Apache 2.0 - See [LICENSE](LICENSE)
