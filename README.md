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
## Task 1
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
#### Task Implementation
To achieve the task goals, a Bash script (**[task1.sh](./task1.sh)**) automates Ansible tasks:

- Generates an Ansible inventory with specified node aliases and users.
- Runs ad hoc commands for testing connectivity and executing basic commands.
- Prints Ansible facts, including distribution and hostname.
- Creates an Ansible playbook for displaying network interfaces.
- Executes the playbook on specified managed nodes.
- Ensures cleanup by removing temporary inventory and playbook files.
```
[ec2-user@ip-192-168-0-145 ansible]$ ./task1.sh >task1_logs && echo See task1_logs
See task1_logs
```    
All logs are saved in the **'[task1_logs](./task1_logs)'** file, providing a comprehensive overview of the executed tasks and their outcomes.
#### Managed Nodes Check
```
[ec2-user@ip-192-168-0-145 ansible]$ ping -c 2 node1
PING node1.example.com (192.168.0.205) 56(84) bytes of data.
64 bytes from node1.example.com (192.168.0.205): icmp_seq=1 ttl=255 time=2.68 ms
64 bytes from node1.example.com (192.168.0.205): icmp_seq=2 ttl=255 time=2.61 ms

--- node1.example.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1012ms
rtt min/avg/max/mdev = 2.619/2.653/2.687/0.034 ms

[ec2-user@ip-192-168-0-145 ansible]$ ping -c 2 node2
PING node2.example.com (192.168.0.77) 56(84) bytes of data.
64 bytes from node2.example.com (192.168.0.77): icmp_seq=1 ttl=64 time=3.87 ms
64 bytes from node2.example.com (192.168.0.77): icmp_seq=2 ttl=64 time=1.61 ms

--- node2.example.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1013ms
rtt min/avg/max/mdev = 1.616/2.745/3.874/1.129 ms

[ec2-user@node1 ~]$ htop --version
htop 2.0.2 - (C) 2004-2018 Hisham Muhammad
Released under the GNU GPL.
ubuntu@node2:~$ htop --version
htop 3.0.5
```
## Task 2
For this task, you will create your first Ansible role; use variables, handlers, and conditions; deploy your first software; and configure an OS with Ansible.

**Goals:**
- Create the new role '*common*' with the following structure:
    - defaults
    - tasks
    - handlers
- Create a task (e.g., a package) to install a list of required packages on all managed nodes. The task must install nothing by default.
   - Use *include_tasks* to include the package tasks in the main.yml file.
   - The list of required packages includes *curl*, *lsof*, *mc*, *nano*, *tar*, *unzip*, *vim*, and *zip*.
- Create a new task to disable *SELinux* on the managed nodes.
   - The task must do nothing by default.
   - Reboot nodes where SELinux was disabled, and skip reboot if SELinux is already disabled.
- Create a playbook to run the '*common*' role.
   - Run the playbook for all managed nodes.
## Initial Node Assessment
```
[ec2-user@ip-192-168-0-145 ansible]$ ansible -i hosts node1 -m shell -a '/usr/sbin/getenforce'
node1 | CHANGED | rc=0 >>
Disabled

[ec2-user@ip-192-168-0-145 ansible]$ ansible -i hosts node2 -m shell -a 'getenforce'
node2 | FAILED | rc=127 >>
/bin/sh: 1: getenforce: not foundnon-zero return code
```
- On *node1*, *SELinux* is confirmed to be disabled.
- On *node2*, an attempt to execute getenforce fails, indicating that SELinux is not present.
```
[ec2-user@ip-192-168-0-145 ansible]$ ansible -i hosts node1 -m shell -a 'which curl /usr/sbin/lsof mc nano tar unzip vim zip || true' -o
node1 | CHANGED | rc=0 | (stdout) /bin/curl (stderr) which: no lsof in (/usr/sbin)\nwhich: no mc in (/sbin:/bin:/usr/sbin:/usr/bin)\nwhich: no nano in (/sbin:/bin:/usr/sbin:/usr/bin)\nwhich: no tar in (/sbin:/bin:/usr/sbin:/usr/bin)\nwhich: no unzip in (/sbin:/bin:/usr/sbin:/usr/bin)\nwhich: no vim in (/sbin:/bin:/usr/sbin:/usr/bin)\nwhich: no zip in (/sbin:/bin:/usr/sbin:/usr/bin)

[ec2-user@ip-192-168-0-145 ansible]$ ansible -i hosts node2 -m shell -a 'which curl lsof mc nano tar unzip vim zip || true' -o
node2 | CHANGED | rc=0 | (stdout) /usr/bin/tar
```
- The output indicates that on *node1*:
   - *curl* is found at */bin/curl*.
   - The following commands are not found in the specified paths: *lsof*, *mc*, *nano*, *tar*, *unzip*, *vim*, *zip*.
- On *node2*, the presence of essential commands (*curl*, *lsof*, *mc*, *nano*, *tar*, *unzip*, *vim*, *zip*) is checked.
   - The results indicate that *tar* is found, while the others are not present.
## Task 3
# Comming soon! Check back often!
