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
LOG="/splunk-logs/output.txt"


#
# cd to the directory that this script is in
#
pushd $(dirname $0) > /dev/null
DIR=$(pwd)

#
# Loop through all indexers and get a comma delimted list of IPs
#
IPS=""
for IP in $(set |grep INDEXER |grep 8089 |grep ADDR |cut -d= -f2)
do
	if test "$IPS"
	then
		IPS="${IPS},"
	fi

	IPS="${IPS}${IP}"

done

if test "${IPS}" 
then
	echo "# "
	echo "# Found the following Indexers: ${IPS}"
	echo "# Writing them to outputs.conf and distsearch.conf..."
	echo "# "
	cat outputs.conf.template | sed -e s/%IPS%/${IPS}/ > outputs.conf
	cat distsearch.conf.template | sed -e s/%IPS%/${IPS}/ > distsearch.conf
fi


#
# Install Splunk
#
echo "# "
echo "# Installing Splunk..."
echo "# "
dpkg -i splunk.deb 2>&1 | tee -a ${LOG}


echo "# "
echo "# Setting up symlinks for Splunk logs to /splunk-logs/, which is exported from Docker"
echo "# "
/var/splunk/bin/splunk --accept-license status 2>&1 | tee -a ${LOG}
rm -rf /opt/splunk/var/log
ln -s /splunk-logs/ /opt/splunk/var/log

#
# Copy in configuration settings
#
cp distsearch.conf /opt/splunk/etc/system/local
cp inputs.conf /opt/splunk/etc/system/local
cp outputs.conf /opt/splunk/etc/system/local
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


