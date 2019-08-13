locals {
  manager_count     = min(max(var.manager_count, 1), 9) - 1
  manager_count_odd = max(local.manager_count % 2 == 0 ? local.manager_count : local.manager_count - 1, 0)
  manager_size      = var.manager_size

  worker_count = min(max(var.worker_count, 0), 1000)
  worker_size  = var.worker_size
}

module "leader" {
  source = "./modules/node"

  name       = var.cluster_name
  region     = var.region
  node_count = 1
  node_type  = "manager"
  size       = local.manager_size
  tags       = var.tags
  ssh_keys   = concat([digitalocean_ssh_key.swarm.id], var.ssh_keys)

  enable_monitoring = var.enable_monitoring
  enable_backups    = var.enable_backups

  connection = {
    agent       = false
    private_key = tls_private_key.generated.private_key_pem
  }
}

module "manager" {
  source = "./modules/node"

  node_count       = local.manager_count_odd
  node_count_start = 2
  node_type        = "manager"

  name     = var.cluster_name
  region   = var.region
  size     = local.manager_size
  tags     = var.tags
  ssh_keys = concat([digitalocean_ssh_key.swarm.id], var.ssh_keys)

  enable_monitoring = var.enable_monitoring
  enable_backups    = var.enable_backups

  connection = {
    agent       = false
    private_key = tls_private_key.generated.private_key_pem
  }
}

module "worker" {
  source = "./modules/node"

  node_type  = "worker"
  node_count = local.worker_count

  name     = var.cluster_name
  region   = var.region
  size     = local.worker_size
  tags     = var.tags
  ssh_keys = concat([digitalocean_ssh_key.swarm.id], var.ssh_keys)

  enable_monitoring = var.enable_monitoring

  connection = {
    agent       = false
    private_key = tls_private_key.generated.private_key_pem
  }
}

locals {
  leader = element(module.leader.nodes, 0)
}

resource "null_resource" "swarm_init" {
  connection {
    agent       = false
    timeout     = "2m"
    host        = local.leader.ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm init --advertise-addr ${local.leader.ipv4_address_private}",
    ]
  }
}

data "external" "tokens" {
  program = ["bash", "${path.module}/scripts/swarm_get_tokens.sh"]

  query = {
    host     = local.leader.ipv4_address
    user     = "root"
    identity = local_file.swarm_private_key.filename
  }

  depends_on = [
    null_resource.swarm_init,
  ]
}

resource "null_resource" "swarm_node" {
  count = length(module.manager.nodes)

  connection {
    agent       = false
    timeout     = "2m"
    host        = module.manager.nodes[count.index].ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      format(
        "docker swarm join --advertise-addr %s --token %s %s",
        module.manager.nodes[count.index].ipv4_address,
        data.external.tokens.result.manager,
        local.leader.ipv4_address_private,
      )
    ]
  }
}

resource "null_resource" "swarm_join_worker" {
  count = length(module.worker.nodes)

  connection {
    agent       = false
    timeout     = "2m"
    host        = module.worker.nodes[count.index].ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      format(
        "docker swarm join --advertise-addr %s --token %s %s",
        module.worker.nodes[count.index].ipv4_address,
        data.external.tokens.result.worker,
        local.leader.ipv4_address_private,
      )
    ]
  }
}
