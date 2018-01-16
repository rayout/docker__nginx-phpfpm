#!/usr/bin/env bats
cp helpers.sh /tmp/helpers.sh
source /tmp/helpers.sh

@test "test_start_with_work" {
    run starts_with 'some_text' 'some'
    [ "$status" -eq 0 ]
}

@test "test_start_with_work_inverse" {
    run not_starts_with 'some_text' 'some'
    [ "$status" -eq 1 ]
}

@test "get_server_name_output" {
    run get_server_template pupka.kodeks.ru
    # echo "0: '${lines[0]}'"
    # echo "1: '${lines[1]}'"
    # echo "2: '${lines[2]}'"
    # echo "3: '${lines[3]}'"
    [ "${lines[0]}" ==  "server {" ]
    [ "${lines[1]}" ==  "    listen 80;" ]
    [ "${lines[2]}" ==  "    server_name www.pupka.kodeks.ru;" ]
    [ "${lines[3]}" ==  "    return 302 \$scheme://pupka.kodeks.ru\$request_uri;" ]
    [ "${lines[4]}" ==  "}" ]
}

@test "test_start_not_work" {
    run starts_with 'some_text' 'text'
    [ "$status" -eq 1 ]
}

@test "test_replace_comma_to_spaces" {
    result=$(echo "" | replace_comma_to_spaces)
    [ "$result" == '' ]

    result=$(echo " " | replace_comma_to_spaces)
    [ "$result" == '' ]

    result=$(echo "abc" | replace_comma_to_spaces)
    [ "$result" == 'abc' ]

    result=$(echo "a,b,c" | replace_comma_to_spaces)
    [ "$result" == 'a b c' ]

    result=$(echo "  a ,  b,  c  " | replace_comma_to_spaces)
    [ "$result" == 'a b c' ]

    result=$(echo -e " \ta,\tb, \t\tc " | replace_comma_to_spaces)
    [ "$result" == 'a b c' ]
}

@test "test_get_www_names" {
  run get_www_names "ENV_NGINX_HOST=www.kodeks.ru,site.kodeks.net,api.cntd.ru"
  [ "$status" -eq 0 ]
  echo $output
  [ "${lines[0]}" ==  "www.kodeks.ru" ]
  [ "${lines[1]}" ==  "www.site.kodeks.net" ]
  [ "${lines[2]}" ==  "www.api.cntd.ru" ]
}

@test "test_get_host_names" {
  run get_host_names "ENV_NGINX_HOST=www.kodeks.ru,site.kodeks.net,api.cntd.ru"
  [ "$status" -eq 0 ]
  echo $output
  [ "${lines[0]}" ==  "kodeks.ru" ]
  [ "${lines[1]}" ==  "site.kodeks.net" ]
  [ "${lines[2]}" ==  "api.cntd.ru" ]
}
