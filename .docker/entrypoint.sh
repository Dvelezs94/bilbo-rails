#!/bin/bash

echo "priting first argument: $1"

if [ -n "$SECRETS_MANAGER_ID" ]; then
  secrets=$(aws secretsmanager get-secret-value --secret-id $SECRETS_MANAGER_ID | jq -r '.SecretString')
  #echo $secrets
  for s in $(echo $secrets | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
      export $s
  done
fi

# init supervisor or sidekiq
case "$1" in
  web)
    /usr/bin/sudo -E -u root /usr/bin/supervisord
  ;;
  sidekiq)
    bundle exec sidekiq
  ;;
  ## use this like bash .docker/entrypoint.sh run echo "hello". you can give it any number of arguments after run
  *)
    #shift
    echo "running: $@"
    $@
  ;;
esac
