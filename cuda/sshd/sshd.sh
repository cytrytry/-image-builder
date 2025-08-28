#!/bin/bash

# SSH_PASSWORD="1234567890"
# SSH_PUBLIC_KEY=


# for old version
if [ "$PUBLIC_KEY" != "" ] && [ "$SSH_PUBLIC_KEY" == "" ]; then
    SSH_PUBLIC_KEY="$PUBLIC_KEY"
fi

if [ "$SSH_PUBLIC_KEY" != "" ] && [ ! -e "/root/.ssh/authorized_keys" ]; then
    mkdir -p "/root/.ssh"
    chmod 700 -R "/root/.ssh"
    echo "$SSH_PUBLIC_KEY" >> "/root/.ssh/authorized_keys"
fi

if [ "$SSH_PASSWORD" != "" ] && [ $(cat /etc/shadow | grep "^root:[^*]" | wc -l) == "0" ]; then
    echo "root:$SSH_PASSWORD" | chpasswd
fi

if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
fi

if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
fi

if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
fi

if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
fi

exec /usr/sbin/sshd -D
