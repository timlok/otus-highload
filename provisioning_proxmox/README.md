# proxmox

Плейбуки адаптированные для запуска на частично преднастроенных реальных или виртуальных серверах.

Запускать так:
```bash
ansible-playbook ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' /home/otus/provisioning_proxmox/HA/all.yml -i /home/otus/provisioning_proxmox/HA/hosts --extra-vars @/home/otus/provisioning_proxmox/HA/variables --list-tasks
```
