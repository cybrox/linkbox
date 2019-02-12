FROM alpine:3.9
MAINTAINER Sven Gehring <cbrxde@gmail.com>

# Install dependencies
RUN apk update
RUN apk add bash
RUN apk add openssh
RUN apk add openrc

# Start sshd on boot
RUN rc-update add sshd

# Add authorized key file for linkbox
ADD authorized_keys /home/linkbox/.ssh/

# Add our helper script for connecting to the tunnel
ADD linkbox /usr/local/bin
ADD private_key /home/linkbox

# Copy entrypoint file and set entrypoint
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["entrypoint.sh"]
