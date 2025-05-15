resource "google_compute_network" "vpc" {
  count = var.create_vpc ? 1 : 0

  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
}
