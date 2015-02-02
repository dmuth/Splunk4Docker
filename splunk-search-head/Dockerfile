#
# Build a image running Splunk
#
# PRE-CONDITION: There must be a file named splunk.deb in the current directory.
# 	You can download Splunk from splunk.com
#

FROM ubuntu:14.04

MAINTAINER Douglas Muth <dmuth@dmuth.org>


#
# Copy in our directory so we can install Splunk
#
ADD . /data-install


#
# Install Splunk and symlink it from /var/splunk
#
RUN ln -s /opt/splunk /var/splunk


EXPOSE 8000


#
# Make this be a volume so that it is writable.
# I learned the hardware that all Docker instances at btrfs by default.
#
VOLUME /opt/splunk


#
# Run our command to install and start Splunk at runtime.
# Unfortunately, we cannot do that there, as the directory will be btrs 
# at runtime.
#
# But honestly, we need to do it this way anyway, because Splunk generates 
# its license key at runtime.  If we did this at build time, the Docker 
# image would only be valid for a maximum of 60 days anyway.
#
CMD /data-install/runtime.sh



