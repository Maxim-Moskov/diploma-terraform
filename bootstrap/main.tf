resource "yandex_storage_bucket" "tfstate" {
  access_key = var.access_key
  secret_key = var.secret_key
  bucket     = var.bucket_name

  versioning {
    enabled = true
  }

  anonymous_access_flags {
    read = false
    list = false
  }
}
