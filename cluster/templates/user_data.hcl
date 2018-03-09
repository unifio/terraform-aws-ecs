#cloud-config
manage_etc_hosts: True
bootcmd:
  - [ cloud-init-per, instance, docker_storage_setup, /usr/bin/docker-storage-setup ]
  - service docker restart

write_files:
  - path: /etc/ecs/ecs.config
    permissions: '0644'
    content: |
      ECS_CLUSTER=${cluster_label}-${stack_item_label}

runcmd:
  - restart ecs
output : { all : '| tee -a /var/log/cloud-init-output.log' }
