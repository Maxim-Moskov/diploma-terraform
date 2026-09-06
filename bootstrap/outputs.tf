output "bucket_name" {
  description = "Имя созданного бакета"
  value       = yandex_storage_bucket.tfstate.bucket
}
