# proxmox

Плейбуки адаптированные для запуска на частично преднастроенных реальных или виртуальных серверах.

Клонируем репозиторий:

```bash
git clone https://github.com/timlok/otus-highload.git
```

Запускаем:

```bash
ansible-playbook --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' /home/otus/otus-highload/provisioning_proxmox/HA/00_all.yml -i /home/otus/otus-highload/provisioning_proxmox/HA/hosts --extra-vars @/home/otus/otus-highload/provisioning_proxmox/HA/variables --list-tasks
```
