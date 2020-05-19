#!/bin/sh

echo "Deploying commit $CI_COMMIT_SHORT_SHA on branch $CI_COMMIT_REF_NAME"
case $CI_COMMIT_REF_NAME in
  master)
    ecs deploy bilbo-demo webapp -t ${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
    ecs deploy bilbo-demo sidekiq -t ${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
  ;;
  # development)
  #   ecs deploy jalecitos-dev rails -t ${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
  #   ecs deploy jalecitos-dev sidekiq -t ${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
  # ;;
  # staging)
  #   ecs deploy jalecitos-stage rails -t ${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
  #   ecs deploy jalecitos-stage sidekiq -t ${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
  # ;;
esac

echo "Deployed succesfully"
