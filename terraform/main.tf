
#Huvudkonfigurationsfil

terraform {
  required_providers {
    virtualbox = {
      source = "alouette/virtualbox"
      version = "7.2.16r174877"
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
  network_interface {
    adapter_type = "hostonly"
  }
}

