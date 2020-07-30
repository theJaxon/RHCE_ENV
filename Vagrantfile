Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync"
  config.vm.box_check_update = false

  config.vm.provision "shell", inline: <<-SHELL
  #sudo yum update -y
  sudo yum install -y python3 python3-pip
  alternatives --set python /usr/bin/python3 
  sudo useradd ansible
  echo ansible | passwd --stdin ansible # Set default ansible password to ansible
  echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible # Grant ansible user the sudo priviliges without demanding a password [privilege escalation]
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
    
    # Use ansible user instead of vagrant
    sudo echo "sudo su - ansible" >> /home/vagrant/.bash_profile

    # [1]
    sudo -u ansible /bin/sh <<\ANSIBLE_USER
      cd /home/ansible
      mkdir -v .ssh
      # Install sshpass from source 
      wget http://sourceforge.net/projects/sshpass/files/latest/download -O sshpass.tar.gz
      tar xvf sshpass.tar.gz && cd sshpass-1.06
      sudo yum install -y gcc vim 
      sudo ./configure && sudo make install && sudo mv /usr/local/bin/sshpass /bin

      pip3 install ansible --user
      echo $(ansible --version)

      ssh-keygen -N "" -f ansible # Generate public and private key pairs (ansible, ansible.pub)

      # Add public key to all managed servers [2]
      sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i ansible.pub ansible@ansible1
      sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i ansible.pub ansible@ansible2
      sshpass -p "ansible" ssh-copy-id -o StrictHostKeyChecking=no -i ansible.pub ansible@ansible3


      # use ansible user & cd into the directory containing ssh keys [3][4]
      sudo echo 'eval "$(ssh-agent -s)"' >> /home/ansible/.bash_profile # Still problematic and must be replaced with wget
      sudo echo "ssh-add /home/ansible/sshpass-1.06/ansible" >> /home/ansible/.bash_profile

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

=end 