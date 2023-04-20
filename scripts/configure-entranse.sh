#!/usr/bin/bash
set -eu

#configure bash autocompletion
echo "source <(kubectl completion bash)" >> .bashrc
echo "complete -o default -F __start_kubectl k" >> .bashrc
echo "alias k=kubectl" >> .bash_aliases

#https://github.com/jonmosco/kube-ps1
# echo "source .my-settings/kube-ps1.sh" >> .bashrc
# echo 'PS1="[\u@\h \W $(kube_ps1)]\$ "' >> .bashrc