
locals {
  default_apis = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com"
  ]
  enable_apis = concat(
    local.default_apis,
    var.enable_apis,
    var.vpc_create ? [
      "compute.googleapis.com"
    ] : [],
    var.bucket_name_prefix != "" ? [
      "storage.googleapis.com"
    ] : []
  )
}

module "project" {
  source                  = "./modules/project"
  project_name            = var.project_name
  project_labels          = var.project_labels
  project_deletion_policy = var.project_deletion_policy
  enable_apis             = local.enable_apis
  billing_account_id      = var.billing_account_id
}

module "service_account" {
  source         = "./modules/service_account"
  project_id     = module.project.project_id
  sa_id          = var.sa_id
  sa_description = var.sa_description
  sa_roles       = var.sa_roles
  depends_on     = [module.project]
}

module "bucket" {
  source               = "./modules/bucket"
  project_id           = module.project.project_id
  sa_email             = module.service_account.sa_email
  bucket_name_prefix   = var.bucket_name_prefix
  bucket_location      = var.bucket_location
  bucket_force_destroy = var.bucket_force_destroy
  bucket_versioning    = var.bucket_versioning
  bucket_labels        = var.bucket_labels
  gcs_backend          = var.gcs_backend
  depends_on = [
    module.project,
    module.service_account
  ]
}

module "gha_wif" {
  source            = "./modules/gha_wif"
  project_id        = module.project.project_id
  sa_name           = module.service_account.sa_name
  sa_email          = module.service_account.sa_email
  gha_wif_enabled   = var.gha_wif_enabled
  gha_owner_id      = var.gha_owner_id
  gha_allowed_repos = var.gha_allowed_repos
  depends_on = [
    module.project,
    module.service_account
  ]
}

module "vpc" {
  source     = "./modules/vpc"
  project_id = module.project.project_id
  sa_email   = module.service_account.sa_email
  vpc_create = var.vpc_create
  vpc_name   = var.vpc_name
  depends_on = [
    module.project,
    module.service_account
  ]
}
