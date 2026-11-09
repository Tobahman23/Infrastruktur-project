
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
  name = "E"
  image = "batocera-x86_64-42-20251006.img"
  cpus = 2
  memory = 4000
  network_adapter {
    type = "hostonly"
  }
}
resource "virtualbox_vm" "tinycore" {
  name = "A"
  image = "TinyCore-current.iso"
  cpus = 1
  memory = 1000
  network_adapter {
    type = "hostonly"
  }
}
output "CombinedMemoryUsage" {
  value = virtualbox_vm.batocera.memory + virtualbox_vm.tinycore.memory
}
output "CombinedCpusUsed" {
  value = virtualbox_vm.batocera.cpus + virtualbox_vm.tinycore.cpus
}
output "StatusBatocera" {
  value = virtualbox_vm.batocera.status
}
output "StatusTinyCore" {
  value = virtualbox_vm.tinycore.status
}

