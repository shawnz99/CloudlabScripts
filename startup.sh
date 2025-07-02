#!/bin/bash

# Variables
HOSTNAME=$(hostname -f | cut -d"." -f1)
HW_TYPE=$(geni-get manifest | grep $HOSTNAME | grep -oP 'hardware_type="\K[^"]*')
SHARED_HOME="/shome"
USERS="root `ls /users`"
NUM_CPUS=$(lscpu | grep '^CPU(s):' | awk '{print $2}')

# Setup password-less ssh between nodes
for user in $USERS; do
  if [ "$user" = "root" ]; then
    ssh_dir=/root/.ssh
  else
    ssh_dir=/users/$user/.ssh
  fi
  /usr/bin/geni-get key > $ssh_dir/id_rsa
  chmod 600 $ssh_dir/id_rsa
  chown $user: $ssh_dir/id_rsa
  ssh-keygen -y -f $ssh_dir/id_rsa > $ssh_dir/id_rsa.pub
  cat $ssh_dir/id_rsa.pub >> $ssh_dir/authorzed_keys
  chmod 644 $ssh_dir/authorized_keys
  cat >>$ssh_dir/config <<EOL
  Host *
    StrictHostKeyChecking no
EOL
    chmod 644 $ssh_dir/config
done

