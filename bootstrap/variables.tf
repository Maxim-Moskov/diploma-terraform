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
  description = "Зона доступности по умолчанию"
  type        = string
  default     = "ru-central1-d"
}

variable "bucket_name" {
  description = "Имя бакета для хранения состояния Terraform"
  type        = string
  default     = "diploma-tfstate-moskov-2026"
}

variable "access_key" {
  description = "Идентификатор статического ключа доступа"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Секретная часть статического ключа доступа"
  type        = string
  sensitive   = true
}
