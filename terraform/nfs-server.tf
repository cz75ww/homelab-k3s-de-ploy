terraform {
  required_version = ">= 0.13"

  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "nfs-server" {
  name = "nfs-server"
  type = "dir"
  target {
    path = "/home/fpsouza/class/vm-settings/disks/nfs-server"
  }
}

# Base Ubuntu cloud image
resource "libvirt_volume" "nfs-server_base" {
  name   = "nfs-server-base"
  pool   = libvirt_pool.nfs-server.name
  source = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Resized root filesystem based on the base image
resource "libvirt_volume" "nfs-server_rootfs" {
  name           = "nfs-server-22.04-rootfs.qcow2"
  pool           = libvirt_pool.nfs-server.name
  base_volume_id = libvirt_volume.nfs-server_base.id
  size           = 10737418240 # 10 GB
  format         = "qcow2"
}

#data disk for NFS storage
resource "libvirt_volume" "nfs-server_data" {
  name   = "nfs-server-data.qcow2"
  pool   = libvirt_pool.nfs-server.name
  size   = 10737418240 # 10 GB
  format = "qcow2"
}

data "template_file" "user_data_nfs-server" {
  template = file("${path.module}/cloud-init/cloud_init.cfg")
}

data "template_file" "net_nfs-server_cfg" {
  template = file("${path.module}/cloud-init/net_nfs-server.cfg")
}

# Cloud-init ISO
resource "libvirt_cloudinit_disk" "nfscommoninit" {
  name           = "nfscommoninit.iso"
  user_data      = data.template_file.user_data_nfs-server.rendered
  network_config = data.template_file.net_nfs-server_cfg.rendered
  pool           = libvirt_pool.nfs-server.name
}

# Virtual machine definition
resource "libvirt_domain" "domain-nfs-server" {
  name   = "nfs-server"
  memory = 2048 #2GB
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.nfscommoninit.id

  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }

  disk {
    volume_id = libvirt_volume.nfs-server_rootfs.id
  }

  # Data disk
  disk {
    volume_id = libvirt_volume.nfs-server_data.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

