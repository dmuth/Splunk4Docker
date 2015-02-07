# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	#
	# Cache anything we download with apt-get
	#
	if Vagrant.has_plugin?("vagrant-cachier")
		config.cache.scope = :box
	end


	config.vm.define :docker do |host|

		host.vm.box = "coreos"
		host.vm.box_url = "http://storage.core-os.net/coreos/amd64-generic/dev-channel/coreos_production_vagrant.box"
		#
		# Specify a static IP so we can do NFS mounts
		#
		host.vm.network "private_network", ip: "10.0.0.100"

		#
		# We can't use vbguest, so instead we use NFS.
		# Also, don't link to /vagrant, since that's on a read-only
		# filesystem in CoreOS.
		#
		config.vm.synced_folder ".", "/home/core/vagrant", 
			id: "core", :nfs => true,  
			:mount_options   => ['nolock,vers=3,udp']

		#
		# Forward our ports out
		#
		# Port 80/8080 is for testing
		# Ports 8000-8009 are for Search Heads
		# Ports 8010-8019 are for Indexers
		#
		config.vm.network :forwarded_port, guest: 80, host: 8080
		config.vm.network :forwarded_port, guest: 8000, host: 8000
		config.vm.network :forwarded_port, guest: 8001, host: 8001
		config.vm.network :forwarded_port, guest: 8002, host: 8002
		config.vm.network :forwarded_port, guest: 8003, host: 8003
		config.vm.network :forwarded_port, guest: 8004, host: 8004
		config.vm.network :forwarded_port, guest: 8005, host: 8005
		config.vm.network :forwarded_port, guest: 8006, host: 8006
		config.vm.network :forwarded_port, guest: 8007, host: 8007
		config.vm.network :forwarded_port, guest: 8008, host: 8008
		config.vm.network :forwarded_port, guest: 8009, host: 8009
		config.vm.network :forwarded_port, guest: 8010, host: 8010
		config.vm.network :forwarded_port, guest: 8011, host: 8011
		config.vm.network :forwarded_port, guest: 8012, host: 8012
		config.vm.network :forwarded_port, guest: 8013, host: 8013
		config.vm.network :forwarded_port, guest: 8014, host: 8014
		config.vm.network :forwarded_port, guest: 8015, host: 8015
		config.vm.network :forwarded_port, guest: 8016, host: 8016
		config.vm.network :forwarded_port, guest: 8017, host: 8017
		config.vm.network :forwarded_port, guest: 8018, host: 8018
		config.vm.network :forwarded_port, guest: 8019, host: 8019


		#
		# As of Vagrant 1.7, it auto-generates new SSH key.
		# Sounds like a good idea, except that it causes this Core OS box 
		# to break. Oops. So instead, we're going to disable that 
		# behavior for now.
		#
		config.ssh.insert_key = false

		#
		# Set the amount of RAM and CPU cores
		#
		host.vm.provider "virtualbox" do |v|
			#
			# You can try with less RAM, but I had problems when using 
			# only half a Gig.
			#
			v.memory = 1024
			v.cpus = 2
			#
			# I don't fully understand these optoins, but they are suggested
			# everywhere else I looked for Vagrant configs for CoreOS.
			#
			v.check_guest_additions = false
			v.functional_vboxsf     = false
		end

		#
		# No good can come from updating plugins.
		# Plus, this makes creating Vagrant instances MUCH faster
		#
		if Vagrant.has_plugin?("vagrant-vbguest")
			host.vbguest.auto_update = false
		end

	end

end


