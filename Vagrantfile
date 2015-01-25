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

		config.vm.network :forwarded_port, guest: 80, host: 8080

		#
		# Set the amount of RAM and CPU cores
		#
		host.vm.provider "virtualbox" do |v|
			v.memory = 256
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


