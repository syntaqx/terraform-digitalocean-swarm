locals {
  manager_count     = min(max(var.manager_count, 1), 9) - 1
  manager_count_odd = max(local.manager_count % 2 == 0 ? local.manager_count : local.manager_count - 1, 0)
  manager_size      = var.manager_size
}

resource "digitalocean_droplet" "manager" {
  count     = local.manager_count_odd
  name      = format("%s-manager-%d", var.cluster_name, count.index + 2)
  region    = var.region
  image     = data.digitalocean_image.docker.id
  size      = local.manager_size
  tags      = var.tags
  ssh_keys  = concat([digitalocean_ssh_key.swarm.id], var.ssh_keys)
  user_data = data.template_cloudinit_config.docker.rendered

  private_networking = true
  monitoring         = var.enable_monitoring # @TODO: true
  backups            = var.enable_backups    # @TODO: true

  connection {
    agent       = false
    timeout     = "2m"
    host        = self.ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  # https://www.packer.io/docs/other/debugging.html#issues-installing-ubuntu-packages
  provisioner "remote-exec" {
    script = "${path.module}/scripts/wait_for_cloud_init.sh"
  }

  provisioner "file" {
    source      = "${path.module}/files/etc/"
    destination = "/etc"
  }
}

resource "null_resource" "swarm_manager_join" {
  count = length(digitalocean_droplet.manager[*])

  connection {
    agent       = false
    timeout     = "2m"
    host        = digitalocean_droplet.manager[count.index].ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.tokens.result.manager} ${digitalocean_droplet.leader.ipv4_address_private}",
    ]
  }
}
