# RHCE_ENV
An environment made as a preparation for RHCE [EX294] exam

*Note: after a while you'll find lots of `ssh-agent` processes running in the background when you `ps aux`, just run `pkill ssh-agent` from time to time and you'll be good ..

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
192.168.50.211 ansible1
192.168.50.212 ansible2
192.168.50.213 ansible3
192.168.50.214 ansible4

```