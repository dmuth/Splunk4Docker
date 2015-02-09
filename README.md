
# Splunk4Docker


I manage a large Splunk installation at my day job and, wanting a way to get my feet wet with Docker, decided to build some Docker containers that run Splunk.  This turned out to be a little more challenging than I anticipated. :-)


## Getting started

Clone this repo.  Then bring up a Vagrant instance of CoreOS by typing `vagrant up`.

Next, download a version of Splunk in .deb package format.  As of this writing, I've tested this with `splunk-6.2.1-245427-linux-2.6-amd64.deb`.  This can be stored anywhere in your filesystem, and a hard symlink can be used to make it accessible to each docker container.


### Spinning up a standalone Search Head

- `vagrant ssh`
- `cd vagrant/splunk-search-head`
- `ln /path/to/splunk-6.2.1-245427-linux-2.6-amd64.deb splunk.dev`
- `./go -d`

This will build an image from the Dockerfile, run the image, and then run `runtime.sh` within the image to install Splunk.

You will shortly have a Splunk Search head listening on port 8000 in the host machine.

To run the container interactively:
- `./go bash`
- (in the Docker container) `/data-devel/runtime.sh`

The script `runtime.sh` in the current directory can be tweaked as necessary.  For further options, run `go.sh -h`.


### Spinning up multiple Indexers 

First, make sure you aren't running any search heads:
- `cd $HOME/vagrant/`
- `./splunk-search-head/kill.sh`

Now, to spin up 3 Indexers, followed by a Seach Head which talks to them:
- `./splunk-indexer./go.sh --num 3`
- `./splunk-search-head/go.sh -d`

Wait a minute or two, and you should be able to connect to port 8000 on the host machine and log into Splunk.  Run the search `index=_internal` and you should see Splunk's internal logs from 4 hosts (3 Indexers plus one Search Head) listed.  Additionally, all events generated on the Search Head will be forwarded to the 3 Indexers.


# Volume Export

Search Head and Indexer containers export the contents of /opt/splunk/var to the Docker Host.  They can be found under `splunk-search-head/volumes` and `splunk-indexer/volumes` with names like `search-head-1` and `indexer-1`, where the number is the number of the host that was created.  These directories will persist after the containers exit and when they are restarted, allowing for log retention.


# Log import

Need to have some logs of your own indexed by Splunk?  No problem!  Just drop them in the directory volumes/index-intake-1/ or volumes/search-head-intake-1/ and they will be indexed instantly.  This directory also presists between Docker containers, so if you have kill and later restart a container, this data will be re-indexed.


# Debugging Splunk

Logs are stored `spunk-(search-head|indexer)/log/splunk/`.  Logs of interest will be `splunkd.log` for overall system operation and `audit.log` for a list of what searches are being done and what Indexers are connected to.

To work on a specific container, run the `go.sh` script with "bash" as an argument. Example: `./splunk-search-head/go.sh bash`.
That will spin up a Docker instance and put you in a root shell.  From there, run `/data-devel/runtime.sh` to run the
script which installs and configure Splunk.  That directory is not ADDed to the Docker image, but rather mounted against
the current directory, so any edits made on the local copy of `runtime.sh` will show up in `/data-devel/`.


# Known Issues

This works great under CoreOS.  Under Ubuntu 14.04... not so much.  I ran into weird issues with installing Splunk and starting Splunk which seem to be volume-related.  Right now, I am exporting a substatnail portion of the /opt/splunk/ directory to the host running Docker.  This is mostly for debugging issues.  I may revisit this decision later.

`docker restart` does not work correctly.  I tried running `/opt/splunk/bin/splunk enable boot-start` inside each container, but that does not work.


# TODO

- I need to seeif I can add a switch that keeps from using Volumes when spinning up Docker.  This may fix issues in Ubuntu, at the cost of being harder to debug
- Logfile intake from the host container
- A script which autogenerates sample data.  This will be helpful for people who are new to Splunk.
- Encryption on port 9998 on the indexers
 

# FAQ

Q: What ports are used by the web servers?

A: Ports 8000-8009 are used by the Search Head(s).  Ports 8010-8019 are used by the Indexers.


Q: The credentials admin/changeme don't work on the Indexers!

A: I had to change the passwords from the default because the Search Head(s) connect to the Indexers, and the Indexers won't let you use default credentials for connecting via port 8089.  Instead, the credentials are: admin/adminpw.  For the love of all that is sacred, please **change these** if you plan on using this code in production!


Q: Why are you running the Splunk install script **inside** of the docker container instead of running it at container creation time?

A: Splunk comes with a free license that is good for 60 days.  During development, I found it more helpful to use this approach to ensure that I can run my instances for longer if needed.


Q: Why does the Virtual Machine use a Gigabyte of RAM?

A: Because Splunk uses a lot of RAM. :-)  I could try limiting this usage, but haven't investigated that avenue thoroughly yet.  The provisioning script for Vagrant sets up a swapfile in CoreOS so you might be able to get by on half a Gig of RAM if you wanted.  I make no guarantees as of this writing, though!


# "I have a question that's not answered in the FAQ!"

File a bug or send me a note. My email address is dmuth@dmuth.org, and I can be readily found on places like [Facebook](http://www.facebook.com/dmuth) and [Twitter](http://twitter.com/dmuth).

