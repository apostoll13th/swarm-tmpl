variable "digitalocean_token" {
  description = "token"
  type        = string
}
variable "ssh_key" {
  description = "ssh_key"
  type        = string
}
variable "user_email" {
  description = "user email"
  type        = string
}

variable "vps_count" {
  description = "Число хостов"
  type        = number
  default     = 1
}

variable "ssh_path" {
  type = string
}

variable "user" {
  type = string
}

variable "yandex_cloud_id" {
  description = "token"
  type        = string
}
variable "yandex_folder_id" {
  description = "token"
  type        = string
}

variable "path_to_service_account_key_file" {
  description = "path to key file"
  type = string
}

variable "task_name" {
  type = string
}

variable "aws_token_a" {
  type = string
}

variable "aws_token_b" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "name_aws53_record" {
  type = string
}

variable "graylog_name_aws53_record" {
  type = string
}

variable "ansible_version" {
  type = string
}
