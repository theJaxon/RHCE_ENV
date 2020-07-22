Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.box_check_update = false

  config.vm.provision "shell", inline: <<-SHELL
  #sudo yum update -y
  sudo yum install -y python3 python3-pip
  alternatives --set python /usr/bin/python3 
  sudo useradd ansible
  echo ansible | passwd --stdin ansible # Set default ansible password to ansible
  echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
  SHELL

  (1..3).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = "bento/centos-8"
      node.vm.hostname = "ansible-#{i}"
      node.vm.network "private_network", ip: "192.168.50.#{i + 210}"
      node.vm.provision "shell", inline:  <<-SHELL
      SHELL
    end
  end

  config.vm.define "controller" do |controller|
    controller.vm.box = "bento/centos-8"
    controller.vm.hostname = "controller"
    controller.vm.network "private_network", ip: "192.168.50.210"
    controller.vm.provision "shell", inline: <<-SHELL
            
    sudo echo "192.168.50.211 ansible1" >> /etc/hosts
    sudo echo "192.168.50.212 ansible2" >> /etc/hosts
    sudo echo "192.168.50.213 ansible3" >> /etc/hosts

    sudo -u ansible /bin/sh <<\ANSIBLE_USER
      cd /home/ansible
      mkdir -v .ssh
      # Install sshpass from source 
      wget http://sourceforge.net/projects/sshpass/files/latest/download -O sshpass.tar.gz
      tar xvf sshpass.tar.gz && cd sshpass-1.06
      sudo yum group install -y "Development Tools" # Tools required for compiling source code
      sudo ./configure && sudo make install && sudo mv /usr/local/bin/sshpass /bin

      
       
      pip3 install ansible --user
      echo $(ansible --version)

      ssh-keygen -N "" -f ansible # Generate public and private key pairs (ansible, ansible.pub)

      # Add public key to all managed servers
      sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i ansible.pub ansible@ansible1
      sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i ansible.pub ansible@ansible2
      sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i ansible.pub ansible@ansible3

      # cd into the directory containing ssh keys
      echo "cd /home/ansible/sshpass-1.06/" >> /home/ansible/.bashrc

ANSIBLE_USER
  SHELL
  end

 # Enable vagrant cachier plugin if it's already installed 
 if Vagrant.has_plugin?("vagrant-cachier")
  config.cache.scope = :box
  end
end


