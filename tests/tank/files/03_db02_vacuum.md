# VACUUM FULL

При проведении дальнейших тестов в БД участились взаимные блокировки. В связи с этим, было выполнено сжатие раздутых таблиц и индексов и уменьшение физического размера файлов БД:

```bash
psql -U postgres -h /tmp -d zabbix -c "VACUUM FULL VERBOSE ANALYZE;"
psql -U postgres -h /tmp -d zabbix -c "REINDEX DATABASE zabbix;"
```

То же самое можно проделать без блокировок (VACUUM FULL), например, с помощью утилиты [pgcompacttable](https://github.com/dataegret/pgcompacttable)

```bash
psql -U postgres -h /tmp -d zabbix -c "create extension if not exists pgstattuple;"
pgcompacttable -h /tmp --all --force --verbose
```

## До сжатия

размер БД zabbix

```sql
zabbix=# SELECT pg_size_pretty( pg_database_size( 'zabbix' ) );
 pg_size_pretty
----------------
 1607 MB
(1 строка)
```

размер 20 самых больших таблиц

```sql
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;
         relation          | total_size
---------------------------+------------
 public.history            | 593 MB
 public.history_uint       | 447 MB
 public.sessions           | 238 MB
 public.auditlog           | 208 MB
 public.trends_uint        | 48 MB
 public.trends             | 45 MB
 public.events             | 2592 kB
 public.items              | 2280 kB
 public.history_str        | 1728 kB
 public.images             | 1184 kB
 public.triggers           | 672 kB
 public.items_applications | 576 kB
 public.history_text       | 560 kB
 public.problem            | 400 kB
 public.profiles           | 400 kB
 public.functions          | 376 kB
 public.event_recovery     | 368 kB
 public.item_discovery     | 304 kB
 public.graphs_items       | 288 kB
 public.graphs             | 272 kB
(20 строк)
```

## После сжатия

размер БД zabbix

```sql
zabbix=# SELECT pg_size_pretty( pg_database_size( 'zabbix' ) );
 pg_size_pretty
----------------
 1019 MB
(1 строка)
```

размер 20 самых больших таблиц

```sql
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;
         relation          | total_size
---------------------------+------------
 public.history            | 329 MB
 public.history_uint       | 226 MB
 public.sessions           | 194 MB
 public.auditlog           | 188 MB
 public.trends_uint        | 31 MB
 public.trends             | 29 MB
 public.items              | 1952 kB
 public.events             | 1232 kB
 public.images             | 1168 kB
 public.history_str        | 992 kB
 public.triggers           | 504 kB
 public.items_applications | 464 kB
 public.history_text       | 336 kB
 public.functions          | 312 kB
 public.graphs_items       | 248 kB
 public.event_recovery     | 240 kB
 public.graphs             | 224 kB
 public.item_discovery     | 216 kB
 public.hosts              | 144 kB
 public.item_preproc       | 136 kB
(20 строк)
```
