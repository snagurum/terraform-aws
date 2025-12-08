# AWS VPC Terraform Module

This Terraform module provisions an **AWS Virtual Private Cloud (VPC)** with **public** and **private** subnets across multiple Availability Zones.  
It also optionally creates a **NAT Gateway** or **NAT Instance** to allow outbound internet access from private subnets.

---

## 📌 Features

- Creates AWS VPC  
- Creates public and private subnets (multi-AZ)  
- Creates Internet Gateway  
- Optional NAT Gateway  
- Optional NAT Instance  
- Output values for subnets, IGW, NAT components  
- Supports public IP mapping on launch  
- Clean modular architecture (core modules for VPC & subnets)

---

## 🗺 Architecture (ASCII Diagram)
```text
                 +---------------------------+
                 |            VPC            |
                 +---------------------------+
                     /                 \
                    /                   \
                   v                     v
          +----------------+     +----------------+
          | Public Subnets |     | Private Subnets|
          +--------+-------+     +--------+-------+
                   |                      |
                   v                      v
          +----------------+     +------------------------+
          | Internet GW    |     | NAT (Gateway/Instance) |
          +----------------+     +------------------------+

```

---

## 📦 Usage

```hcl
module "network" {
  source = "./modules/aws-vpc"

  name                   = "demo"
  vpc_cidr               = "10.0.0.0/16"
  azs                    = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]

  create_nat_gateway     = true
  create_nat_instance    = false

  map_public_ip_on_launch = true
}

```




