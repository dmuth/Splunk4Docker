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
# cd to the directory that this script is in
#
pushd $(dirname $0) > /dev/null
DIR=$(pwd)


#
# Check our arguments
#
ARG_DETATCH=""
ARG_HELP=""
ARG_FORCE_BUILD=""
ARG_CLEAN=""
ARG_CMD=""
ARG_NUM=1


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

	elif test "$ARG" == "--rebuild"
	then
		ARG_FORCE_BUILD=1

	elif test "$ARG" == "--clean"
	then
		ARG_CLEAN=1

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


#
# Check our arguments
#
if test "$ARG_HELP"
then
	echo "Syntax: $0 [-d] [--rebuild] [--clean] [--num <num indexers>] [<command to run in this image>]"
	echo ""
	echo "	-d		Detach from the image being run"
	echo "	--rebuild	Force a rebuild of the Docker image"
	echo "	--clean		Remove the local volumes, including indexes and logs"
	echo ""
	echo "To make this image be interactive, type '$0 bash'"
	echo ""
	exit 1
fi

if test "$ARG_NUM" -gt 1
then
	echo "# "
	echo "# Multiple Search Heads requested. Forcing -d for detachment..."
	echo "# "
	ARG_DETACH="-d"

fi

if test "${ARG_CLEAN}"
then
	echo "# "
	echo "# --clean specified, nuking contents of volumes/"
	echo "# "
	#
	# This might not succeeed, because CoreOS does weird things with NFS mounts
	#
	rm -rf volumes/ || true
fi

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
# Put the current directory in as /data-devel for development purposes
#
VOLUMES="${VOLUMES} -v ${DIR}:/data-devel "


#
# Remove old images with "splunk_search_head" in the name.
#
if test "$(docker ps -a |grep splunk_search_head | grep -v ,splunk | awk '{print $1}')"
then
	echo "# "
	echo "# Removing old Docker images with this name..."
	echo "# "
	docker rm -f $(docker ps -a |grep splunk_search_head | grep -v ,splunk | awk '{print $1}')
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


#
# Now build our Search Heads!
#
for I in $(seq 1 ${ARG_NUM})
do
	echo "# "
	echo "# Running Docker image ${I}/${ARG_NUM}..."
	echo "# "

	#
	# Expose our Splunk data under the volumes/search-head-X/ directory structure.
	#
	VOLUMES_LOCAL="${VOLUMES} -v ${DIR}/volumes/search-head-${I}:/splunk-data"


	#
	# Create a directory for intake in Splunk and put a dummy file in there
	#
	INTAKE="${DIR}/volumes/search-head-intake-${I}/"
	mkdir -p $INTAKE
	echo "$(date) test=test2 test2=test3" > ${INTAKE}/test.txt
	VOLUMES_LOCAL="${VOLUMES_LOCAL} -v ${INTAKE}:/logs"

	PORTS="$((7999 + $I)):8000"

	docker run -it \
		${ARG_DETACH} \
		--name splunk_search_head_${I} \
		-p ${PORTS} \
		${VOLUMES_LOCAL} \
		${LINKS} \
		dmuth/splunk_search_head ${ARG_CMD}

done


