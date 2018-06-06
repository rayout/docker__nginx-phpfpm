#!/bin/bash

#
# Тут производится настройка задач cron, которые должны быть добавлены в crontab
# после старта контейнера, в зависимости от соответвующих ENV-параметров,
# переданных в контейнер при старте.
#

#
# Добавление автозапуска Laravel Scheduler в crontab
#
if [ "$CRONTAB_LARAVEL_SCHEDULER_ENABLED" = "true" ]
then
   cat /var/spool/cron/crontabs | { cat; echo "* * * * * www-data php /var/www/artisan schedule:run >> /dev/null 2>&1"; } >> /etc/cron.d/crontab
fi

#
# Добавление произвольных заданий в crontab из строки разделённой "\n"
# (sed используется для trim'а строк)
#
if [ -n "$CRONTAB_JOBS" ]
then
   cat /var/spool/cron/crontabs | { cat; echo -e "$CRONTAB_JOBS" | sed 's/^ *//;s/ *$//'; } >> /etc/cron.d/crontab
fi
