locals {
  ssh_keys = {
    ci_cd = file("${path.module}/keys/ci_cd_id_rsa.pub")
    admin = file("${path.module}/keys/admin_id_rsa.pub")
    app   = file("${path.module}/keys/app_id_rsa.pub")
  }

  common_labels = {
    task_name  = var.task_name
    user_email = var.user_email
  }
  
  common_instance_config = {
    zone        = "ru-central1-a"
    cores       = 2
    memory      = 2
    disk_size   = 20
    preemptible = false
  }
}