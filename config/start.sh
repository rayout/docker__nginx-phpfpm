#!/bin/bash

/root/setup-cron-tasks.sh && /tmp/setenv.sh \ &&
supervisord -c /etc/supervisor/conf.d/supervisord.conf
