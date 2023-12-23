#!/bin/bash

# Variables
role_name="common"
required_packages=("curl" "lsof" "mc" "nano" "tar" "unzip" "vim" "zip")
inventory_file="inventory.ini"
playbook_file="common_playbook.yml"
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

# Function to create Ansible role directory structure
create_role() {
    echo "Creating Ansible role structure for '$role_name'..."
    mkdir -p roles/$role_name/{defaults,tasks,handlers}
    echo "Role structure created."
}

# Function to create task to install required packages
create_package_task() {
    echo "Creating task to install required packages..."
    cat <<EOF > roles/$role_name/tasks/main.yml
---
- name: Install Required Packages
  package:
    name: "{{ item }}"
    state: present
  with_items:
    - ${required_packages[@]}
EOF
    echo "Task to install packages created."
}

# Function to create task to disable SELinux
create_selinux_task() {
    echo "Creating task to disable SELinux and reboot if necessary..."
    cat <<EOF > roles/$role_name/tasks/selinux.yml
---
- name: Disable SELinux
  seboolean:
    name: "{{ item }}"
    state: no
  with_items:
    - selinuxuser_ping
  notify:
    - Reboot if SELinux Disabled
EOF

    echo "Creating SELinux handlers file..."
    cat <<EOF > roles/$role_name/handlers/main.yml
---
- name: Reboot if SELinux Disabled
  command: shutdown -r now
  async: 1
  poll: 0
EOF

    echo "Task to disable SELinux and handlers created."
}

# Function to create playbook to run the 'common' role
create_playbook() {
    echo "Creating playbook to run the 'common' role..."
    cat <<EOF > "$playbook_file"
---
- name: Run 'common' Role
  hosts: all
  roles:
    - $role_name
EOF
    echo "Playbook created."
}

# Function to delete Ansible files
delete_all() {
    echo "Deleting Ansible structure..."
    rm -rf roles "$inventory_file" "$playbook_file"
    echo "Ansible structure deleted."
}

# Function to run Ansible playbook
run_playbook() {
    echo "Running Ansible playbook..."
    ansible-playbook -i "$inventory_file" "$playbook_file"
}

# Main execution
create_inventory
create_role
create_package_task
create_selinux_task
create_playbook
run_playbook
delete_all

echo "Task 2 complete."
