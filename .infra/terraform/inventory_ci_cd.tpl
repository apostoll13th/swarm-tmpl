all:
  vars:
    ansible_user: ci_cd
    ansible_ssh_private_key_file: /home/jenkins/.ssh/ci_cd_id_rsa
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