#!/usr/bin/env bash
set -x

# call this script by doing ./secretsmanager.sh secret/of/app

secrets=$(aws secretsmanager get-secret-value --secret-id $1 | jq -r '.SecretString')
#echo $secrets
for s in $(echo $secrets | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
    export $s
done
