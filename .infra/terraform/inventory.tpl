all:
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ${private_key_path}
  children:
    prod:
      hosts:
%{ for index, ip in prod_ips ~}
        prod-${index}:
          ansible_host: ${ip}
%{ endfor ~}
    dev:
      hosts:
%{ for index, ip in dev_ips ~}
        dev-${index}:
          ansible_host: ${ip}
%{ endfor ~}