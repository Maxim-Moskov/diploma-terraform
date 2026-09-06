# diploma-terraform

Инфраструктура дипломного проекта в Yandex.Cloud, описанная в Terraform.

Часть итоговой работы курса Netology «DevOps-инженер». Общее описание проекта — в репозитории [diploma-devops](https://github.com/Maxim-Moskov/diploma-devops).

---

## Структура

```
.
├── bootstrap/          # отдельный конфиг: бакет для хранения состояния
│   ├── main.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── outputs.tf
├── main.tf             # сеть, подсеть, security group, виртуальная машина
├── variables.tf
├── versions.tf         # провайдер и backend "s3"
└── outputs.tf
```

Конфигурация разделена на два уровня намеренно. Terraform хранит состояние в S3-бакете, но сам бакет тоже нужно создать — а backend не может ссылаться на несуществующее хранилище. Поэтому `bootstrap/` создаёт бакет и держит своё состояние локально, а корневой конфиг уже использует готовый backend.

---

## Что создаётся

| Ресурс | Имя | Параметры |
|---|---|---|
| Бакет для tfstate | `diploma-tfstate-moskov-2026` | versioning включён, анонимный доступ закрыт |
| Сеть | `diploma-network` | — |
| Подсеть | `diploma-subnet` | `10.10.0.0/24`, зона `ru-central1-d` |
| Security group | `diploma-sg` | вход: 22/TCP, 80/TCP, ICMP; выход: ANY |
| Виртуальная машина | `diploma-app` | `standard-v3`, 2 ядра (20%), 2 ГБ RAM, HDD 15 ГБ, Ubuntu 22.04 LTS |

---

## Требования

- Terraform 1.12.x (`required_version = "~> 1.12.0"`)
- Сервисный аккаунт Yandex.Cloud с ролями `editor` и `storage.admin`
- Авторизованный ключ сервисного аккаунта (`key.json`)
- Статический ключ доступа того же аккаунта — для S3-backend
- SSH-ключ, публичная часть которого прописывается в метаданные ВМ

Из Казахстана прямой Terraform Registry работает нестабильно, поэтому в `~/.terraformrc` прописано зеркало:

```hcl
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
  }
}
```

---

## Применение

### Шаг 1. Бакет для состояния

```bash
cd bootstrap

export TF_VAR_access_key=<key_id статического ключа>
export TF_VAR_secret_key=<secret статического ключа>

terraform init
terraform apply
```

### Шаг 2. Основная инфраструктура

```bash
cd ..

export AWS_ACCESS_KEY_ID=<key_id статического ключа>
export AWS_SECRET_ACCESS_KEY=<secret статического ключа>

terraform init
terraform plan
terraform apply
```

Обрати внимание: bootstrap читает ключи из переменных `TF_VAR_*`, а backend `s3` — из стандартных AWS-переменных. Это разные механизмы, значения одинаковые.

### Результат

```bash
terraform output
```

```
app_url        = "http://81.26.185.75"
ssh_command    = "ssh -i ~/.yc-diploma/diploma_vm ubuntu@81.26.185.75"
vm_external_ip = "81.26.185.75"
vm_internal_ip = "10.10.0.13"
```

---

## Переменные

| Переменная | По умолчанию | Назначение |
|---|---|---|
| `sa_key_file` | `/home/max/ter-homeworks/03/src/key.json` | путь к ключу сервисного аккаунта |
| `folder_id` | `b1g75upb479gc00alfll` | каталог Yandex.Cloud |
| `zone` | `ru-central1-d` | зона доступности |
| `vm_name` | `diploma-app` | имя виртуальной машины |
| `vm_user` | `ubuntu` | пользователь на ВМ |
| `ssh_public_key_path` | `/home/max/.yc-diploma/diploma_vm.pub` | публичный SSH-ключ |
| `vm_cores` | `2` | количество ядер |
| `vm_core_fraction` | `20` | гарантированная доля vCPU, % |
| `vm_memory` | `2` | оперативная память, ГБ |
| `vm_disk_size` | `15` | размер диска, ГБ |
| `image_family` | `ubuntu-2204-lts` | семейство образа ОС |

---

## Особенности конфигурации

**Флаги `skip_*` в backend.** Yandex Object Storage совместим с протоколом S3, но не является AWS. Без `skip_region_validation`, `skip_credentials_validation`, `skip_requesting_account_id` и `skip_s3_checksum` Terraform попытается проверить регион и учётные данные через AWS API и упадёт.

**Образ через `data`-источник.** Берётся последняя сборка семейства `ubuntu-2204-lts`, а не зафиксированный `image_id` — при пересоздании подтянется актуальная версия с накатанными патчами безопасности.

**Ubuntu 22.04, а не 24.04.** В 24.04 идёт Python 3.12, несовместимый с модулем `get_url` из Ansible 2.14, который используется в соседнем репозитории.

**`preemptible = false`.** Прерываемая ВМ дешевле вдвое, но останавливается принудительно каждые 24 часа — это ломало бы автоматический деплой.

**Версионирование бакета.** Если состояние повредится или его затрут, можно откатиться на предыдущую версию. Для файла, описывающего всю инфраструктуру, дешёвая страховка.

---

## Удаление

```bash
terraform destroy                 # инфраструктура
cd bootstrap && terraform destroy # бакет
```

Бакет удаляется последним: пока в нём лежит состояние основного конфига, удалять его нельзя.

---

## Что не хранится в репозитории

`.gitignore` отсекает состояния, каталог `.terraform/`, файлы `*.tfvars` и любые ключи. Секреты передаются исключительно через переменные окружения.
