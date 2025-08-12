variable "controlplane_ip_address" {
  type        = string
  default     = "192.168.122.100"
  description = "The IP address of the K3s control plane node."
}

variable "nfs-server_ip_address" {
  type        = string
  default     = "192.168.122.130"
  description = "The IP address of the nfs server."
}


variable "nodes" {
  description = "Map of node settings"
  type = map(object({
    hostname  = string
    static_ip = string
    net_cfg   = string # Just the relative filename
  }))
  default = {
    node01 = {
      hostname  = "node01"
      static_ip = "192.168.122.110"
      net_cfg   = "cloud-init/net_node01.cfg"
    }
    node02 = {
      hostname  = "node02"
      static_ip = "192.168.122.120"
      net_cfg   = "cloud-init/net_node02.cfg"
    }
  }
}


variable "key_path" {
  type        = string
  default     = "/home/kube-user/.ssh/id_rsa"
  description = "Path to the private SSH key used to connect to the remote host."
}

variable "playbook" {
  type        = string
  default     = "/home/kube-user/class/vm-settings/terraform/kubernetes/kubernetes.yml"
  description = "Path to the Ansible playbook that installs K3s."
}
