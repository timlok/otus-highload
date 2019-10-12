# proxmox

Плейбуки адаптированные для запуска на частично преднастроенных реальных или виртуальных серверах.

ВАЖНО! Перед первым запуском плейбуков необходимо:

- определить свои значения переменных в файле [variables](HA/variables) и [hosts](HA/hosts)
- проверить имена хостов в play-файлах плейбуков (yml-файлы в этом [каталоге](HA/)
- на всех ВМ в файле /etc/hostname выставить правильные имена в соответствии с файлом [hosts](HA/hosts) (на стенде proxmox ВМ разворачиваются из шаблона в котором имя машины ```template```)

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
