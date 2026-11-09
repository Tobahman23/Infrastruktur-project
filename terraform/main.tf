
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
