output "leader" {
  value = digitalocean_droplet.leader
}

output "tokens" {
  value = {
    manager = data.external.tokens.result.manager
    worker  = data.external.tokens.result.worker
  }
}

output "managers" {
  value = digitalocean_droplet.manager
}

output "workers" {
  value = digitalocean_droplet.worker
}
