#!/bin/bash

# Variables
inventory_file="inventory.ini"
playbook_file="network_interfaces.yml"
node1_alias="node1"
node1_user="ec2-user"
node2_alias="node2"
node2_user="ubuntu"

# Function to create Ansible inventory
create_inventory() {
    cat <<EOF > "$inventory_file"
[managed_nodes]
$node1_alias ansible_user=$node1_user
$node2_alias ansible_user=$node2_user

[managed_nodes:vars]
ansible_python_interpreter=auto_legacy_silent
EOF
}

# Function to create Ansible playbook
create_playbook() {
    cat <<EOF > "$playbook_file"
---
- name: Print Network Interfaces
  hosts: managed_nodes
  gather_facts: yes

  tasks:
    - name: Display Network Interfaces
      debug:
        var: ansible_interfaces
EOF
}

# Task 1: Create Ansible inventory
echo "Task 1: Creating Ansible inventory $inventory_file:"
create_inventory
cat $inventory_file

# Task 2: Run ad hoc commands
echo "Task 2: Runing ad hoc commands:"
ansible -i "$inventory_file" managed_nodes -m ping
ansible -i "$inventory_file" managed_nodes -a "uname -a"
ansible -i "$inventory_file" managed_nodes -a "uptime"
ansible -i "$inventory_file" managed_nodes -b -m package -a "name=htop state=present"

# Task 3: Print Ansible facts
echo "Task 3: Printing Ansible facts:"
ansible -i "$inventory_file" managed_nodes -m setup -a "filter=ansible_distribution"
ansible -i "$inventory_file" managed_nodes -m setup -a "filter=ansible_hostname"


# Task 4: Create Ansible playbook
echo "Creating Ansible playbook $playbook_file:"
create_playbook
cat $playbook_file

# Task 5: Run Ansible playbook
echo "Task 5: Runing Ansible playbook:"
ansible-playbook -i "$inventory_file" "$playbook_file"
rm "$inventory_file" "$playbook_file"
echo 'Tasks Complete!'
