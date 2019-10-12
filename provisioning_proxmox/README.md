# proxmox

Плейбуки адаптированные для запуска на частично преднастроенных реальных или виртуальных серверах.

ВАЖНО! Перед первым запуском плейбуков необходимо:

- определить свои значения переменных в файле [variables](provisioning_proxmox/HA/variables) и [hosts](provisioning_proxmox/HA/hosts)
- проверить имена хостов в play-файлах плейбуков (yml-файлы в этом [каталоге](provisioning_proxmox/HA/)
- на всех ВМ в файле /etc/hostname выставить правильные имена в соответствии с файлом [hosts](provisioning_proxmox/HA/hosts) (на стенде proxmox ВМ разворачиваются из шаблона в котором имя машины ```template```)

Клонируем репозиторий:

```bash
[otus@hl-client ~]$ git clone https://github.com/timlok/otus-highload.git
```

Получаем список тасок:

```bash
[otus@hl-client ~]$ ansible-playbook --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' /home/otus/otus-highload/provisioning_proxmox/HA/00_all.yml -i /home/otus/otus-highload/provisioning_proxmox/HA/hosts --extra-vars @/home/otus/otus-highload/provisioning_proxmox/HA/variables --list-tasks
```

Запускаем, например, так:

```bash
[otus@hl-client ~]$ ansible-playbook -v --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' /home/otus/otus-highload/provisioning_proxmox/HA/01_tuning_OS.yml -i /home/otus/otus-highload/provisioning_proxmox/HA/hosts --extra-vars @/home/otus/otus-highload/provisioning_proxmox/HA/variables
```
