# Configure the DigitalOcean Provider
# Will use content of DIGITALOCEAN_TOKEN env variable
provider "digitalocean" {

}

# Adjust number of servers to match your needs
variable "number_of_servers" {
  default = "2"
}

# Create droplet based on centos image
resource "digitalocean_droplet" "web" {
  count = "${var.number_of_servers}"
  image = "centos-7-0-x64"
  name = "web-server-${count.index}"
  region = "ams2"
  size = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.ssh.id}"]

  # Install and run Apache httpd right after
  # provisioning droplet
  provisioner "remote-exec" {
    inline = [
      "yum -y install httpd",
      "systemctl start httpd"
    ]
  }

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file("../id_rsa_clear")}"
  }
}

# Create SSH key that can be connected to droplets
resource "digitalocean_ssh_key" "ssh" {
  name = "Terraform Example"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMRib4BZcrv3hS8agJA0BOGlU/5P8lW5h5HW5elxEWuzElRjCr0ReEVAceVBm50rGc/rqf40zfaNGMGXe3c3u6r4ZMLNbq+xjh7aeC0zeAvAEQmzH0ErW+aLVda3CA2G2vKt1zMGv4Vu5IoH4gj0fZUiv2OKgheuPe/icH8Mc5j/rqbVEXR2HZHcjDIwf1BcBeDIMg2Nsh+bvCTh3KGLdEkEg9bhK0RNj/s4qEoi8INA1dLCK7TLTzuHtW7Ntdvg1lTHEzhHh2U4coGJi5VPLfPnwLpNr04sC89KNUzVIuxrp8FxfgZbLR4harX3Mp8C0q98s/C/BoN/QxotX5dPJH stefan.landro@gmail.com"
}

# Domain name
variable "digital_ocean_domain_name" {
  default = "do.landro.io"
}

# Looked up manually in aws route 53 console
# Consider using aws_route53_zone resource instead
variable "dns_zone_id" {
  default = "Z2X1UBSEPFNQNM"
}

# Create DNS records in order to manage servers
resource "aws_route53_record" "ssh" {
  count = "${var.number_of_servers}"
  zone_id = "${var.dns_zone_id}"
  name = "ssh${count.index}.${var.digital_ocean_domain_name}"
  type = "A"
  ttl = "60"
  records = ["${element(digitalocean_droplet.web.*.ipv4_address, count.index)}"]
}

# Create floating IPs and connect to droplets
resource "digitalocean_floating_ip" "web" {
  count = "${var.number_of_servers}"
  droplet_id = "${element(digitalocean_droplet.web.*.id, count.index)}"
  region = "${element(digitalocean_droplet.web.*.region, count.index)}"
}

# Create DNS records using floating IP
resource "aws_route53_record" "do" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.digital_ocean_domain_name}."
  type = "A"
  ttl = 60
  records = ["${digitalocean_floating_ip.web.*.ip_address}"]
}

# Multi provider - multi datacenter
# Using DNS failover

variable "javazone_domain_name" {
  default = "javazone.landro.io"
}

# Create DNS records digital ocean
resource "aws_route53_record" "javazone-do" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.javazone_domain_name}"
  type = "A"

  weighted_routing_policy {
    weight = "${var.number_of_servers}"
  }
  set_identifier = "do"

  alias {
    name = "${aws_route53_record.do.fqdn}"
    zone_id = "${aws_route53_record.do.zone_id}"
    evaluate_target_health = true
  }

  health_check_id = "${aws_route53_health_check.do.id}"

}

# Create DNS records amazon ecs
resource "aws_route53_record" "javazone-ecs" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.javazone_domain_name}"
  type = "A"

  weighted_routing_policy {
    weight = "${var.asg_max}"
  }
  set_identifier = "ecs"

  alias {
    name = "${aws_alb.main.dns_name}"
    zone_id = "${aws_alb.main.zone_id}"
    evaluate_target_health = true
  }

  health_check_id = "${aws_route53_health_check.ecs.id}"

}

# Create health check for service running on
# virtual machines (droplets) at Digital Ocean
resource "aws_route53_health_check" "do" {
  fqdn = "${var.digital_ocean_domain_name}"
  port = 80
  type = "HTTP"
  resource_path = "/images/poweredby.png"
  failure_threshold = "3"
  request_interval = "10"
}

# Create health check for service running on elastic
# container service (ECS) at Amazon
resource "aws_route53_health_check" "ecs" {
  fqdn = "${aws_alb.main.dns_name}"
  port = 80
  type = "HTTP"
  resource_path = "/images/poweredby.png"
  failure_threshold = "3"
  request_interval = "10"
}

