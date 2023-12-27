#!/bin/bash -xe

# Variables
collectd_role="collectd"
inventory_file="inventory.ini"
playbook_file="collectd_playbook.yml"
node1_alias="node1"
node1_user="ec2-user"
node2_alias="node2"
node2_user="ubuntu"
log_file="task3_logs"

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
    echo "Creating Ansible role structure for '$collectd_role'..."
    mkdir -p roles/$collectd_role/{defaults,files,handlers,tasks,templates}
    echo "Role structure created."
}

# Function to create default variables
create_defaults() {
    echo "Creating default variables..."
    cat <<EOF > roles/$collectd_role/defaults/main.yml
---
install_collectd: true
collectd_exporter_port: 9103
collectd_modules:
  - df
  - processes
  - protocols
  - swap
  - tcpconns
  - uptime
  - users
  - vmem
EOF
}

# Function to create task to manage collectd
create_collectd_task() {
    echo "Creating task to manage collectd..."
    cat <<EOF > roles/$collectd_role/tasks/manage_collectd.yml
---
- name: Manage (Install or Remove) Collectd
  include_tasks: "{{ install_collectd | bool | ternary('install_collectd.yml', 'remove_collectd.yml') }}"
  register: manage_collectd

- name: Debug Manage Collectd
  debug:
    var: manage_collectd
EOF
}

# Function to create main tasks files for installation and removal
create_install_task() {
    echo "Creating task to install collectd..."
    cat <<EOF > roles/$collectd_role/tasks/install_collectd.yml
---
- name: Install Collectd
  block:
    - name: Update OS & Install Collectd
      package:
        name: collectd
        state: latest
      notify: Restart Collectd

    - name: Copy Prometheus Config Template
      template:
        src: prometheus.conf.j2
        dest: /etc/collectd.d/prometheus.conf
      notify:
        - Restart Collectd
        - Test Collectd
  register: install_collectd_var
  when: install_collectd | bool

- name: Debug Install Collectd
  debug:
    var: install_collectd_var
EOF
}

create_remove_task() {
    echo "Creating task to remove collectd..."
    cat <<EOF > roles/$collectd_role/tasks/remove_collectd.yml
---
- name: Remove Collectd
  block:
    - name: Stop and Disable Collectd
      systemd:
        name: collectd
        state: stopped
        enabled: no
      notify: Restart Collectd

    - name: Remove Collectd and Plugins
      package:
        name: collectd
        state: absent
      notify: Restart Collectd

    - name: Remove Config Files
      file:
        path: "/etc/collectd.d/{{ item }}"
        state: absent
      with_items:
        - prometheus.conf
      notify:
        - Restart Collectd
        - Test Collectd

  when: not install_collectd | bool
EOF
}

# Function to create handler to restart collectd
create_handler() {
    echo "Creating handler to restart collectd..."
    cat <<EOF > roles/$collectd_role/handlers/main.yml
---
- name: Collectd Management
  block:
    - name: Restart Collectd
      service:
        name: collectd
        state: restarted

    - name: Test Collectd
      uri:
        url: "http://{{ ansible_hostname }}:{{ collectd_exporter_port }}"
        method: GET
        status_code: 200
        return_content: yes
        validate_certs: no
      register: result
      until: result.status == 200
      retries: 30
      delay: 5
      ignore_errors: true
      changed_when: false
  when: install_collectd | bool
EOF
}

# Function to create Prometheus Config Template
create_prometheus_template() {
    echo "Creating Prometheus Config Template..."
    cat <<EOF > roles/$collectd_role/templates/prometheus.conf.j2
LoadPlugin write_prometheus
<Plugin write_prometheus>
   Port {{ collectd_exporter_port }}
   {% for module in collectd_modules %}
   LoadPlugin {{ module }}
   {% endfor %}
</Plugin>
EOF
}

# Function to create playbook to run the 'collectd' role
create_playbook() {
    echo "Creating playbook to run the '$collectd_role' role..."
    cat <<EOF > "$playbook_file"
---
- name: Run '$collectd_role' Role
  hosts: all
  roles:
    - $collectd_role
EOF
    echo "Playbook created."
}

# Function to delete Ansible files
delete_all() {
    cat "$inventory_file" "$playbook_file" \
        roles/$collectd_role/templates/prometheus.conf.j2 \
        roles/$collectd_role/handlers/main.yml \
        roles/$collectd_role/tasks/remove_collectd.yml \
        roles/$collectd_role/defaults/main.yml \
        roles/$collectd_role/tasks/install_collectd.yml \
        roles/$collectd_role/tasks/manage_collectd.yml
    echo "Deleting Ansible structure..."
    rm -rf roles "$inventory_file" "$playbook_file"
    echo "Ansible structure deleted."
}

# Function to run Ansible playbooks
run_playbooks() {
    echo "Running Ansible playbooks..."
    ansible-playbook -i "$inventory_file" "$playbook_file" -vv
#    ansible-playbook -i "$inventory_file" "$playbook_file" \
#        -e install_collectd=false -vv
}

# Redirect all output to a log file
exec > >(tee -a ${log_file}) 2>&1

# Log the script start time
echo "Script started: $(date)"

# Main execution
create_inventory
create_role
create_defaults
create_collectd_task
create_install_task
create_remove_task
create_handler
create_prometheus_template
create_playbook
run_playbooks
delete_all

echo "Task 3 complete."

# Log the script end time
echo "Script completed: $(date)"

