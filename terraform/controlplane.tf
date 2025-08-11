resource "libvirt_pool" "controlplane" {
  name = "controlplane"
  type = "dir"
  target {
    path = "/home/fpsouza/class/vm-settings/disks/controlplane"
  }

   depends_on = [
    libvirt_domain.domain-nfs-server
  ]
}

# Base Ubuntu cloud image
resource "libvirt_volume" "controlplane_base" {
  name   = "controlplane-base"
  pool   = libvirt_pool.controlplane.name
  source = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  format = "qcow2"

  depends_on = [
    libvirt_pool.controlplane
  ]
}

# Resized root filesystem based on the base image
resource "libvirt_volume" "controlplane_rootfs" {
  name           = "controlplane-22.04-rootfs.qcow2"
  pool           = libvirt_pool.controlplane.name
  base_volume_id = libvirt_volume.controlplane_base.id
  size           = 10737418240  # 10 GB
  format         = "qcow2"

  depends_on = [
    libvirt_volume.controlplane_rootfs
  ]
}

data "template_file" "user_data_controlplane" {
  template = file("${path.module}/cloud-init/cloud_init.cfg")
}

data "template_file" "net_controlplane_cfg" {
  template = file("${path.module}/cloud-init/net_controlplane.cfg")
}

# Cloud-init ISO
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data_controlplane.rendered
  network_config = data.template_file.net_controlplane_cfg.rendered
  pool           = libvirt_pool.controlplane.name

 
 



}

# Virtual machine definition
resource "libvirt_domain" "domain-controlplane" {
  name   = "controlplane"
  memory = 2048 #2GB
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

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
    volume_id = libvirt_volume.controlplane_rootfs.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  depends_on = [
    libvirt_domain.domain-nfs-server
  ]
}


