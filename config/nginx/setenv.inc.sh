# Include sh functions
source ./helpers.sh

main() {
    mkdir -p /etc/nginx/sites-available;
    if [ -f "$config_template_source1" ]; then
        cp $config_template_source1 $config_template;
    elif [ -f "$config_template_source2" ]; then
        cp $config_template_source2 $config_template;
    fi;
    cp $config_template $config;

    /usr/bin/env | grep -E '^ENV_NGINX_|^HOST=|^PUBLIC_PATH=' | \
    while read raw_env_variable;
    do
        if not_starts_with $raw_env_variable 'ENV_NGINX_' ; then
            raw_env_variable="ENV_NGINX_$raw_env_variable";
        fi;
        raw_env_variable=$(echo $raw_env_variable | sed 's/\//\\\//g');
        variable_with_value=$(echo $raw_env_variable| replace_comma_to_spaces);
        key=$(echo $variable_with_value| awk -F '=' '{print $1}');
        if [ "$key" = "ENV_NGINX_HOST" ] ; then
            host_replacement=$(echo $(get_host_names $raw_env_variable));
            replace_in_config "ENV_NGINX_HOST" "$host_replacement" "$config";
        else
            value=$(echo $variable_with_value| sed "s/$key=//g");
            replace_in_config "$key" "$value" "$config";
        fi;
    done;
}
