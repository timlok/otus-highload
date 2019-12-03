# proxmox

Плейбуки адаптированные для запуска на частично преднастроенных реальных или виртуальных серверах.

ВАЖНО! Перед первым запуском плейбуков необходимо:

- определить свои значения переменных в файле [variables](HA/variables)
- определить свои значения в файлах [hosts](HA/hosts) или [hosts_ip](HA/hosts_ip)
- на всех ВМ в файле /etc/hostname выставить правильные имена в соответствии с файлом [hosts](HA/hosts) или [hosts_ip](HA/hosts_ip) (на стенде proxmox ВМ разворачиваются из шаблона в котором имя машины ```template```)
- разложить необходимые ключи ssh на все ВМ

## Быстрый запуск

Клонируем репозиторий:

```bash
git clone https://github.com/timlok/otus-highload.git
```

Переходим в каталог с ролями:

```bash
cd otus-highload/provisioning_proxmox/HA/
```

Получаем список тасок:

```bash
ansible-playbook -v --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' 00_all.yml --extra-vars @variables --list-tasks

```

Запускаем, например, так:

```bash
ansible-playbook -v --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' 00_all.yml --extra-vars @variables
```
