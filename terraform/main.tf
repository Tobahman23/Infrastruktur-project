
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

resource "virtualbox_vm" "batocera" {
  name = "dasagsard"
  image = "batocera.box"
  cpus = 4
  memory = "4096 mib"
  network_adapter {
  type           = "hostonly"
  host_interface = "VirtualBox Host-Only Ethernet Adapter" # Ändra till ditt faktiska kort
  }
  status = "poweroff"
  
}

resource "terraform_data" "configure_vm" {
    provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm ${virtualbox_vm.batocera.name} poweroff
      VBoxManage modifyvm "${virtualbox_vm.batocera.name}" --graphicscontroller vmsvga --vram 128 --accelerate3d on
    EOT
  }
}

output "SpecsBatocera" {
  value = virtualbox_vm.batocera.cpus
}
