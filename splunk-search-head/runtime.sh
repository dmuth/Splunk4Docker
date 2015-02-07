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
	echo "/opt/splunk/bin/splunk add search-server -host ${IP}:8089 "\
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


#
# Make our symlinks to /splunk-data/ first, and do it in $SPLUNK_HOME/var/,
# as Splunk does funny things with symlinks elsewhere when installing it.
#
mkdir -p /opt/splunk/
ln -s /splunk-data/ /opt/splunk/var
/opt/splunk/bin/splunk --accept-license status 2>&1 | tee -a ${LOG}



#
# Copy in configuration settings
#
cp inputs.conf /opt/splunk/etc/system/local
cp server.conf /opt/splunk/etc/system/local
mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
cp user-prefs.conf /opt/splunk/etc/users/admin/user-prefs/local

if test -f "outputs.conf"
then
	cp outputs.conf /opt/splunk/etc/system/local
fi


echo "# "
echo "# Starting up Splunk..."
echo "# "
/opt/splunk/bin/splunk --accept-license start 2>&1 | tee -a ${LOG}

echo "# "
echo "# Adding Indexers as Search Peers..."
echo "# "
${ADD_INDEXERS}

#
# Finally, we want this script to run forever so that Docker doesn't exit
#
echo "# "
echo "# Press ^C to end this script and (probably) this Docker container..."
echo "# "
while true
do
	sleep 300
done


