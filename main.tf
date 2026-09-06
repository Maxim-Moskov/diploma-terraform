data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_vpc_network" "diploma" {
  name        = "diploma-network"
  description = "Сеть дипломного проекта"
}

resource "yandex_vpc_subnet" "diploma" {
  name           = "diploma-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.diploma.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_security_group" "diploma" {
  name        = "diploma-sg"
  description = "Доступ к приложению и управлению"
  network_id  = yandex_vpc_network.diploma.id

  ingress {
    protocol       = "TCP"
    description    = "SSH для администрирования и деплоя из CI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP для веб-приложения"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "ICMP"
    description    = "Диагностика доступности"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Исходящий трафик: обновления и загрузка образов"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "app" {
  name        = var.vm_name
  hostname    = var.vm_name
  platform_id = "standard-v3"
  zone        = var.zone

  allow_stopping_for_update = true

  resources {
    cores         = var.vm_cores
    core_fraction = var.vm_core_fraction
    memory        = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.diploma.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.diploma.id]
  }

  metadata = {
    ssh-keys           = "${var.vm_user}:${file(var.ssh_public_key_path)}"
    serial-port-enable = "1"
  }

  scheduling_policy {
    preemptible = false
  }
}
