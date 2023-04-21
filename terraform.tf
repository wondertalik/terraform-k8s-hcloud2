terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.38.2"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.2"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }

  required_version = ">= 1.4.4"
}
