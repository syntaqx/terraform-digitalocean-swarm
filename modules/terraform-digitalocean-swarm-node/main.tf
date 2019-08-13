locals {
  node_type = var.node_type == "manager" ? "manager" : "worker"
}
data "digitalocean_image" "docker" {
  slug = "docker-18-04"
}

data "template_file" "docker_user_data" {
  template = file("${path.module}/templates/user_data.yml")
}

data "template_cloudinit_config" "docker" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.docker_user_data.rendered
  }
}

resource "digitalocean_droplet" "node" {
  count     = var.node_count
  name      = format("%s-%s-%02d", var.name, local.node_type, count.index + var.node_count_start)
  region    = var.region
  image     = data.digitalocean_image.docker.id
  size      = var.size
  tags      = var.tags
  ssh_keys  = var.ssh_keys
  user_data = data.template_cloudinit_config.docker.rendered

  private_networking = true
  monitoring         = var.enable_monitoring
  backups            = var.enable_backups

  connection {
    host        = self.ipv4_address
    type        = lookup(var.connection, "type", "ssh")
    agent       = lookup(var.connection, "agent", false)
    timeout     = lookup(var.connection, "timeout", "2m")
    user        = lookup(var.connection, "user", "root")
    password    = lookup(var.connection, "password", null)
    private_key = lookup(var.connection, "private_key", null)
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
