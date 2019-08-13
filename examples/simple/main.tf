provider "digitalocean" {
}

module "swarm" {
  source = "../.."

  cluster_name = "example"

  manager_count = 1 # 1 manager will always be deployed
  worker_count  = 0

  output_dir = "${path.module}/tmp"
}
