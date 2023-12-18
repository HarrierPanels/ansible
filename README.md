[![EPAM](https://img.shields.io/badge/Cloud&DevOps%20UA%20Lab%202nd%20Path-Ansible-orange)](./)
[![EPAM](https://img.shields.io/badge/Configuration%20Management-Practical%20Tasks-blue)](./)
[![HitCount](https://hits.dwyl.com/HarrierPanels/ansible.svg?style=flat&show=unique)](http://hits.dwyl.com/HarrierPanels/ansible)
<br>
## Practical Task
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
Host node*
```
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  User <node_user>
  IdentityFile <path_to_private_ssh_key>
```
