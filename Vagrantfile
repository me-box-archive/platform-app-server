# -*- mode: ruby -*-
# vi: set ft=ruby :

require "json"
require "./vagrant-config.rb"

Vagrant.configure(2) do |config|
  
  app_config = JSON.parse(File.read("config.json"))
  
  config.vm.box = "ubuntu/wily64"
  
  config.vm.network "private_network", ip: DevEnv::IP

  config.vm.provision "docker" do |d|
  
  	d.pull_images "tutum/mongodb"
    
    d.build_image "/vagrant",
      args: "-t databox-app-server"
      
    d.run "tutum/mongodb",
      auto_assign_name: false,
      args: "--name databox-app-server-mongodb \
        -e MONGODB_USER=\"#{app_config["mongodb"]["user"]}\" \
        -e MONGODB_PASS=\"#{app_config["mongodb"]["pass"]}\" \
        -e MONGODB_DATABASE=\"#{app_config["mongodb"]["db"]}\""
      
    d.run "databox-app-server",
      auto_assign_name: false,
      args: "--name databox-app-server \
      	--link databox-app-server-mongodb:mongodb \
      	-p 0.0.0.0:#{DevEnv::PORT}:#{DevEnv::PORT} \
      	-e PORT=#{DevEnv::PORT}"
    
  end
  
end
