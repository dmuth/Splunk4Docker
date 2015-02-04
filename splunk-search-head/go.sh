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
ARG_DETATCH=""
ARG_HELP=""
ARG_CMD=""


#
# Parse our arguements. If we find what looks like a command, grab
# the rest of the argmuents
#
while test "$1"
do
	ARG=$1
	if test "$ARG" == "-h"
	then
		ARG_HELP=1

	elif test "$ARG" == "-d"
	then
		ARG_DETACH="-d "

	else 
		ARG_CMD=$@
		break

	fi

	shift

done


#
# Check our arguments
#
if test "$1" == "-h"
then
	echo "Syntax: $0 [-d] [<command to run in this image>]"
	echo ""
	echo "To make this image be interactive, type '$0 bash'"
	echo ""
	exit 1
fi

#
# cd to the directory that this script is in
#
pushd $(dirname $0) > /dev/null
DIR=$(pwd)

LINKS=""
INSTANCES=$(docker ps -a |grep indexer | awk '{print $1}')

if test "${INSTANCES}"
then
	echo "# "
	echo "# Indexers found! We'll link to them..."
	echo "# "
	INDEX=0
	for ID in ${INSTANCES}
	do
		NAME=$(docker inspect --format {{.Name}} ${ID} | cut -c2-)
		INDEX=$(($INDEX + 1))
		LINKS="${LINKS} --link ${NAME}:indexer${INDEX}"
	done

	echo "# "
	echo "# Indexers we will link: ${LINKS}"
	echo "# "

fi


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


echo "# "
echo "# Running Docker image..."
echo "# "
echo "# It make take 10s of seconds for Splunk to start, be patient or run without -d"
echo "# "
docker run -it \
	${ARG_DETACH} \
	-p 8000:8000 \
	${VOLUMES} \
	${LINKS} \
	dmuth/splunk ${ARG_CMD}


