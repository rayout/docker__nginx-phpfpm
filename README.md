# NGINX-PHPFPM

В контейнере стартует процессы: nginx, php-fpm и cron.

## NGINX

### ENV переменные

ENV_NGINX_HOST: Адрес сайта
ENV_NGINX_PUBLIC_PATH: Публичный путь

Так же заменяет все переменные которые начинаются на "ENV_NGINX_".    
`Предварительно меняет "," на пробел внутри переменной!`

### Проброс своего конфигурационного файла

В `Dockerfile` необходимо прописать копирования вашего файла по пути `/site.conf`  
Например: `COPY ./nginx.conf /site.conf`

Если для локальной разработки, то можно делать так:

```
    web:
        image: gitlab.kodeks.ru:4567/docker/nginx-phpfpm
        volumes:
            - ./nginx.conf:/site.conf    
```        

### Работа с proxy_pass

К сожалению при обнволении контейнера вознкиает ситуация когда одновременно работают как старый так и новый контейнеры.  
При такой ситуации nginx при стартет делает resolve доменного имени и получает 2 IP адреса.  
Когда старый сервис выключается, ДНС не делает новый resolv по умолчанию, а просто пробрасывает в половине случаев на несуществующий адрес.  

Что бы этой ситуации не случалось можно использовать ХАК. К сожалнию он спасает ситуацию не полность. Все равно есть лаг 1-3 секунды когда ДНС nginx может смотреть на старый адрес.   
Но с этим хаком он хотя бы стартует.

```
server {
    listen 80;

    # issue with ip and the nginx proxy
    real_ip_header X-Forwarded-For;

    server_name ENV_NGINX_PROXY_HOST;
    resolver 169.254.169.250 ipv6=off;
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header Package $package;
        proxy_set_header X-NginX-Proxy true;
        set $upstream http://proxy:ENV_NGINX_PROXY_PORT$request_uri;
        proxy_pass $upstream;
    }
}
```

Из этого примера нам важны строки:   
`resolver 127.0.0.1 ipv6=off;` - пробрасываем ДНС на dnsmasq в контейнере (можно напрямую на 169.254.169.250 но это плохое решение) 
`set $upstream http://proxy:ENV_NGINX_PROXY_PORT$request_uri;` - назначаем переменную с адресом куда будет проксировать.  
`proxy_pass $upstream;` - используем эту переменную  

## CRON

### Настройка заданий

Для того, что бы добавить задания в cron,  нужно передать переменную окружения,
в зависимости от наличия и значения которой при запуске контейнера скрипт 
`setup-cron-tasks.sh` добавит правила в `/etc/crontab`.

Это можно сделать добавив в секцию "php-fpm" в файле `docker-compose.yml` в проекте соответствующую переменную.

Поддерживаемые переменные:

- `CRONTAB_LARAVEL_SCHEDULER_ENABLED` (bool) - включение заданий по расписанию в Laravel 5
- `CRONTAB_JOBS` (string) - проивольный список команд для добавления в общесистемный crontab (команды разделяются "\n")


### Пример добавления заданий

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

