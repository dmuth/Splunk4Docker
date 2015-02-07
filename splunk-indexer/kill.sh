#!/bin/bash
#
# Kill off all our Splunk instances
#

echo "# "
echo "# Killing all Splunk Search Heads"
echo "# "

if test "$(docker ps |grep dmuth/splunk_indexer | awk '{print $1}')"
then
	docker kill $(docker ps |grep dmuth/splunk_indexer | awk '{print $1}')
fi

