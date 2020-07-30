# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

eval "$(ssh-agent -s)"
ssh-add /home/ansible/sshpass-1.06/ansible