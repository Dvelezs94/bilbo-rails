#!/bin/bash

if [ -n "$SECRETS_MANAGER_ID" ]; then
  # Get current region on the instance and export it as default region
  # CURRENT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
  # export AWS_DEFAULT_REGION=$CURRENT_REGION
  # Get secrets manager secret and export all vaoues as env vars
  secretsmanager $SECRETS_MANAGER_ID
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
  run)
    shift
    $@
  ;;
  *)
    /usr/bin/sudo -E -u root /usr/bin/supervisord
  ;;
esac
