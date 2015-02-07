#!/bin/bash
#
# Provision our Vagrant instance
#


#
# Set up our swapfile
#
# The instructions for setting up a swapfile I borrowed from the excellent writeup at:
#	https://github.com/coreos/docs/issues/52
#

#
# Create our swapfile
#
fallocate -l 1024m /media/state/swapfile
chmod 600 /media/state/swapfile
mkswap /media/state/swapfile

#
# Write our service file
#
cat > /media/state/units/swapon.service << EOF
[Unit]
Description=Turn on swap

[Service]
Type=oneshot
ExecStart=/sbin/swapon /media/state/swapfile

[Install]
WantedBy=local.target

EOF

#
# Enable startup of our service, and start it manually this time
#
systemctl enable --runtime /media/state/units/swapon.service
systemctl start swapon



