variable "name" {
  description = "Name of the node and corresponding resources"
  type        = string
}

variable "region" {
  description = "Region in which to create resources"
  type        = string
  default     = "nyc3"
}

variable "node_type" {
  description = "Node type (worker, manager)"
  type        = string
  default     = "worker"
}

variable "node_count" {
  description = "Node count"
  type        = string
  default     = 1
}

variable "node_count_start" {
  description = "Node count start number"
  type        = string
  default     = 1
}

variable "size" {
  description = "Droplet instance size"
  type        = string
  default     = "s-1vcpu-1gb"
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

variable "connection" {
  description = "SSH remote execution provisioner connection information"
  type        = map
  default = {
    type        = "ssh"
    agent       = false
    timeout     = "2m"
    user        = "root"
    password    = null
    private_key = ""
  }
}

variable "enable_monitoring" {
  description = "Install the DigitalOcean monitoring agent"
  type        = bool
  default     = false
}

variable "enable_backups" {
  description = "Automatically backup manager nodes"
  type        = bool
  default     = false
}
