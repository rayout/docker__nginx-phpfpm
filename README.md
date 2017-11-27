# NGINX-PHPFPM

В контейнере стартует процессы: nginx, php-fpm и cron.

## Проброс своего конфигурационного файла nginx

В `Dockerfile` необходимо прописать копирования вашего файла по пути `/site.conf`  
Например: `COPY ./nginx.conf /site.conf`

## Настройка заданий cron

Для того, что бы добавить задания в cron,  нужно передать переменную окружения,
в зависимости от наличия и значения которой при запуске контейнера скрипт 
`setup-cron-tasks.sh` добавит правила в `/etc/crontab`.

Это можно сделать добавив в секцию "php-fpm" в файле `docker-compose.yml` в проекте соответствующую переменную.

Поддерживаемые переменные:

- `CRONTAB_LARAVEL_SCHEDULER_ENABLED` (bool) - включение заданий по расписанию в Laravel 5
- `CRONTAB_JOBS` (string) - проивольный список команд для добавления в общесистемный crontab (команды разделяются "\n")


## Пример добавления заданий

Файл `docker-compose.yml`:

```
...

### PHP-FPM Container #######################################

web:
    image: ...
    ...
    environment:
        - CRONTAB_LARAVEL_SCHEDULER_ENABLED=true
        - CRONTAB_JOBS=
            * * * * * www-data foo >> /dev/null 2>&1 \n
            * * * * * www-data foo >> /dev/null 2>&1 \n
            * * * * * www-data foo >> /dev/null 2>&1

...
```

Где:
- `www-data` - имя пользователя, от которого должна запускаться команда (при необходимости следует изменить)
- `foo` -  команда для запуска

