output "prod_ip_addresses" {
  value = [for instance in yandex_compute_instance.prod_instance: instance.network_interface.0.nat_ip_address]
  description = "The public IP addresses of the app instances"
}

output "dev_ip_address" {
  value = yandex_compute_instance.dev_instance[0].network_interface.0.nat_ip_address
  description = "The public IP address of the Graylog instance"
}