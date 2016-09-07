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
}