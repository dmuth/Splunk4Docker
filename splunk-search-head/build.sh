#!/bin/bash
#
# A wrapper to build our Docker image
#

#
# Errors are fatal
#
set -e


if test ! -f splunk.deb
then
	echo "! "
	echo "! File \"splunk.deb\" not found. Please download Splunk and place it here to continue."
	echo "! "
	echo "! (Note that you very likely want the amd64 version)"
	echo "! "
	exit 1
fi

if test -f "outputs.conf"
then
	echo "# "
	echo "# Found stale outputs.conf, removing!"
	echo "# "
	rm outputs.conf
fi

docker build -t dmuth/splunk_search_head .


