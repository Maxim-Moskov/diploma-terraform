variable "sa_key_file" {
  description = "Путь к авторизованному ключу сервисного аккаунта"
  type        = string
  default     = "/home/max/ter-homeworks/03/src/key.json"
}

variable "folder_id" {
  description = "Идентификатор каталога Yandex Cloud"
  type        = string
  default     = "b1g75upb479gc00alfll"
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-d"
}

variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
  default     = "diploma-app"
}

variable "vm_user" {
  description = "Пользователь, создаваемый на виртуальной машине"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу для доступа на ВМ"
  type        = string
  default     = "/home/max/.yc-diploma/diploma_vm.pub"
}

variable "vm_cores" {
  description = "Количество ядер"
  type        = number
  default     = 2
}

variable "vm_core_fraction" {
  description = "Гарантированная доля vCPU в процентах"
  type        = number
  default     = 20
}

variable "vm_memory" {
  description = "Объём оперативной памяти в гигабайтах"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Размер загрузочного диска в гигабайтах"
  type        = number
  default     = 15
}

variable "image_family" {
  description = "Семейство образа операционной системы"
  type        = string
  default     = "ubuntu-2204-lts"
}
