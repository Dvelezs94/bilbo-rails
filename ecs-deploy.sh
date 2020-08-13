#!/bin/sh

echo "Deploying commit $CI_COMMIT_SHORT_SHA on branch $CI_COMMIT_REF_NAME"
case $CI_COMMIT_REF_NAME in
  master)
    ecs deploy bilbo-production webapp --image bilbo-production $DOCKER_IMAGE_CI --region $AWS_REGION --timeout 600
    ecs deploy bilbo-production sidekiq --image bilbo-production-sidekiq $DOCKER_IMAGE_CI --region $AWS_REGION --timeout 600
    ## demo deployment
    ecs deploy bilbo-demo webapp --image bilbo-demo $DOCKER_IMAGE_CI  --region us-east-2 --timeout 600
    ecs deploy bilbo-demo sidekiq --image bilbo-demo-sidekiq $DOCKER_IMAGE_CI --region us-east-2 --timeout 600
  ;;
  staging)
    ecs deploy bilbo-staging rails --image bilbo-staging $DOCKER_IMAGE_CI --region us-west-1 --timeout 600
    ecs deploy bilbo-staging sidekiq --image bilbo-staging-sidekiq $DOCKER_IMAGE_CI --region us-west-1 --timeout 600
  ;;
esac

echo "Deployed succesfully"
