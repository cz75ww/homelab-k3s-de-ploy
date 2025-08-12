## Make sure ssh connections from virtual machines are available

# Wait for SSH to be ready
resource "null_resource" "wait_for_ssh_nfs-server" {
  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash
set -e
echo "Waiting for SSH to be available at ${var.nfs-server_ip_address}..."
until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${var.nfs-server_ip_address} 'echo SSH is ready' >/dev/null 2>&1; do
  echo "SSH not ready, retrying in 5 seconds..."
  sleep 5
done
echo "SSH is ready!"
EOT
  }

  depends_on = [
    libvirt_domain.domain-nfs-server
  ]
}

# Wait for SSH to be ready
resource "null_resource" "wait_for_ssh_controlplane" {
  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash
set -e
echo "Waiting for SSH to be available at ${var.controlplane_ip_address}..."
until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${var.controlplane_ip_address} 'echo SSH is ready' >/dev/null 2>&1; do
  echo "SSH not ready, retrying in 5 seconds..."
  sleep 5
done
echo "SSH is ready!"
EOT
  }

  depends_on = [
    libvirt_domain.domain-controlplane
  ]
}



resource "null_resource" "wait_for_ssh_nodes" {
  for_each = var.nodes

  provisioner "local-exec" {
    command = <<EOT
#!/bin/bash
set -e
echo "Waiting for SSH to be available at ${each.value.static_ip} (node: ${each.value.hostname})..."
until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${each.value.static_ip} 'echo SSH is ready' >/dev/null 2>&1; do
  echo "SSH not ready for ${each.value.hostname}, retrying in 5 seconds..."
  sleep 5
done
echo "SSH is ready on node ${each.value.hostname}!"
EOT
  }

  depends_on = [
    libvirt_domain.node
  ]
}

## Running Ansible

# Generate dynamic Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    nfs-server   = var.nfs-server_ip_address
    controlplane = var.controlplane_ip_address
    nodes        = var.nodes
  })
  filename = "${path.module}/kubernetes/hosts.ini"
}


resource "null_resource" "running_ansible" {
  triggers = {
    # playbook_checksum = filesha1(var.playbook)
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${local_file.ansible_inventory.filename} --private-key ${var.key_path} -u ubuntu --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ${var.playbook} -vv"
  }
  depends_on = [
    local_file.ansible_inventory,
    null_resource.wait_for_ssh_nfs-server,
    null_resource.wait_for_ssh_controlplane,
    null_resource.wait_for_ssh_nodes
  ]
}