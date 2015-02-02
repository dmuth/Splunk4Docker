#!/bin/bash
#
# Wrapper to both build and run our Docker container
# Useful for development/testing
#

#
# Errors are fatal
#
set -e 

#
# Check our arguments
#
if test "$1" == "-h"
then
	echo "Syntax: $0 <command to run in this image>"
	echo ""
	echo "To make this image be interactive, type '$0 bash'"
	echo ""
	exit 1
fi


echo "# "
echo "# Building Docker image..."
echo "# "
./build.sh


VOLUMES=""
#
# Make our logs visible to the outside world
#
VOLUMES="${VOLUMES} -v /home/core/vagrant/splunk-search-head/logs:/splunk-logs "
#
# Put the current directory in as /data-devel for development purposes
#
VOLUMES="${VOLUMES} -v /home/core/vagrant/splunk-search-head/:/data-devel "


echo "# "
echo "# Running Docker image..."
echo "# "
docker run -it \
	-p 8000:8000 \
	${VOLUMES} \
	dmuth/splunk $@


