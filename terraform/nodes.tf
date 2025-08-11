# Deploy worker nodes
resource "libvirt_pool" "vm_pool" {
  name   = "vmpool"
  type   = "dir"
  target {
    path = "/home/fpsouza/class/vm-settings/disks/nodes"
  }

  depends_on = [
    libvirt_domain.domain-nfs-server,
    libvirt_domain.domain-controlplane
  ]
}

resource "libvirt_volume" "base_img" {
  for_each = var.nodes
  name     = "${each.key}-base"
  pool     = libvirt_pool.vm_pool.name
  source   = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img"
  format   = "qcow2"

  depends_on = [
    libvirt_pool.vm_pool
  ]
}

resource "libvirt_volume" "rootfs" {
  for_each       = var.nodes
  name           = "${each.key}-22.04-rootfs.qcow2"
  pool           = libvirt_pool.vm_pool.name
  base_volume_id = libvirt_volume.base_img[each.key].id
  size           = 10737418240  # 10 GB
  format         = "qcow2"

  depends_on = [
    libvirt_volume.base_img
  ]
}

data "template_file" "user_data_nodes" {
  for_each = var.nodes
  template = file("${path.module}/cloud-init/cloud_init.cfg")
}

data "template_file" "net_cfg" {
  for_each = var.nodes
  template = file("${path.module}/${each.value.net_cfg}")
}


resource "libvirt_cloudinit_disk" "init" {
  for_each       = var.nodes
  name           = "${each.key}-commoninit.iso"
  user_data      = data.template_file.user_data_nodes[each.key].rendered
  network_config = data.template_file.net_cfg[each.key].rendered
  pool           = libvirt_pool.vm_pool.name

  depends_on = [
    libvirt_domain.domain-nfs-server,
    libvirt_domain.domain-controlplane
  ]
}

resource "libvirt_domain" "node" {
  for_each = var.nodes

  name   = each.value.hostname
  memory = 2048
  vcpu   = 1
  cloudinit = libvirt_cloudinit_disk.init[each.key].id

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
    volume_id = libvirt_volume.rootfs[each.key].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

   depends_on = [
    libvirt_domain.domain-nfs-server,
    libvirt_domain.domain-controlplane
  ]
}


