#!/bin/bash

# Variables
role_name="common"
packages=("curl" "lsof" "mc" "nano" "tar" "unzip" "vim" "zip")
inventory_file="inventory.ini"
playbook_file="common_playbook.yml"
node1_alias="node1"
node1_user="ec2-user"
node2_alias="node2"
node2_user="ubuntu"

# Function to modify package array for Ansible
create_package_array() {
    # Create new array with commas
    required_packages=()
    for (( i=0; i<${#packages[@]}-1; i++ )); do
        required_packages+=("${packages[$i]},")
    done
    required_packages+=("${packages[-1]}")
}

# Print new array
echo "${packages_with_commas[@]}"


# Function to create Ansible inventory
create_inventory() {
    cat <<EOF > "$inventory_file"
[managed_nodes]
$node1_alias ansible_user=$node1_user
$node2_alias ansible_user=$node2_user

[managed_nodes:vars]
ansible_become=yes
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
    cat <<EOF > roles/$role_name/tasks/install_packages.yml
---
- name: Update Amazon Linux 2
  when: ansible_os_family == 'RedHat'
  yum:
    name: '*'
    state: latest

- name: Update Ubuntu
  when: ansible_os_family == 'Debian'
  apt:
    upgrade: dist
    update_cache: yes

- name: Install Required Packages
  package:
    name: "{{ item }}"
    state: latest
  with_items:
    - "{{ 'libsemanage-python' if ansible_distribution == 'Amazon' else 'python3-semanage' }}"
    - "{{ 'libselinux-python' if ansible_distribution == 'Amazon' else 'python3-selinux' }}"
    - "{{ 'selinux-policy' if ansible_distribution == 'Amazon' else 'policycoreutils,selinux-utils,selinux-basics' }}"
    - ${required_packages[*]}
  when: install_required_packages | default(false) | bool
  register: install_pack

- name: Show Install Required Packages output
  debug:
    var: install_pack
EOF
    echo "Task to install packages created."
}

# Function to create task to disable SELinux
create_selinux_task() {
    echo "Creating task to disable SELinux and reboot if necessary..."
    cat <<EOF > roles/$role_name/tasks/selinux.yml
---
- name: Ensure SELinux-policy package is installed
  package:
    name: "{{ 'selinux-policy' if ansible_distribution == 'Amazon' else 'policycoreutils,selinux-utils,selinux-basics' }}"
    state: latest

- name: Disable SELinux
  selinux:
    policy: "{{ 'targeted' if ansible_distribution == 'Amazon' else 'default' }}"
    state: disabled
  when: disable_selinux_task | default(false) | bool
  notify:
    - Reboot if SELinux Disabled

- name: Wait for system to become reachable after reboot
  wait_for:
    host: "{{ inventory_hostname }}"
    port: 22
    timeout: 300
    delay: 10
  when: disable_selinux_task | default(false) | bool
EOF

    echo "Creating SELinux handlers file..."
    cat <<EOF > roles/$role_name/handlers/main.yml
---
- name: Reboot if SELinux Disabled
  command: shutdown -r now
  async: 1
  poll: 0
  when: disable_selinux_task | default(false) | bool
EOF

    echo "Task to disable SELinux and handlers created."
}

# Function to create main tasks file including the package tasks
create_main_tasks() {
    echo "Creating main tasks file..."
    cat <<EOF > roles/$role_name/tasks/main.yml
---
- name: Install packages
  include_tasks: install_packages.yml

- name: Disable SELinux
  include_tasks: selinux.yml
EOF
    echo "Main tasks file created."
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
    ansible-playbook -i "$inventory_file" "$playbook_file" \
      -e "install_required_packages=true"  -e "disable_selinux_task=true" -v
}

# Main execution
create_package_array
create_inventory
create_role
create_package_task
create_selinux_task
create_main_tasks
create_playbook
run_playbook
delete_all

echo "Task 2 complete."