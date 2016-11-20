#cloud-config
manage_etc_hosts: True
bootcmd:
  - [ cloud-init-per, instance, docker_storage_setup, /usr/bin/docker-storage-setup ]
  - service docker restart

runcmd:
  # Set hostname and tag based on instance-id
  - echo "${cluster_name}-${stack_item_label}-`curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-'`" > /etc/hostname
  - hostname -F /etc/hostname
  - sed -i "s/^127.0.0.1 ip-.*$/127.0.0.1 `hostname`.${domain} `hostname`/" /etc/hosts
  - sed -i "s/^::1 ip-.*$/::1 `hostname`.${domain} `hostname`/" /etc/hosts
  - /usr/local/bin/aws ec2 create-tags --region=${region} --resources `curl http://169.254.169.254/latest/meta-data/instance-id` --tags Key=Name,Value=`hostname`
  # Configure ECS
  - 'echo -e "${ecs_config}" > /etc/ecs/ecs.config'
  - restart ecs
output : { all : '| tee -a /var/log/cloud-init-output.log' }
