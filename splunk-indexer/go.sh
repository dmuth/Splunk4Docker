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
ARG_FORCE_BUILD=""
ARG_NUM=1
ARG_CMD=""


#
# Parse our arguements. If we find what looks like a command, grab
# the rest of the argmuents
#
while test "$1"
do
	ARG=$1
	ARG_NEXT=$2

	if test "$ARG" == "-h"
	then
		ARG_HELP=1

	elif test "$ARG" == "-d"
	then
		ARG_DETACH="-d "

	elif test "$ARG" == "--force-build"
	then
		ARG_FORCE_BUILD=1

	elif test "$ARG" == "--num"
	then
		ARG_NUM=$2
		shift

	else 
		ARG_CMD=$@
		break

	fi

	shift

done


if test "$ARG_HELP"
then
	echo "Syntax: $0 [-d] [--force-build] [--num <num indexers>] [<command to run in this image>]"
	echo ""
	echo "To make this image be interactive, type '$0 bash'"
	echo ""
	exit 1
fi

if test "$ARG_NUM" -gt 1
then
	echo "# "
	echo "# Multiple Indexers requested. Forcing -d for detachment..."
	echo "# "
	ARG_DETACH="-d"

fi

pushd $(dirname $0) > /dev/null
DIR=$(pwd)

if test ! "$(docker images |grep dmuth/splunk_indexer)"
then
	echo "# "
	echo "# Docker image not found! Building..."
	echo "# "
	./build.sh
fi

if test "$ARG_FORCE_BUILD"
then
	echo "# "
	echo "# Forcing an image build..."
	echo "# "
	./build.sh
fi


VOLUMES=""
#
# Put the current directory in as /data-devel for development purposes
#
VOLUMES="${VOLUMES} -v ${DIR}:/data-devel "


#
# Remove old images with "indexer" in the name.
#
if test "$(docker ps -a |grep dmuth/splunk_indexer | awk '{print $1}')"
then
	echo "# "
	echo "# Removing old Docker images with this name..."
	echo "# "
	docker rm $(docker ps -a |grep dmuth/splunk_indexer | awk '{print $1}')
fi


#
# Now run our indexers!
#
for I in $(seq 1 ${ARG_NUM})
do
	echo "# "
	echo "# Running Docker image ${I}/${ARG_NUM}..."
	echo "# "

	#
	# Expose  our Splunk data under the volumes/indexer-X/ directory structure.
	#
	VOLUMES_LOCAL="${VOLUMES} -v ${DIR}/volumes/indexer-${I}:/splunk-data"

	#
	# Create a directory for intake in Splunk and put a dummy file in there
	#
	INTAKE="${DIR}/volumes/indexer-intake-${I}/"
	mkdir -p $INTAKE
	echo "$(date) test=test2 test2=test3" > ${INTAKE}/test.txt
	VOLUMES_LOCAL="${VOLUMES_LOCAL} -v ${INTAKE}:/logs"

	PORTS="$((8009 + $I)):8000"

	docker run -it \
		${ARG_DETACH} \
		--name splunk_indexer_${I} \
		-p ${PORTS} \
		${VOLUMES_LOCAL} \
		dmuth/splunk_indexer ${ARG_CMD}

done

