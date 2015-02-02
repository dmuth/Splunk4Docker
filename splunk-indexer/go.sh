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

pushd $(dirname $0) > /dev/null
DIR=$(pwd)

echo "# "
echo "# Building Docker image..."
echo "# "
./build.sh


VOLUMES=""
#
# Make our logs visible to the outside world
#
VOLUMES="${VOLUMES} -v ${DIR}/logs:/splunk-logs "
#
# Put the current directory in as /data-devel for development purposes
#
VOLUMES="${VOLUMES} -v ${DIR}:/data-devel "

#PORTS="-p 8000:8000" # Debugging

#
# Remove old images with "indexer" in the name.:w
#
if test "$(docker ps -a |grep indexer | awk '{print $1}')"
then
	echo "# "
	echo "# Removing old Docker images with this name..."
	echo "# "
	docker rm $(docker ps -a |grep indexer | awk '{print $1}')
fi

echo "# "
echo "# Running Docker image..."
echo "# "
docker run -it \
	--name indexer1 \
	${PORTS} \
	${VOLUMES} \
	dmuth/splunk $@


