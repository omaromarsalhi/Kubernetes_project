# Ansible Playbooks for Kubernetes Cluster Setup

This directory contains Ansible playbooks to configure the Kubernetes cluster components based on the Medium guide.

## Project Structure

```
ansible/
├── ansible.cfg
├── ansible-bastion.cfg
├── inventory.ini
├── README.md
├── playbooks/
│   └── haproxy-playbook.yml
└── roles/
    └── haproxy/
        ├── handlers/
        │   └── main.yml
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   └── haproxy.cfg.j2
        └── vars/
            └── main.yml
```

## Running from Bastion Host

If you're running Ansible from the bastion host (as shown in your command), make sure:

1. The ansible directory is copied to `/home/ec2-user/ansible/`
2. Run from the ansible directory:
   ```bash
   cd /home/ec2-user/ansible
   ansible-playbook -i inventory.ini playbooks/haproxy-playbook.yml
   ```

## Steps

1. **Update Inventory**:
   - Replace `BASTION_PUBLIC_IP` with the actual bastion public IP
   - Replace `LOAD_BALANCER_PRIVATE_IP` with the actual load balancer private IP

2. **Run HAProxy Playbook**:
   ```bash
   ansible-playbook -i inventory.ini playbooks/haproxy-playbook.yml
   ```

## Bastion Host Configuration

The inventory includes a bastion host for secure access to private instances. Ansible is configured to automatically proxy SSH connections through the bastion host using the `ProxyCommand` in `ansible.cfg`. This allows direct access to private instances without manual SSH tunneling.

### Testing the Playbook

### Quick Test Commands

1. **Syntax Check** (recommended before running):
   ```bash
   ansible-playbook --syntax-check -i inventory.ini playbooks/haproxy-playbook.yml
   ```

2. **List Hosts** (see which hosts will be affected):
   ```bash
   ansible-playbook --list-hosts -i inventory.ini playbooks/haproxy-playbook.yml
   ```

3. **List Tasks** (see what tasks will run):
   ```bash
   ansible-playbook --list-tasks -i inventory.ini playbooks/haproxy-playbook.yml
   ```

4. **Dry Run** (see what would change without making changes):
   ```bash
   ansible-playbook --check -i inventory.ini playbooks/haproxy-playbook.yml
   ```

### Run the Playbook

**Basic run:**
```bash
ansible-playbook -i inventory.ini playbooks/haproxy-playbook.yml
```

**With verbose output:**
```bash
ansible-playbook -v -i inventory.ini playbooks/haproxy-playbook.yml
```

**With very verbose output:**
```bash
ansible-playbook -vv -i inventory.ini playbooks/haproxy-playbook.yml
```

### Automated Testing Script

Run the included test script:
```bash
chmod +x test-playbook.sh
./test-playbook.sh
```

This will check syntax, list hosts/tasks, and provide the final run command.

## Troubleshooting

### SSH Connection Issues

If you get "kex_exchange_identification: Connection closed by remote host":

1. **Test manual SSH connection**:
   ```bash
   ssh -i ~/.ssh/id_rsa ec2-user@10.0.21.19
   ```

2. **Check SSH key permissions**:
   ```bash
   chmod 600 ~/.ssh/id_rsa
   ```

3. **Test with Ansible ping**:
   ```bash
   ansible -i inventory.ini lb -m ping
   ```

4. **Check security groups**: Ensure the bastion security group allows outbound SSH (port 22) to the load balancer security group

5. **Verify SSH service is running on target**:
   ```bash
   ssh ec2-user@10.0.21.19 "sudo systemctl status sshd"
   ```

### Common Issues

- **Role not found**: Ensure `roles_path` is set correctly in `ansible.cfg`
- **Permission denied**: Check SSH key permissions and ownership
- **Host key verification**: The config has `host_key_checking = False` to avoid this
- **Python interpreter**: Amazon Linux uses `/usr/bin/python3`
