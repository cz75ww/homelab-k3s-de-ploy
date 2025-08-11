[nfs-server]
${nfs-server}

[controlplane]
${controlplane}

[nodes]
%{ for node in nodes ~}
${node.static_ip} ansible_host=${node.static_ip} hostname=${node.hostname}
%{ endfor ~}
