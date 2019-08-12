locals {
  worker_count = var.cluster_size
  worker_size  = var.instance_size
}

resource "digitalocean_droplet" "worker" {
  count     = local.worker_count
  name      = format("worker-%02d-%s", count.index + 1, var.cluster_name)
  region    = var.region
  image     = data.digitalocean_image.docker.id
  size      = local.worker_size
  ssh_keys  = [digitalocean_ssh_key.swarm.id]
  user_data = data.template_cloudinit_config.docker.rendered

  private_networking = true
  monitoring         = false # @TODO: true
  backups            = false # @TODO: true

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

resource "null_resource" "swarm_worker_join" {
  count = length(digitalocean_droplet.worker[*])

  connection {
    agent       = false
    timeout     = "2m"
    host        = digitalocean_droplet.worker[count.index].ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.tokens.result.worker} ${digitalocean_droplet.leader.ipv4_address_private}",
    ]
  }
}
