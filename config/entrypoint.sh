#!/bin/bash

/root/setenv.sh .env
/root/setup-cron-tasks.sh && /tmp/set-nginx-env.sh \ &&
supervisord -c /etc/supervisor/conf.d/supervisord.conf
