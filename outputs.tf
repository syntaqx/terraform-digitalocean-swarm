output "leader" {
  value = module.leader.nodes[0]
}

output "tokens" {
  value = {
    manager = data.external.tokens.result.manager
    worker  = data.external.tokens.result.worker
  }
}

output "managers" {
  value = module.manager.nodes
}

output "workers" {
  value = module.worker.nodes
}
