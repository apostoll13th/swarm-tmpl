provider "yandex" {
  service_account_key_file = var.path_to_service_account_key_file
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
}
