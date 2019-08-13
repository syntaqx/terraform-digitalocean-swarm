provider "digitalocean" {
}

module "swarm" {
  source = "../.."

  cluster_name = "example"

  manager_count = 1
  worker_count  = 1

  output_dir = "${path.module}/tmp"
}
