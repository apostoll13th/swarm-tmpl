data "yandex_vpc_subnet" "default" {
  name = "default-ru-central1-a"
}

data "yandex_compute_image" "ubuntu_image" {
  folder_id = "standard-images"
  family    = "ubuntu-2204-lts"
}