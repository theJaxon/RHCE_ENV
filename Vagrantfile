NUMBER_OF_NODES = ENV['NUMBER_OF_NODES'] = '4'
NUMBER_OF_NODES_TO_INT = NUMBER_OF_NODES.to_i
Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.box_check_update = false

  config.vm.provision "shell", inline: <<-SHELL
  # Install python on all machines
  sudo yum module install -y python36
  sudo useradd ansible
  echo ansible | passwd --stdin ansible # Set default ansible password to ansible
  echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible # Grant ansible user the sudo priviliges without demanding a password [privilege escalation]
  SHELL

  (1..NUMBER_OF_NODES_TO_INT).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "bento/centos-8"
      node.vm.hostname = "ansible-#{i}"
      node.vm.network "private_network", ip: "192.168.50.#{i + 210}"
      # Create & attach a 5GiB disk to each node machine
      file_for_disk = "./large_disk#{i}.vdi"
      node.vm.provider "virtualbox" do |v|
        # If the disk already exists don't create it
        unless File.exist?(file_for_disk)
            v.customize ['createhd', '--filename', file_for_disk, '--size', 5120]
        end
        v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_for_disk]
      end
    end
  end

  config.vm.define "controller" do |controller|
    controller.vm.box = "bento/centos-8"
    controller.vm.hostname = "controller"
    controller.vm.network "private_network", ip: "192.168.50.210"

    controller.vm.provision "shell", inline: <<-SHELL
    export NUMBER_OF_NODES=#{ENV['NUMBER_OF_NODES']}        
    for((i=1; i<=$NUMBER_OF_NODES; i++));
    do
      sudo echo "192.168.50.21$i ansible$i" >> /etc/hosts
    done
    
    sudo yum install -y epel-release && sudo yum install -y ansible

    # Use ansible user instead of vagrant
    sudo echo "sudo su - ansible" >> /home/vagrant/.bash_profile

    # [1] [5]
    sudo -u ansible /bin/sh << 'ANSIBLE_USER'
      export NUMBER_OF_NODES=#{ENV['NUMBER_OF_NODES']}        
      cd /home/ansible
      mkdir -v .ssh
      sudo yum install -y vim sshpass
      cd /home/ansible/.ssh/
      ssh-keygen -N "" -f id_rsa # Generate public and private key pairs (id_rsa, id_rsa.pub)

      # Add public key to all managed servers [2]
      for((i=1; i<=$NUMBER_OF_NODES; i++));
      do
        sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i id_rsa.pub ansible@ansible$i
      done

ANSIBLE_USER
  SHELL
  end

end

# Useful Resource for problems i've faced writing this script:
=begin

1-Executing the script as the user ansible instead of vagrant 
Answer provided by Diomidis Spinellis was extremely helpful and did the job
https://stackoverflow.com/questions/35628656/how-execute-commands-as-another-user-during-provisioning-on-vagrant

2- auto add the ssh public keys into all ansible nodes, sshpass in combination with ss-copy-id were used, mainly relying on the answer provided by Graeme 
https://stackoverflow.com/questions/21196719/bash-script-to-push-ssh-keys

3-ssh-agent by default relies on forking so it doesn't open in the current shell, to make it do so i've used the answer provided by glenn jackman 
https://superuser.com/questions/901568/ssh-agent-could-not-open-connection?newreg=d66d9b54917447c0965d17d3c9abef12  

4-Solution 2 introduced its own problem .. while it works, it can't be echoed the usual way because it gets interpreted by the shell, to solve it use single quotes then double quotes for the eval command
i've used the solution by Etan Reisner from
https://stackoverflow.com/questions/28037232/escape-eval-command-when-appending-to-file

5- Use the quoted-heredoc style to fix the eval inconsistent behavior with vagrant
https://github.com/hashicorp/vagrant/issues/11796

=end 