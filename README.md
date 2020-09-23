# RHCE_ENV
An environment made as a preparation for RHCE [EX294] exam

---

#### rhel-system-roles:
```bash
sudo yum install -y rhel-system-roles
```
:file_folder: **Important dirs**:
* /etc/ansible/
  * hosts
  * ansible.cfg

* /usr/share
  * /ansible/roles
  * /doc/rhel-system-roles

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