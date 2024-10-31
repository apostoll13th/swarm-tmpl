
resource "yandex_compute_instance" "prod_instance" {
  count  = var.vps_count
  name   = "app-${count.index}"
  zone   = local.common_instance_config.zone
  
  resources {
    cores  = local.common_instance_config.cores
    memory = local.common_instance_config.memory
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = local.common_instance_config.disk_size
    }
  }
  
  network_interface {
    subnet_id = data.yandex_vpc_subnet.default.id
    nat       = true
  }
  
   metadata = {
    ssh-keys = "${var.user}:${var.ssh_key}"
  }

  labels = local.common_labels
  
  scheduling_policy {
    preemptible = local.common_instance_config.preemptible
  }
}

resource "yandex_compute_instance" "dev_instance" {
  count  = var.vps_count
  name   = "graylog-${count.index}"
  zone   = local.common_instance_config.zone
  
  resources {
    cores  = local.common_instance_config.cores
    memory = local.common_instance_config.memory
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = local.common_instance_config.disk_size
    }
  }
  
  network_interface {
    subnet_id = data.yandex_vpc_subnet.default.id
    nat       = true
  }
  
   metadata = {
    ssh-keys = "${var.user}:${var.ssh_key}"
  }
  
  labels = local.common_labels
  
  scheduling_policy {
    preemptible = local.common_instance_config.preemptible
  }
}


resource "time_sleep" "wait_for_instance" {
  depends_on = [yandex_compute_instance.prod_instance, yandex_compute_instance.dev_instance]
  create_duration = "30s"
}

resource "null_resource" "setup_users_app" {
  count      = var.vps_count
  depends_on = [time_sleep.wait_for_instance]

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.ssh_path)
    host        = yandex_compute_instance.prod_instance[count.index].network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [<<-EOT
      #!/bin/bash
      set -e

      create_user_with_ssh_key() {
        local username="$1"
        local ssh_key="$2"
        
        sudo useradd -m -s /bin/bash "$username"
        sudo mkdir -p "/home/$username/.ssh"
        echo "$ssh_key" | sudo tee "/home/$username/.ssh/authorized_keys"
        sudo chown -R "$username:$username" "/home/$username/.ssh"
        sudo chmod 700 "/home/$username/.ssh"
        sudo chmod 600 "/home/$username/.ssh/authorized_keys"
        sudo usermod -aG sudo "$username"

        echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
      }

      create_user_with_ssh_key "ci_cd" "${replace(local.ssh_keys["ci_cd"], "'", "'\\''")}"
      create_user_with_ssh_key "app" "${replace(local.ssh_keys["app"], "'", "'\\''")}"
      create_user_with_ssh_key "admin" "${replace(local.ssh_keys["admin"], "'", "'\\''")}"
    EOT
    ]
  }
}


resource "null_resource" "setup_users_graylog" {
  count      = var.vps_count
  depends_on = [time_sleep.wait_for_instance]

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.ssh_path)
    host        = yandex_compute_instance.dev_instance[count.index].network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
    inline = [<<-EOT
      #!/bin/bash
      set -e

      create_user_with_ssh_key() {
        local username="$1"
        local ssh_key="$2"
        
        sudo useradd -m -s /bin/bash "$username"
        sudo mkdir -p "/home/$username/.ssh"
        echo "$ssh_key" | sudo tee "/home/$username/.ssh/authorized_keys"
        sudo chown -R "$username:$username" "/home/$username/.ssh"
        sudo chmod 700 "/home/$username/.ssh"
        sudo chmod 600 "/home/$username/.ssh/authorized_keys"
        sudo usermod -aG sudo "$username"

        echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
      }
        
     create_user_with_ssh_key "ci_cd" "${replace(local.ssh_keys["ci_cd"], "'", "'\\''")}"
     create_user_with_ssh_key "app" "${replace(local.ssh_keys["app"], "'", "'\\''")}"
     create_user_with_ssh_key "admin" "${replace(local.ssh_keys["admin"], "'", "'\\''")}"
    EOT
    ]
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    prod_ips = yandex_compute_instance.prod_instance[*].network_interface[0].nat_ip_address
    dev_ips  = yandex_compute_instance.dev_instance[*].network_interface[0].nat_ip_address
    private_key_path = var.ssh_path
  })
  filename = "${path.module}/../ansible/inventory.yml"
}

resource "local_file" "ansible_inventory_ci_cd" {
  content = templatefile("${path.module}/inventory_ci_cd.tpl", {
    prod_ips = yandex_compute_instance.prod_instance[*].network_interface[0].nat_ip_address
    dev_ips  = yandex_compute_instance.dev_instance[*].network_interface[0].nat_ip_address
  })
  filename = "${path.module}/../ansible/inventory_ci_cd.yml"
}