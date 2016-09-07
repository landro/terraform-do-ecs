footer: Javazone 2016 - 8. September 2016
slidenumbers: true

![](bekk.mov)

---

#[fit] Terraform 
## colonise the cloud!
### Stefan Magnus Landrø, BEKK Consulting

---

# Terraform 
 
- Commandline tool (OS X, Windows, Linux, …)
- Developed by Hashicorp (Vagrant, Packer, Consul, Nomad)
- Lets you describe and provision cloud infrastructure using json-like text files 
- Servers, networks, load balancing, storage
- Multi-provider (AWS, Azure, GC, Cloudstack, …)

---

# Demo

- Digital Ocean (Amsterdam, The Netherlands)
- 2 virtual machines (CentOS/Linux)
- Log in using public/private key
- Run Apache httpd web server
- Domain name (DNS) (AWS)
- Multi datacenter, multi provider, multi technology!

---

# Provider (1)

- A **provider** is used to connect to a cloud provider
- AWS, Azure, GC, Digital Ocean, Cloudstack, Openstack, Heroku, CloudFoundry, Mailgun, easyDNS, CloudFlare…
- **Providers** know the APIs and expose available services 

---

# Resource (2)

- A **resource** defines how to use a cloud resource/service
  - VM, IP-address, load balancer, network, firewall, object storage, DNS-record 
- The name of the provider is used as a **resource** name prefix
- **Resources** have unique ids
  - Combination of resource type and name

---

# Dependencies (3)

- A **resource** can depend on another **resource**
- Can determine the order of creation

---

# state og taint

- When manipulating **resources**, Terraform saves the current state i a .tfstate file (or S3, Atlas)
- Knows a **resource's** current state in the cloud

        terraform show

- When resources have to be recreated, it can be tainted

        terraform taint

---

# Syntax (4)

- Variables
- Interpolation
- Functions
  - base64, join, split, lower, upper, …

---

# Bonus: Domain Name Service 

- Decentralised name system on the Internet
- A domain name can contain different types of records  
- E.g.: www.vg.no
  - A: 195.88.55.16
  - A: 195.88.54.16
  - AAAA: 2001:67c:21e0::16

---

# Multi-provider (5)

- Can connect **resources** from different cloud providers
- Unique feature in Terraform!

---

# provisioner (6)

- A **provisioner** lets you provision against the **resource** right after creation
  - chef
  - remote-exec (script run on the server)
  - local-exec (script run locally)

---

# Bonus: floating IP (7)


- Floating IPs (Elastic IPs) are IP-adresses that can be moved between servers dynamically
- Prevent changing public IP in case of backend changes (no firewall issues)

---

# Let's go docker!

- Run docker containers on Elastic Container Service 
- Virtual Private Cloud (VPC) (Security groups etc)
- Autoscaling group (Core OS)
- Container cluster  
- Container Task/Service
- ALB Load Balancer


---

# Multi provider, multi datacenter, multi technology (8)

- DNS using weighted record set
  - Could have used latency / geolocation
- Health checks to determine data center (or service) outage

---

# Bonus: Dependency graph

- Dependency graphs can be generated dynamically

        terraform graph | dot -Tpng | open -f -a Preview


---

# Code

[github.com/landro/terraform-do-ecs](http://github.com/landro/terraform-do-ecs)

---

# [fit]Q&A
_
@landro
github.com/landro

---

![](bekk.mov)

