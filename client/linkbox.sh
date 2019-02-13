#!/bin/bash
#
# Description: Linkbox client setup script for Raspberry Pi
# Maintainer: Sven Gehring <cbrxde@gmail.com>

REMOTE_HOST="$1"
if [[ "$REMOTE_HOST" == "" ]]; then
  echo "LINKBOX: Expected remote host as argument 1"
  exit 1
fi

# Remove known hosts since we don't care about identity
rm -f /root/.ssh/known_hosts
rm -f ~/.ssh/known_hosts

# Set proper permission for server private key
chmod 700 ./private_key

# Connect to remote host
ssh \
  -o StrictHostKeyChecking=no \
  -p 10666 \
  -l linkbox \
  -i ./private_key \
  -f -N -T -R 10022:localhost:22 "$REMOTE_HOST"
