terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.38.0"
    }
  }

  required_version = ">= 1.4.4"
}
