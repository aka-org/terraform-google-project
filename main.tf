module "project" {
  source                  = "./modules/project"
  project_name            = var.project_name
  project_labels          = var.project_labels
  project_deletion_policy = var.project_deletion_policy
  billing_account_id      = var.billing_account_id
}

module "apis" {
  source      = "./modules/apis"
  project_id  = module.project.project_id
  enable_apis = var.enable_apis
  depends_on  = [module.project]
}

module "bucket" {
  source      = "./modules/bucket"
  project_id  = module.project.project_id
  bucket      = var.bucket
  gcs_backend = var.gcs_backend
  depends_on  = [module.apis]
}

module "service_accounts" {
  source           = "./modules/service_accounts"
  project_id       = module.project.project_id
  service_accounts = var.service_accounts
  depends_on = [
    module.apis,
    module.bucket
  ]
}

module "gha_wif" {
  source          = "./modules/gha_wif"
  project_id      = module.project.project_id
  sa_ids          = module.service_accounts.sa_ids
  gha_wif_enabled = var.gha_wif_enabled
  gha_wif_sa      = var.gha_wif_sa
  gha_wif_org     = var.gha_wif_org
  gha_wif_repo    = var.gha_wif_repo
  depends_on = [
    module.apis,
    module.bucket,
    module.service_accounts
  ]
}

module "vpc" {
  source     = "./modules/vpc"
  project_id = module.project.project_id
  create_vpc = var.create_vpc
  vpc_name   = var.vpc_name
  depends_on = [
    module.apis,
    module.bucket
  ]
}
