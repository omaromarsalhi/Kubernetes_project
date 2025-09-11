# Kubernetes Cluster Implementation
## Production-Ready Kubernetes Cluster on AWS

This project implements a production-ready Kubernetes cluster following the Medium guide: [Deploying a Production Kubernetes Cluster in 2023-2024](https://medium.com/@augustineozor/deploying-a-production-ready-kubernetes-cluster-in-2023-2024-a-step-by-step-guide-part-1-8f6b2e8c1c1a)

## 🏗️ Architecture Overview

```
Internet → Load Balancer (HAProxy) → [ETCD Cluster | K8s Masters | Workers]
                                      ↓
                               Shared Storage (iSCSI + OCFS2)
```

### 📋 Infrastructure Diagram
For a detailed visual representation of the infrastructure, see:
- **Interactive Diagram**: [infra_with_nfs.html](infra_with_nfs.html)
- **Static Image**: [kubernetes-infrastructure-nfs.png](kubernetes-infrastructure-nfs.png)

![Kubernetes Infrastructure with NFS](kubernetes-infrastructure-nfs.png)

## 📊 Current Status

### ✅ COMPLETED COMPONENTS
- **Infrastructure**: VPC, subnets, security groups, EC2 instances (Terraform)
- **HAProxy Load Balancer**: Configured for ETCD (2379) and Kubernetes API (6443)
- **ETCD Role**: Complete Ansible automation for 3-node ETCD cluster
- **Security Groups**: Proper access rules for all components

### 🚀 READY FOR DEPLOYMENT
- **ETCD Cluster**: Ansible role created and ready to deploy
- **Kubernetes Masters**: Next component to implement
- **Monitoring**: Prometheus + Grafana stack
- **Storage**: iSCSI + OCFS2 shared storage

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured
- Terraform v1.0+
- Ansible v2.9+
- SSH key pair

### Infrastructure Deployment
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### ETCD Cluster Deployment
```bash
cd ansible
ansible-playbook -i inventory.ini playbooks/etcd-playbook.yml
```

### HAProxy Deployment
```bash
cd ansible
ansible-playbook -i inventory.ini playbooks/haproxy-playbook.yml
```

## 📁 Project Structure

```
kubernetes_project/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                  # Main infrastructure
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── modules/
│       ├── vpc/                # Network configuration
│       ├── security_groups/    # Security rules
│       └── ec2_cluster/        # EC2 instances
├── ansible/                     # Configuration Management
│   ├── ansible.cfg             # Ansible configuration
│   ├── inventory.ini           # Host inventory
│   ├── playbooks/              # Deployment playbooks
│   │   ├── etcd-playbook.yml   # ETCD cluster deployment
│   │   └── haproxy-playbook.yml # Load balancer deployment
│   └── roles/                  # Ansible roles
│       ├── etcd/               # ETCD cluster role
│       └── haproxy/            # HAProxy load balancer role
├── HANDOFF_SUMMARY.txt         # Project status for handoff
└── README.md                   # This file
```

## 🔧 Components

### Infrastructure (Terraform)
- **VPC**: 10.0.0.0/16 with public/private subnets across 3 AZs
- **EC2 Instances**:
  - Bastion host (public)
  - Load balancer (public)
  - 2x ETCD nodes (private)
  - 2x Master nodes (private)
  - 2x Worker nodes (private)
  - Storage node (private)

### HAProxy Load Balancer
- **Ports**: 2379 (ETCD), 6443 (Kubernetes API), 8399 (Stats)
- **Features**: Health checks, round-robin load balancing
- **Stats Access**: http://lb-ip:8399/stats_secure (admin/omar123)

### ETCD Cluster
- **Version**: 3.5.9
- **Security**: TLS certificates for all communication
- **Configuration**: Automated cluster formation
- **Health Checks**: Built-in verification

## 🔒 Security Features

- **Network Security**: Security groups with minimal required access
- **SSH Access**: Only through bastion host
- **TLS Encryption**: ETCD with certificate-based authentication
- **Load Balancer Access**: Restricted to necessary ports

## 📈 Monitoring & Access

### HAProxy Statistics
- **URL**: http://[load-balancer-ip]:8399/stats_secure
- **Credentials**: admin / omar123
- **Features**: Real-time connection stats, backend health

### SSH Access Pattern
```bash
# Connect to bastion
ssh -i ~/.ssh/id_rsa ec2-user@bastion-ip

# From bastion, connect to private instances
ssh -i ~/.ssh/id_rsa ec2-user@private-instance-ip
```

## 🚧 Next Steps

1. **Deploy ETCD Cluster**
   ```bash
   ansible-playbook -i inventory.ini playbooks/etcd-playbook.yml
   ```

2. **Implement Kubernetes Masters**
   - Create Ansible role for K3S/Kubernetes
   - Configure master nodes
   - Join to ETCD cluster

3. **Deploy Worker Nodes**
   - Configure worker nodes
   - Join Kubernetes cluster

4. **Set up Shared Storage**
   - iSCSI target on storage node
   - OCFS2 filesystem
   - Mount on all nodes

5. **Configure Networking**
   - Calico/Cilium CNI
   - Network policies

6. **Deploy Monitoring**
   - Prometheus + Grafana
   - AlertManager

## 🐛 Troubleshooting

### Common Issues
- **SSH Connection Failed**: Check security groups and key permissions
- **Ansible Connection Error**: Verify inventory.ini IP addresses
- **HAProxy Not Accessible**: Check security group rules for port 8399

### Logs
```bash
# HAProxy logs
sudo journalctl -u haproxy -f

# ETCD logs
sudo journalctl -u etcd -f

# System logs
sudo journalctl -xe
```

## 📚 Resources

- [Medium Guide: Production Kubernetes Cluster](https://medium.com/@augustineozor/deploying-a-production-ready-kubernetes-cluster-in-2023-2024-a-step-by-step-guide-part-1-8f6b2e8c1c1a)
- [ETCD Documentation](https://etcd.io/docs/)
- [HAProxy Documentation](https://www.haproxy.org/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)

## 🤝 Contributing

This project follows the implementation from the Medium guide. For questions or issues, please check the troubleshooting section or refer to the original guide.

---

**Status**: HAProxy ✅ Complete | ETCD ⚡ Ready to Deploy | Kubernetes 🔄 Next
