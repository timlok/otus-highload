# яндекс.танк

На хостовой машине должен быть установлен и запущен docker. Необязательно, но удобнее, чтобы все файлы лежали рядом.

Запуск
```bash
docker run -v $(pwd):/var/loadtest -v $HOME/.ssh:/home/otus/.ssh -it direvius/yandex-tank
```

или так, если нужно залогиниться в контейнер

```bash
docker run --entrypoint /bin/bash -v $(pwd):/var/loadtest -v $HOME/.ssh:/home/otus/.ssh -it direvius/yandex-tank
```

Тесты были направлены на VIP-адрес pacemaker-кластера и привожу результаты без улучшений и оптимизаций и с оптимизациями. В каких-то тестах pacemaker перебрасывал VIP на другой хост и поднимал упавший php-fpm. Был оптимизирован  только php-fpm, т.к. производительность веба упиралась в него. На каждой ВМ 1 ядро ЦП и 2 ГБ ОЗУ. Единовременно нагрузка была только на одну ВМ (VIP-адрес). Заметил странность - одновременно работающие redis и memcached дают лучший результат, чем поодиночке. Хотя использовать их оба не стоит, вроде как.
По итогам тестов, на мой взгляд, php-fpm не помешало бы увеличить ядра ЦП до 2х штук.
На мастер-сервере БД появляется iowait, но БД я ещё никак не настраивал.

Результирующий файл [/etc/php-fpm.d/www.conf](files/www.conf)

Была проведена оптимизация php с помощью подключения модулей кеширования: php-pecl-apcu, php-pecl-zendopcache, php-pecl-memcache + memcached, php-pecl-redis + redis.

Оптимизация TCP/IP-стека для nginx+php-fpm:

```
net.core.rmem_max = 16777216 
net.ipv4.tcp_rmem = 4096 87380 16777216 
net.core.wmem_max = 16777216 
net.ipv4.tcp_wmem = 4096 16384 16777216 
net.ipv4.tcp_fin_timeout = 20 
net.ipv4.tcp_tw_reuse = 1 
net.core.netdev_max_backlog = 10000 
net.ipv4.ip_local_port_range = 15000 65000
```

## Результаты тестов

тестирование без оптимизации
https://overload.yandex.net/218467

установлен php-pecl-apcu
https://overload.yandex.net/218533

установлены
php-pecl-apcu
php-pecl-zendopcache
https://overload.yandex.net/218545

установлены
php-pecl-apcu
php-pecl-zendopcache
php-pecl-memcache, memcached
https://overload.yandex.net/218555

установлены
php-pecl-apcu
php-pecl-zendopcache
php-pecl-memcache, memcached
php-pecl-redis, redis
https://overload.yandex.net/218558

установлены
php-pecl-apcu
php-pecl-zendopcache
php-pecl-redis, redis
https://overload.yandex.net/218564

установлены
php-pecl-apcu
php-pecl-zendopcache
php-pecl-memcache, memcached
php-pecl-redis, redis
оптимизация php-fpm
https://overload.yandex.net/218658

установлены
php-pecl-apcu
php-pecl-zendopcache
php-pecl-memcache, memcached
php-pecl-redis, redis
оптимизация php-fpm
оптимизация sysctl.conf
https://overload.yandex.net/218662

Сводный график нагрузки на сервера во время выполнения последнего теста:

![Сводный график нагрузки на сервера во время выполнения последнего теста](files/summary_servers_load.png)