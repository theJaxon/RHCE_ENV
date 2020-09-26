# RHCE_ENV
An environment made as a preparation for RHCE [EX294] exam

---

#### Useful tips:
1- Gather facts again inside the playbook
* Can be done using the `setup` module 

```yml
- name: gather facts again
  setup:
```

* Can also be done using another play inside that playbook
```yml
hosts: localhost
tasks:
  - name: install httpd
    yum:
      name: httpd
      state: latest 

hosts: localhost # facts are being gathered again
tasks:
  - name: gather package facts
    package_facts:
      manager: auto
```

2- Edit ~/.vimrc to allow auto indent
```bash
vi ~/.vimrc
set ai
```

3- Add `--syntax-check` flag at the end of the command to verify there was no syntax issues, remove it quickly using `ctrl + w`
```bash
ansible-playbook <name>.yml --syntax-check
```

---

#### rhel-system-roles:
```bash
sudo yum install -y rhel-system-roles
```
:file_folder: **Important dirs**:
* /etc/ansible/
  * hosts
  * ansible.cfg
  * facts.d/ # for storing custom facts (file extension must be .fact)

* /usr/share
  * /ansible/roles
  * /doc/rhel-system-roles

---

#### :clock1: Fact caching:
* Mainly done when managing a large fleet of servers to save the time spent gathering facts at the beginning of the playbook.

1. Caching using redis
```ini
[defaults]
gathering = smart
fact_caching = redis
fact_caching_timeout = 7200 # 2 hours timeout
```

2. Caching locally using a file
```ini
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_timeout = 7200
fact_caching_connection = /tmp/fact_cache
```
---

#### Ansible Facts:
* `ansible_local` used to get local facts stored in /etc/ansible/facts.d/<name>.fact

---

#### [Magic Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html):
1. hostvars # access vars defined for any host in the play
2. groups # List of all groups in the inventory
3. group_names # List of groups that the current host is part of
4. inventory_hostname # same as ansible_hostname
5. inventory_file 

---

#### Quick Tip for `configure managed nodes` objective:
1- Generate the ssh key on controller node first `ssh-keygen`
2- Make a shell script that automates the user creation, password and privilege escalation part 
3- use `scp` to place it in /tmp on all the hosts that will be managed 
4- run it then from controller copy ssh key using `ssh-copy-id`

```bash
useradd ansible 
echo ansible | passwd --stdin ansible 
usermod -aG wheel ansible 
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
```

List of hosts that will be managed:
```
192.168.50.221 ansible1
192.168.50.222 ansible2
192.168.50.223 ansible3
192.168.50.224 ansible4
```

An easier approach for achieving same objective is to generate the keys then use `group_vars` and use the `all` group to set `ansible_ssh_password` to the host password 
then make a playbook that uses `authorized_key` module to place the generated ssh key to the managed hosts

```yml
- hosts: all
  tasks:
    - name: copy authorized keys
      authorized_key:
        user: vagrant
        key: "{{ lookup('file', '/home/vagrant/.ssh/id_rsa.pub') }}"
```