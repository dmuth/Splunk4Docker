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
# cd to the directory that this script is in
#
pushd $(dirname $0) > /dev/null

#
# Install Splunk
#
if test ! -f /opt/splunk/bin/splunk
then
	echo "# "
	echo "# Installing Splunk..."
	echo "# "
	dpkg -i splunk.deb 2>&1 | tee -a ${LOG}

else
	echo "# "
	echo "# Splunk is already installed, skipping installation."
	echo "# "

fi


echo "# "
echo "# Setting up symlinks for Splunk logs and data to /splunk-data/, which is exported from Docker"
echo "# "

#
# Make our symlinks to /splunk-data/ first, and do it in $SPLUNK_HOME/var/,
# as Splunk does funny things with symlinks elsewhere when installing it.
#
mkdir -p /opt/splunk/
ln -sf /splunk-data/ /opt/splunk/var
/var/splunk/bin/splunk --accept-license status 2>&1 | tee -a ${LOG}


#
# Copy in configuration settings
#
cp passwd /opt/splunk/etc/passwd
cp inputs.conf /opt/splunk/etc/system/local
cp server.conf /opt/splunk/etc/system/local
mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
cp user-prefs.conf /opt/splunk/etc/users/admin/user-prefs/local

#
# Run Splunk in the foreground
#
echo "# "
echo "# Running Splunk in the foreground..."
echo "# "
/var/splunk/bin/splunk --accept-license start --nodaemon 2>&1 | tee -a ${LOG}


