# Configure the DigitalOcean Provider
# Will use content of DIGITALOCEAN_TOKEN env variable
provider "digitalocean" {

}

# Create droplet based on centos image
resource "digitalocean_droplet" "web" {
  count = "2"
  image = "centos-7-0-x64"
  name = "web-server-${count.index}"
  region = "ams2"
  size = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.ssh.id}"]
}

# Create SSH key that can be connected to droplets
resource "digitalocean_ssh_key" "ssh" {
  name = "Terraform Example"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMRib4BZcrv3hS8agJA0BOGlU/5P8lW5h5HW5elxEWuzElRjCr0ReEVAceVBm50rGc/rqf40zfaNGMGXe3c3u6r4ZMLNbq+xjh7aeC0zeAvAEQmzH0ErW+aLVda3CA2G2vKt1zMGv4Vu5IoH4gj0fZUiv2OKgheuPe/icH8Mc5j/rqbVEXR2HZHcjDIwf1BcBeDIMg2Nsh+bvCTh3KGLdEkEg9bhK0RNj/s4qEoi8INA1dLCK7TLTzuHtW7Ntdvg1lTHEzhHh2U4coGJi5VPLfPnwLpNr04sC89KNUzVIuxrp8FxfgZbLR4harX3Mp8C0q98s/C/BoN/QxotX5dPJH stefan.landro@gmail.com"
}