
#Huvudkonfigurationsfil

terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox" #Terraform provider för Virtualbox
      version = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {

}


resource "virtualbox_vm" "ubuntu" {
  name = "ubuyes"
  image = "ubuntu.box"
  cpus = 2
  memory = "2048 mib"
  network_adapter {
  type           = "hostonly"
  host_interface = "VirtualBox Host-Only Ethernet Adapter" # Ändra till ditt faktiska kort
  }
  status = "poweroff"
}

resource "virtualbox_vm" "batocera" {
  name = "batoyes"
  image = "batocera.box"
  cpus = 4
  memory = "4096 mib"
  network_adapter {
  type           = "hostonly"
  host_interface = "VirtualBox Host-Only Ethernet Adapter" # Ändra till ditt faktiska kort
  }
  status = "poweroff"
  
}

output "cpus_batocera" {
  value = virtualbox_vm.batocera.cpus
}

output "memory_batocera" {
  value = virtualbox_vm.batocera.memory
}


