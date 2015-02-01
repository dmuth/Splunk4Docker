#!/bin/bash
#
# Wrapper to both build and run our Docker container
# Useful for development/testing
#

#
# Errors are fatal
#
set -e 

echo "# "
echo "# Building Docker image..."
echo "# "
./build.sh


echo "# "
echo "# Running Docker image..."
echo "# "
docker run -it -p 8000:8000 -v /home/core/vagrant/splunk/logs:/splunk-logs dmuth/splunk 


