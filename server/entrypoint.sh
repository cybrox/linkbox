#!/bin/bash
#
# Description: Linkbox docker server entrypoint
# Maintainer: Sven Gehring <cbrxde@gmail.com>


# Encrypted password for linkbox account
LINKBOX_PASS="\$6\$h6UlR9hLiXgsnzXy\$7J9Ur9AoZnUzoV4RdfRLECSVue23UfdWeiuzV9StSKeUo9cKoWu9KpY\/8hBshdl6YCg5djhiM8Qmu\/ImpbL5e."


# Generate new rsa key if it doesn't exist
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi

# Generate new dsa key if it doesn't exist
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

# Create run directory for sshd
mkdir -p /var/run/sshd

# Allow TCP forwarding in sshd config
# This is required for establishing a reverse ssh connection
sed -i "s/AllowTcpForwarding no/AllowTcpForwarding yes/g" /etc/ssh/sshd_config

# Ensure our private key permissions are not too open
chmod 700 /home/linkbox/private_key

# Start ssh daemon
/usr/sbin/sshd

# Create a user for linkbox and set password
adduser -h /home/linkbox -s /bin/bash -S linkbox
sed -i "s/linkbox:!:/linkbox:$LINKBOX_PASS:/g" /etc/shadow

# Run passed command
exec "$@"

