#!/bin/bash
IFS="=" # используется на строке 6 для разделения строки конфига на ключ и значение
echo "Updating .env file with values from environment"
while read line; do
	if [[ $line != "#"* ]] && [[ $line != "" ]] ; then
		read -ra _VAR <<< "$line"
		if [[ -v "${_VAR[0]}" ]]; then
			echo "Value of ${_VAR[0]} in .env file will be replaced with a value from environment"
			sed -i "s/$line/${_VAR[0]}=${!_VAR[0]}/" $1 # конструкция ${!_VAR[0]} берет значение environment variable название которой хранится в _VAR[0]
		fi
	fi
done <$1
echo ".env file updated, following command will be executed: '$2'"
eval $2