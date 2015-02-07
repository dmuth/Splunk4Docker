#!/bin/bash
#
# This script will be run at run-time by the docker instance
#

#
# Errors are fatal
#
set -e

#
# Where to log our command output.
#
LOG="/splunk-data/output.txt"


#
# Install Splunk
#
echo "# "
echo "# Installing Splunk..."
echo "# "
dpkg -i /data-install/splunk.deb 2>&1 | tee -a ${LOG}


echo "# "
echo "# Setting up symlinks for Splunk logs and data to /splunk-data/, which is exported from Docker"
echo "# "

#
# Make our symlinks to /splunk-data/ first, and do it in $SPLUNK_HOME/var/,
# as Splunk does funny things with symlinks elsewhere when installing it.
#
mkdir -p /opt/splunk/
ln -s /splunk-data/ /opt/splunk/var
/var/splunk/bin/splunk --accept-license status 2>&1 | tee -a ${LOG}


#
# Copy in configuration settings
#
cp /data-install/passwd /opt/splunk/etc/passwd
cp /data-install/inputs.conf /opt/splunk/etc/system/local
cp /data-install/server.conf /opt/splunk/etc/system/local
mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
cp /data-install/user-prefs.conf /opt/splunk/etc/users/admin/user-prefs/local

#
# Run Splunk in the foreground
#
echo "# "
echo "# Running Splunk in the foreground..."
echo "# "
/var/splunk/bin/splunk --accept-license start --nodaemon 2>&1 | tee -a ${LOG}


