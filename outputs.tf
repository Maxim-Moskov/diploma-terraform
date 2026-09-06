output "vm_external_ip" {
  description = "Публичный IP-адрес виртуальной машины"
  value       = yandex_compute_instance.app.network_interface.0.nat_ip_address
}

output "vm_internal_ip" {
  description = "Внутренний IP-адрес виртуальной машины"
  value       = yandex_compute_instance.app.network_interface.0.ip_address
}

output "ssh_command" {
  description = "Готовая команда для подключения к виртуальной машине"
  value       = "ssh -i ~/.yc-diploma/diploma_vm ${var.vm_user}@${yandex_compute_instance.app.network_interface.0.nat_ip_address}"
}

output "app_url" {
  description = "Адрес веб-приложения"
  value       = "http://${yandex_compute_instance.app.network_interface.0.nat_ip_address}"
}
