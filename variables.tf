variable "cluster_name" {
  description = "Cluster name to idenity resources with"
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

variable "cluster_size" {
  description = "Number of worker nodes in the Swarm (0-1000)"
  type        = number
  default     = 5
}

variable "instance_size" {
  description = "Droplet instance size"
  type        = string
  default     = "s-1vcpu-1gb"
}

# variable "worker_disk_size" {
#   description = "Size of Worker's ephemeral storage volume in GiB (20-1024)"
#   type = number
#   default  = 20
# }

# variable "worker_disk_type" {
#   description = "Worker ephemeral storage volume type"
#   type = string
#   default = "standard"
# }

# https://docs.docker.com/engine/swarm/admin_guide/#add-manager-nodes-for-fault-tolerance
variable "manager_size" {
  description = "Number of Swarm manager nodes (1, 3, 5, 7, 9)"
  type        = number
  default     = 3
}

variable "manager_instance_size" {
  description = "Manager Droplet instance size"
  type        = string
  default     = "s-1vcpu-1gb"
}

# variable "manager_disk_size" {
#   description = "Size of Manager's ephemeral storage volume in GiB"
#   type = number
#   default = 20
# }

# variable "manager_disk_type" {
#   description = "Manager's ephemeral storage volume type"
#   type = string
#   default = "standard"
# }

variable "enable_monitoring" {
  description = "Boolean controlling whether monitoring agent is installed"
  type        = bool
  default     = true
}

variable "enable_backups" {
  description = "Boolean controlling whether manager backups are enabled"
  type        = bool
  default     = true
}

variable "output_dir" {
  description = "File output parent directory"
  type        = string
  default     = "/tmp"
}
