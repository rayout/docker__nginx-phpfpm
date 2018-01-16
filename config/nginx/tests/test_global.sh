#!/usr/bin/env bats
@test "global test case" {
    config_template=site.conf
    config=$(mktemp /tmp/test_XXXXXXXXX)
    if [ -f $config ] ; then rm $config; fi
    source ./setenv.inc.sh
    source ./helpers.sh

    ENV_NGINX_PUBLIC_PATH="somewhere/config" ENV_NGINX_HOST=www.kodeks.ru,site.kodeks.net,api.cntd.ru main
    grep "root /var/www/somewhere/config;" $config
    grep "server_name kodeks.ru site.kodeks.net api.cntd.ru;" $config

    if [ -f $config ] ; then rm $config; fi
}

@test "global docker restart" {
    config_template=site.conf
    config=$(mktemp /tmp/test_XXXXXXXXX)
    if [ -f $config ] ; then rm $config; fi
    source ./setenv.inc.sh
    source ./helpers.sh

    ENV_NGINX_PUBLIC_PATH="somewhere/config" ENV_NGINX_HOST=www.kodeks.ru,site.kodeks.net,api.cntd.ru main
    ENV_NGINX_PUBLIC_PATH="somewhere/config" ENV_NGINX_HOST=www.kodeks.ru,site.kodeks.net,api.cntd.ru main
    grep "root /var/www/somewhere/config;" $config
    count=$(grep "server_name kodeks.ru site.kodeks.net api.cntd.ru;" $config | wc -l)
    [ "$count" = "1" ]
    unset count

    # if [ -f $config ] ; then rm $config; fi
}

@test "global test case (old version support)" {
    config_template=site.conf
    config=$(mktemp /tmp/test_XXXXXXXXX)
    if [ -f $config ] ; then rm $config; fi
    source ./setenv.inc.sh
    source ./helpers.sh

    PUBLIC_PATH="somewhere/config" HOST=www.kodeks.ru,site.kodeks.net,api.cntd.ru main
    grep "root /var/www/somewhere/config;" $config
    grep "server_name kodeks.ru site.kodeks.net api.cntd.ru;" $config
    if [ -f $config ] ; then rm $config; fi
}
