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

	elif test "$ARG" == "--force-build"
	then
		ARG_FORCE_BUILD=1

	else 
		ARG_CMD=$@
		break

	fi

	shift

done


#
# Check our arguments
#
if test "$ARG_HELP"
then
	echo "Syntax: $0 [-d] [--force-build] [<command to run in this image>]"
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


#
# If there are Indexers, not them and link to them
#
LINKS=""
INSTANCES=$(docker ps | grep splunk_indexer | awk '{print $1}')

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
		LINKS="${LINKS} --link ${NAME}:splunk_indexer${INDEX}"
	done

	echo "# "
	echo "# Indexers we will link: ${LINKS}"
	echo "# "

fi

if test ! "$(docker images |grep dmuth/splunk_search_head)"
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
# Make our logs visible to the outside world
#
VOLUMES="${VOLUMES} -v ${DIR}/logs:/splunk-logs "
#
# Put the current directory in as /data-devel for development purposes
#
VOLUMES="${VOLUMES} -v ${DIR}:/data-devel "


#
# Remove old images with "splunk_search_head" in the name.
#
if test "$(docker ps -a |grep splunk_search_head | awk '{print $1}')"
then
	echo "# "
	echo "# Removing old Docker images with this name..."
	echo "# "
	docker rm $(docker ps -a |grep splunk_search_head | awk '{print $1}')
fi


echo "# "
echo "# Running Docker image..."
echo "# "

if test ! "${ARG_DETACH}" -o "${ARG_CMD}"
then
	echo "# "
	echo "# It make take 10s of seconds for Splunk to start, "
	echo "# please be patient."
	echo "# "
fi

docker run -it \
	${ARG_DETACH} \
	--name splunk_search_head \
	-p 8000:8000 \
	${VOLUMES} \
	${LINKS} \
	dmuth/splunk_search_head ${ARG_CMD}


