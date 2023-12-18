[![EPAM](https://img.shields.io/badge/Cloud&DevOps%20UA%20Lab%202nd%20Path-Ansible-orange)](./)
[![EPAM](https://img.shields.io/badge/Configuration%20Management-Practical%20Tasks-blue)](./)
[![HitCount](https://hits.dwyl.com/HarrierPanels/ansible.svg?style=flat&show=unique)](http://hits.dwyl.com/HarrierPanels/ansible)
<br>
## Practical Tasks Environment
To complete the practical tasks for the Ansible lesson, you need to build an environment in a public cloud (e.g., AWS).
Three Virtual Machines 	Machine Names

    min 1 vCPU
    min 512 Mb RAM
    min 10 Gb system drive
    OS - Ubuntu 22.04 or CentOS 8

    control.example.com
    node1.example.com
    node2.example.com

If you are creating your environment to practice in the cloud (AWS, Azure, GCP, or another cloud provider), you need to meet the requirements mentioned above. Note that virtual machines can connect to each other over SSH and add the necessary entries in /etc/hosts so that they can communicate with each other by name.

Update “~/.ssh/config” file on Control node to:
```
Host node*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  User <node_user>
  IdentityFile <path_to_private_ssh_key>
```
Update “/etc/hosts” file on each node to (change the ip to your nodes’ ip):
```
127.0.0.1 localhost
192.168.0.100 control.example.com control
192.168.0.101 node1.example.com node1
192.168.0.102 node2.example.com node2
```
<sub>**Note:** For these tasks, you will be working mostly on the control virtual machine. You will only need to log on to the managed nodes to troubleshoot. These virtual machines must be connected to the internet, and SSH access to the other VMs must be allowed from control.example.com. The VMs should resolve each other's FQDN (add entries in /etc/hosts).</sub>

Cloud Environment

If you are creating your environment to practice in the cloud (AWS, Azure, GCP, or another cloud provider), you need to meet the requirements mentioned above. Note that virtual machines can connect to each other over SSH and add the necessary entries in /etc/hosts so that they can communicate with each other by name.
Task

The purpose of this task is to apply theoretical knowledge in practice and acquire hands-on experience using the tools and technologies presented in this submodule.

Based on the requirements described, complete the following tasks:
