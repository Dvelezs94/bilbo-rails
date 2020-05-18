#!/bin/bash

if [ -n "$SECRETS_MANAGER_ID" ]; then
  # Get current region on the instance and export it as default region
  # CURRENT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')
  # export AWS_DEFAULT_REGION=$CURRENT_REGION
  # Get secrets manager secret and export all vaoues as env vars
  secretsmanager $SECRETS_MANAGER_ID
fi

# init supervisor or sidekiq
if [ $COMPONENT == "sidekiq" ]; then
  bundle exec sidekiq
else
  /usr/bin/sudo -E -u root /usr/bin/supervisord
fi
