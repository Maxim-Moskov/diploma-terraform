terraform {
  required_version = "~> 1.12.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.100.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "diploma-tfstate-moskov-2026"
    region = "ru-central1"
    key    = "diploma/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  service_account_key_file = var.sa_key_file
  folder_id                = var.folder_id
  zone                     = var.zone
}
