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

Провёл повторный тест с последней конфигурацией

установлены
php-pecl-apcu
php-pecl-zendopcache
php-pecl-memcache, memcached
php-pecl-redis, redis
оптимизация php-fpm
оптимизация sysctl.conf
https://overload.yandex.net/219036

 и обнаружил:

 - Потребление ОЗУ увеличилось только на 24,95 МБ, что говорит о том, что php-fpm дополнительно запустил ещё chlidren`ов.
 - Php-fpm уже не говорит, о том, что ему плохо.
 - Из-за высокой нагрузки на сеть и ЦП, pacemaker не может проверить статус клонированного ресурса (для работы в active/active) cluster_vip. Поскольку от этого ресурса зависят все остальные ресурсы, то pacemaker перезапускает cluster_vip и все свои остальные ресурсы и именно поэтому происходят потери http-запросов при тестировании. При этом, с точки зрения потери http-трафика, не очень важно, на какой ноде pacemaker восстановит ресурсы, т.к. потери http-трафика будут в любом случае.
   Привожу лог с выявлением этого поведения:

```bash
[root@hl-zabbix02 ~]# journalctl -f -b | grep -v "Could not map name=hl-zabbix"
-- Logs begin at Сб 2019-10-12 02:12:30 MSK. --
окт 12 13:18:55 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 3.250000
окт 12 13:19:25 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 4.990000
окт 12 13:19:55 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 21.799999
окт 12 13:20:24 hl-zabbix02 lrmd[1518]:  warning: cluster_vip:0_monitor_2000 process (PID 11413) timed out
окт 12 13:20:24 hl-zabbix02 lrmd[1518]:  warning: cluster_vip:0_monitor_2000:11413 - timed out after 20000ms
окт 12 13:20:24 hl-zabbix02 lrmd[1518]:  warning: cluster_vip:1_monitor_2000 process (PID 11414) timed out
окт 12 13:20:24 hl-zabbix02 crmd[1521]:    error: Result of monitor operation for cluster_vip:0 on hl-zabbix02.otus: Timed Out
окт 12 13:20:24 hl-zabbix02 lrmd[1518]:  warning: cluster_vip:1_monitor_2000:11414 - timed out after 20000ms
окт 12 13:20:24 hl-zabbix02 crmd[1521]:    error: Result of monitor operation for cluster_vip:1 on hl-zabbix02.otus: Timed Out
окт 12 13:20:24 hl-zabbix02 crmd[1521]:   notice: State transition S_IDLE -> S_POLICY_ENGINE
окт 12 13:20:28 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 39.299999
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice: On loss of CCM Quorum: Ignore
окт 12 13:20:28 hl-zabbix02 pengine[1520]:  warning: Processing failed monitor of cluster_vip:0 on hl-zabbix02.otus: unknown error
окт 12 13:20:28 hl-zabbix02 pengine[1520]:  warning: Processing failed monitor of cluster_vip:1 on hl-zabbix02.otus: unknown error
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice:  * Recover    cluster_vip:0     ( hl-zabbix02.otus )
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice:  * Recover    cluster_vip:1     ( hl-zabbix02.otus )
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice:  * Restart    zabbix_server     ( hl-zabbix02.otus )   due to required cluster_vip-clone running
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice:  * Restart    nginx             ( hl-zabbix02.otus )   due to required php-fpm start
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice:  * Restart    php-fpm           ( hl-zabbix02.otus )   due to required zabbix_server start
окт 12 13:20:28 hl-zabbix02 pengine[1520]:   notice: Calculated transition 176, saving inputs in /var/lib/pacemaker/pengine/pe-input-90.bz2
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice: On loss of CCM Quorum: Ignore
окт 12 13:20:30 hl-zabbix02 pengine[1520]:  warning: Processing failed monitor of cluster_vip:0 on hl-zabbix02.otus: unknown error
окт 12 13:20:30 hl-zabbix02 pengine[1520]:  warning: Processing failed monitor of cluster_vip:1 on hl-zabbix02.otus: unknown error
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice:  * Recover    cluster_vip:0     ( hl-zabbix02.otus )
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice:  * Recover    cluster_vip:1     ( hl-zabbix02.otus )
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice:  * Restart    zabbix_server     ( hl-zabbix02.otus )   due to required cluster_vip-clone running
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice:  * Restart    nginx             ( hl-zabbix02.otus )   due to required php-fpm start
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice:  * Restart    php-fpm           ( hl-zabbix02.otus )   due to required zabbix_server start
окт 12 13:20:30 hl-zabbix02 pengine[1520]:   notice: Calculated transition 177, saving inputs in /var/lib/pacemaker/pengine/pe-input-91.bz2
окт 12 13:20:30 hl-zabbix02 crmd[1521]:   notice: Initiating stop operation nginx_stop_0 locally on hl-zabbix02.otus
окт 12 13:20:30 hl-zabbix02 systemd[1]: Reloading.
окт 12 13:20:30 hl-zabbix02 systemd[1]: Stopping The nginx HTTP and reverse proxy server...
окт 12 13:20:31 hl-zabbix02 systemd[1]: Stopped The nginx HTTP and reverse proxy server.
окт 12 13:20:31 hl-zabbix02 crmd[1521]:   notice: Transition aborted by operation cluster_vip:0_monitor_2000 'modify' on hl-zabbix02.otus: Old event
окт 12 13:20:32 hl-zabbix02 crmd[1521]:   notice: Result of stop operation for nginx on hl-zabbix02.otus: 0 (ok)
окт 12 13:20:32 hl-zabbix02 crmd[1521]:   notice: Transition 177 (Complete=1, Pending=0, Fired=0, Skipped=1, Incomplete=18, Source=/var/lib/pacemaker/pengine/pe-input-91.bz2): Stopped
окт 12 13:20:32 hl-zabbix02 pengine[1520]:   notice: On loss of CCM Quorum: Ignore
окт 12 13:20:32 hl-zabbix02 pengine[1520]:  warning: Processing failed monitor of cluster_vip:0 on hl-zabbix02.otus: unknown error
окт 12 13:20:32 hl-zabbix02 pengine[1520]:  warning: Processing failed monitor of cluster_vip:1 on hl-zabbix02.otus: unknown error
окт 12 13:20:32 hl-zabbix02 pengine[1520]:   notice:  * Start      nginx             ( hl-zabbix02.otus )
окт 12 13:20:32 hl-zabbix02 pengine[1520]:   notice: Calculated transition 178, saving inputs in /var/lib/pacemaker/pengine/pe-input-92.bz2
окт 12 13:20:32 hl-zabbix02 crmd[1521]:   notice: Initiating start operation nginx_start_0 locally on hl-zabbix02.otus
окт 12 13:20:32 hl-zabbix02 systemd[1]: Reloading.
окт 12 13:20:32 hl-zabbix02 systemd[1]: Starting Cluster Controlled nginx...
окт 12 13:20:32 hl-zabbix02 nginx[11627]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
окт 12 13:20:32 hl-zabbix02 nginx[11627]: nginx: configuration file /etc/nginx/nginx.conf test is successful
окт 12 13:20:32 hl-zabbix02 systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
окт 12 13:20:32 hl-zabbix02 systemd[1]: Started Cluster Controlled nginx.
окт 12 13:20:34 hl-zabbix02 crmd[1521]:   notice: Result of start operation for nginx on hl-zabbix02.otus: 0 (ok)
окт 12 13:20:34 hl-zabbix02 crmd[1521]:   notice: Initiating monitor operation nginx_monitor_4000 locally on hl-zabbix02.otus
окт 12 13:20:34 hl-zabbix02 crmd[1521]:   notice: Transition 178 (Complete=2, Pending=0, Fired=0, Skipped=0, Incomplete=0, Source=/var/lib/pacemaker/pengine/pe-input-92.bz2): Complete
окт 12 13:20:34 hl-zabbix02 crmd[1521]:   notice: State transition S_TRANSITION_ENGINE -> S_IDLE
окт 12 13:20:58 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 24.139999
окт 12 13:21:28 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 14.630000
окт 12 13:21:58 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 9.030000
окт 12 13:22:28 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 5.470000
окт 12 13:22:58 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 3.320000
окт 12 13:23:28 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 2.010000
окт 12 13:23:58 hl-zabbix02 crmd[1521]:   notice: High CPU load detected: 1.220000
```

Вывод:
Не считаю правильным перенастраивать pacemaker на увеличение таймаута недоступности ресурса cluster_vip, т.к. станет не оптимальным выполнение задачи отказоустойчивости при проблемах сетевой связанности, отказах сервисов или ВМ.
Для решения этой проблемы считаю необходимым увеличение мощности или количества ядер ЦП.