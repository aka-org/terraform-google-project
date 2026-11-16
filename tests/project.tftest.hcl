# Runs the module against mocked providers: no credentials, no API calls,
# no file written. Run with `terraform test` from the repository root.
#
# The first runs apply the whole module (the mocks invent every value a
# real provider would return) and check what a caller gets back; the runs
# with a `module` block plan one submodule and check its resources.

mock_provider "google" {
  # The provider checks the shape of a service account's name and email
  # where they are used, so the mock returns realistic ones.
  mock_resource "google_service_account" {
    defaults = {
      name  = "projects/example-1a2b3c4d/serviceAccounts/terraform-sa@example-1a2b3c4d.iam.gserviceaccount.com"
      email = "terraform-sa@example-1a2b3c4d.iam.gserviceaccount.com"
    }
  }
}
mock_provider "random" {}
mock_provider "local" {}

variables {
  project_name       = "example"
  billing_account_id = "000000-000000-000000"
}

run "defaults_create_project_and_service_account_only" {
  assert {
    condition     = output.project_name == "example" && startswith(output.project_id, "example-")
    error_message = "The project id is the project name with a random suffix."
  }
  assert {
    condition     = output.sa_id == "terraform-sa"
    error_message = "The service account's default id is terraform-sa."
  }
  assert {
    condition     = output.bucket_name == null && output.vpc_name == null
    error_message = "No bucket or network is created unless asked for."
  }
  assert {
    condition     = output.identity_provider_github_ids == null
    error_message = "No Workload Identity Federation unless enabled."
  }
}

run "state_bucket_is_named_from_its_prefix" {
  variables {
    bucket_name_prefix = "tf-states"
  }

  assert {
    condition     = startswith(output.bucket_name, "tf-states-")
    error_message = "The bucket is named <prefix>-<random suffix>."
  }
}

run "one_identity_provider_per_repository" {
  variables {
    gha_wif_enabled   = true
    gha_owner_id      = "1234"
    gha_allowed_repos = ["acme/infra", "acme/website"]
  }

  assert {
    condition     = output.identity_provider_github_ids == ["infra", "website"]
    error_message = "Each allowed repository gets a provider named after the repository."
  }
}

run "identity_provider_ids_fit_what_google_accepts" {
  variables {
    gha_wif_enabled   = true
    gha_owner_id      = "1234"
    gha_allowed_repos = ["acme/gcp-infra", "acme/app", "acme/My_Repo.js"]
  }

  assert {
    condition     = output.identity_provider_github_ids == ["gh-gcp-infra", "gh-app", "my-repo-js"]
    error_message = "A repository name Google would refuse as a provider id (reserved gcp- prefix, under 4 characters, other characters) is adjusted; the provider itself checks the result."
  }
}

run "network_on_request" {
  variables {
    vpc_create = true
    vpc_name   = "main"
  }

  assert {
    condition     = output.vpc_name == "main"
    error_message = "vpc_create makes the network named by vpc_name."
  }
}

run "public_access_prevention_is_validated" {
  command = plan

  variables {
    bucket_name_prefix              = "tf-states"
    bucket_public_access_prevention = "off"
  }

  expect_failures = [var.bucket_public_access_prevention]
}

run "apis_stay_enabled_when_removed_from_the_list" {
  command = plan

  module {
    source = "./modules/project"
  }

  variables {
    project_labels          = {}
    project_deletion_policy = "PREVENT"
    enable_apis             = ["cloudbilling.googleapis.com", "container.googleapis.com"]
  }

  assert {
    condition     = toset(keys(google_project_service.enabled_apis)) == toset(["cloudbilling.googleapis.com", "container.googleapis.com"])
    error_message = "One google_project_service per API."
  }
  assert {
    condition     = alltrue([for s in google_project_service.enabled_apis : s.disable_on_destroy == false])
    error_message = "Destroying an API's resource must not disable the API."
  }
  assert {
    condition     = google_project.this.auto_create_network == false
    error_message = "The project is created without the default network."
  }
}

run "editor_members_removed_by_default" {
  command = plan

  module {
    source = "./modules/service_account"
  }

  variables {
    project_id            = "example-1a2b3c4d"
    sa_id                 = "terraform-sa"
    sa_description        = "Terraform"
    sa_roles              = ["roles/storage.admin"]
    remove_editor_members = true
  }

  assert {
    condition     = length(google_project_iam_binding.remove_default_sa_access) == 1
    error_message = "The roles/editor binding exists by default."
  }
  assert {
    condition = toset(keys(google_project_iam_member.default_sa_roles)) == toset([
      "roles/resourcemanager.projectIamAdmin",
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountAdmin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/storage.admin",
    ])
    error_message = "The service account gets the module's own roles plus the caller's."
  }
}

run "editor_members_left_alone_on_request" {
  command = plan

  module {
    source = "./modules/service_account"
  }

  variables {
    project_id            = "example-1a2b3c4d"
    sa_id                 = "terraform-sa"
    sa_description        = "Terraform"
    sa_roles              = []
    remove_editor_members = false
  }

  assert {
    condition     = length(google_project_iam_binding.remove_default_sa_access) == 0
    error_message = "remove_editor_members = false creates no roles/editor binding."
  }
}

run "bucket_is_private_and_versioned_by_default" {
  command = plan

  module {
    source = "./modules/bucket"
  }

  variables {
    project_id                      = "example-1a2b3c4d"
    sa_email                        = "terraform-sa@example-1a2b3c4d.iam.gserviceaccount.com"
    bucket_name_prefix              = "tf-states"
    bucket_location                 = "europe-west1"
    bucket_force_destroy            = false
    bucket_versioning               = true
    bucket_uniform_access           = true
    bucket_public_access_prevention = "enforced"
    bucket_labels                   = {}
    gcs_backend                     = false
  }

  assert {
    condition     = google_storage_bucket.tf_states[0].uniform_bucket_level_access == true
    error_message = "Access to the state bucket goes through IAM only."
  }
  assert {
    condition     = google_storage_bucket.tf_states[0].public_access_prevention == "enforced"
    error_message = "The state bucket can't be made public."
  }
  assert {
    condition     = google_storage_bucket.tf_states[0].versioning[0].enabled == true
    error_message = "The state bucket keeps object versions."
  }
  assert {
    condition     = length(local_file.gcs_backend) == 0
    error_message = "No backend.tf is written unless gcs_backend is set."
  }
}

run "backend_file_only_with_a_bucket" {
  command = plan

  module {
    source = "./modules/bucket"
  }

  variables {
    project_id                      = "example-1a2b3c4d"
    sa_email                        = "terraform-sa@example-1a2b3c4d.iam.gserviceaccount.com"
    bucket_name_prefix              = ""
    bucket_location                 = "europe-west1"
    bucket_force_destroy            = false
    bucket_versioning               = true
    bucket_uniform_access           = true
    bucket_public_access_prevention = "enforced"
    bucket_labels                   = {}
    gcs_backend                     = true
  }

  assert {
    condition     = length(google_storage_bucket.tf_states) == 0 && length(local_file.gcs_backend) == 0
    error_message = "Without a bucket prefix there is no bucket and no backend.tf, whatever gcs_backend says."
  }
  assert {
    condition     = length(google_project_iam_member.default_sa_roles) == 0
    error_message = "Without a bucket the service account gets no storage role."
  }
}

run "identity_provider_is_limited_to_its_repository_and_owner" {
  command = plan

  module {
    source = "./modules/gha_wif"
  }

  variables {
    project_id        = "example-1a2b3c4d"
    sa_name           = "projects/example-1a2b3c4d/serviceAccounts/terraform-sa@example-1a2b3c4d.iam.gserviceaccount.com"
    sa_email          = "terraform-sa@example-1a2b3c4d.iam.gserviceaccount.com"
    gha_wif_enabled   = true
    gha_owner_id      = "1234"
    gha_allowed_repos = ["acme/infra"]
  }

  assert {
    condition = alltrue([
      strcontains(google_iam_workload_identity_pool_provider.github_repos["acme/infra"].attribute_condition, "attribute.repository == \"acme/infra\""),
      strcontains(google_iam_workload_identity_pool_provider.github_repos["acme/infra"].attribute_condition, "attribute.repository_owner_id == \"1234\""),
    ])
    error_message = "A provider accepts tokens only from its repository, owned by the given owner id."
  }
  assert {
    condition     = google_iam_workload_identity_pool_provider.github_repos["acme/infra"].attribute_mapping["attribute.ref"] == "assertion.ref"
    error_message = "The token's ref is mapped, so a caller can bind one branch."
  }
  assert {
    condition     = google_iam_workload_identity_pool_provider.github_repos["acme/infra"].oidc[0].issuer_uri == "https://token.actions.githubusercontent.com"
    error_message = "The issuer is GitHub Actions."
  }
}
