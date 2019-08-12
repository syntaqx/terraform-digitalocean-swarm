resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "swarm" {
  name       = format("%s-swarm", var.cluster_name)
  public_key = tls_private_key.generated.public_key_openssh
}

resource "local_file" "swarm_private_key" {
  filename          = format("%s/output/.ssh/%s", path.module, var.cluster_name)
  sensitive_content = tls_private_key.generated.private_key_pem
}

resource "local_file" "swarm_public_key" {
  filename          = format("%s/output/.ssh/%s.pub", path.module, var.cluster_name)
  sensitive_content = tls_private_key.generated.public_key_openssh
}
