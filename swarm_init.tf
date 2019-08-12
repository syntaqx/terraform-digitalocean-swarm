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

resource "digitalocean_droplet" "leader" {
  name      = format("manager-1-%s", var.cluster_name)
  region    = var.region
  image     = data.digitalocean_image.docker.id
  size      = local.manager_size
  tags      = var.tags
  ssh_keys  = concat([digitalocean_ssh_key.swarm.id], var.ssh_keys)
  user_data = data.template_cloudinit_config.docker.rendered

  private_networking = true
  monitoring         = var.enable_monitoring
  backups            = var.enable_backups

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

resource "null_resource" "swarm_init" {
  triggers = {
    leader = digitalocean_droplet.leader.id
  }

  connection {
    agent       = false
    timeout     = "2m"
    host        = digitalocean_droplet.leader.ipv4_address
    user        = "root"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm init --advertise-addr ${digitalocean_droplet.leader.ipv4_address_private}",
    ]
  }
}

data "external" "tokens" {
  program = ["bash", "${path.module}/scripts/swarm_get_tokens.sh"]

  query = {
    host     = digitalocean_droplet.leader.ipv4_address
    user     = "root"
    identity = local_file.swarm_private_key.filename
  }

  depends_on = [
    null_resource.swarm_init
  ]
}
