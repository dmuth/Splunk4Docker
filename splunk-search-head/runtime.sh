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

#
# Loop through all indexers and get a comma delimted list of IPs
#
# Also, while in this loop, we're going to generate a script which will add 
# Indexers after Splunk starts
#
IPS=""
ADD_INDEXERS="./add-indexers.sh"
echo "#!/bin/bash" > ${ADD_INDEXERS}
echo "# " >> ${ADD_INDEXERS}
echo "# This script is auto-geneated by $0 -- DO NOT EDIT!" >> ${ADD_INDEXERS}
echo "# " >> ${ADD_INDEXERS}
chmod 755 ${ADD_INDEXERS}

for IP in $(set |grep INDEXER |grep 8089 |grep ADDR |cut -d= -f2)
do
	if test "$IPS"
	then
		IPS="${IPS},"
	fi

	IPS="${IPS}${IP}"

	#
	# Add the Indexers to our list of Search Peers.
	# Yes, this is a hardcoded password. This is NOT intended to be used
	# in production.
	#
	echo "/var/splunk/bin/splunk add search-server -host ${IP}:8089 "\
		"-auth admin:changeme "\
		"-remoteUsername admin -remotePassword adminpw" >> ${ADD_INDEXERS}

done


if test "${IPS}" 
then
	echo "# "
	echo "# Found the following Indexers: ${IPS}"
	echo "# Writing them to outputs.conf..."
	echo "# "
	cat outputs.conf.template | sed -e s/%IPS%/${IPS}/ > outputs.conf
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
cp inputs.conf /opt/splunk/etc/system/local
cp outputs.conf /opt/splunk/etc/system/local
cp server.conf /opt/splunk/etc/system/local
mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
cp user-prefs.conf /opt/splunk/etc/users/admin/user-prefs/local


echo "# "
echo "# Starting up Splunk..."
echo "# "
/var/splunk/bin/splunk --accept-license start 2>&1 | tee -a ${LOG}

echo "# "
echo "# Adding Indexers as Search Peers..."
echo "# "
${ADD_INDEXERS}


