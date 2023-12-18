[![EPAM](https://img.shields.io/badge/Cloud&DevOps%20UA%20Lab%202nd%20Path-Ansible-orange)](./)
[![EPAM](https://img.shields.io/badge/Configuration%20Management-Practical%20Tasks-blue)](./)
[![HitCount](https://hits.dwyl.com/HarrierPanels/ansible.svg?style=flat&show=unique)](http://hits.dwyl.com/HarrierPanels/ansible)
<br>
## Practical Tasks Prerequisites
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

**Cloud Environment**

If you are creating your environment to practice in the cloud (AWS, Azure, GCP, or another cloud provider), you need to meet the requirements mentioned above. Note that virtual machines can connect to each other over SSH and add the necessary entries in /etc/hosts so that they can communicate with each other by name.

**Tasks**

The purpose of these tasks is to apply theoretical knowledge in practice and acquire hands-on experience using the tools and technologies presented in this submodule.

Based on the requirements described, complete the following tasks:
#### Task 1
For this task, you will install Ansible, set up a sample project, use ad hoc Ansible commands, and get some facts about your managed servers. Also, you will write your very first playbook.

**Goals:**
- Install Ansible to your control machine.
- Using ad hoc commands, do the following tasks on the node1 and node2:
    - Test a response from node1 and node2 using the Ansible module ping.
    - Run the uname -a command on the managed nodes.
    - Check uptime.
    - Install the htop package on the managed nodes.
- Add the managed nodes to the inventory group managed_nodes. You can use either the default inventory location or create a new inventory file in the location you prefer.
- With an ad hoc command, please make sure is everything runs correctly:
    - Print the host names of the managed_nodes group from Ansible-facts.
    - Print the manage nodes distributive name from Ansible-facts.
    - Create a playbook to print a list of network interfaces for every virtual machine.

To achieve the task goals, a Bash script (**[task1.sh](./task1.sh)**) automates Ansible tasks:

- Generates an Ansible inventory with specified node aliases and users.
- Runs ad hoc commands for testing connectivity and executing basic commands.
- Prints Ansible facts, including distribution and hostname.
- Creates an Ansible playbook for displaying network interfaces.
- Executes the playbook on specified managed nodes.
- Ensures cleanup by removing temporary inventory and playbook files.
    
