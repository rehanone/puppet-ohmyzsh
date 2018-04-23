
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
  config.vm.box_url = "https://atlas.hashicorp.com/puppetlabs/boxes/ubuntu-16.04-64-puppet"

  config.vm.synced_folder ".", "/etc/puppet/modules/ohmyzsh"

  config.vm.provision :shell, inline: <<-EOF
    gem install rspec-puppet --no-user-install --no-ri --no-rdoc
    gem install puppetlabs_spec_helper --no-user-install --no-ri --no-rdoc
    apt-get update
    puppet module install puppetlabs/stdlib
    puppet module install puppetlabs/vcsrepo
  EOF

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "tests"
    puppet.manifest_file  = "vagrant.pp"
    puppet.options        = "../"
    puppet.options        = "--verbose --debug"
  end

  config.vm.provision :serverspec do |spec|
    spec.pattern = 'spec/*_spec.rb'
  end
end
