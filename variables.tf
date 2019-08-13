variable "cluster_name" {
  description = "Unique name of the cluster"
  type        = string
}

variable "region" {
  description = "Region in which to create resources"
  type        = string
  default     = "nyc3"
}

variable "tags" {
  description = "A list of the tags to be applied to cluster resources"
  type        = list(any)
  default     = []
}

variable "ssh_keys" {
  description = "A list of SSH IDs or fingerprints to enable for resources"
  type        = list(any)
  default     = []
}

variable "worker_count" {
  description = "Number of worker nodes in the Swarm (0-1000)"
  type        = number
  default     = 5
}

variable "worker_size" {
  description = "Worker Droplet instance size"
  type        = string
  default     = "s-1vcpu-1gb"
}

# https://docs.docker.com/engine/swarm/admin_guide/#add-manager-nodes-for-fault-tolerance
variable "manager_count" {
  description = "Number of manager nodes in the Swarm (1, 3, 5, 7, 9), even numbers are rounded down"
  type        = number
  default     = 3
}

variable "manager_size" {
  description = "Manager Droplet instance size"
  type        = string
  default     = "s-1vcpu-1gb"
}

# variable "enable_system_prune" {
#   description = "Cleans up unused images, containers, networks and volumes"
#   type        = bool
#   default     = true
# }

variable "enable_monitoring" {
  description = "Install the DigitalOcean monitoring agent"
  type        = bool
  default     = true
}

variable "enable_backups" {
  description = "Automatically backup manager nodes"
  type        = bool
  default     = true
}

variable "output_dir" {
  description = "File output parent directory"
  type        = string
  default     = "./tmp" # /tmp seems broken?
}
