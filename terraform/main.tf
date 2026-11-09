
#Huvudkonfigurationsfil

terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {

}

resource "virtualbox_vm" "batocera" {
  name = "TestBatocera"
  image = "batocera-x86_64-42-20251006.img"
  cpus = 2
  memory = 4000
  network_adapter {
    type = "hostonly"
  }
}

