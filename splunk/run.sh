#!/bin/bash
#
# This script will be run at run-time by the docker instance
#


#
# Install Splunk
#
echo "# "
echo "# Installing Splunk..."
echo "# "
dpkg -i /data-install/splunk.deb

#
# Run Splunk in the foreground
#
echo "# "
echo "# Running Splunk in the foreground..."
echo "# "
/var/splunk/bin/splunk --accept-license start --nodaemon



