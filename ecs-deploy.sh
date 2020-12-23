#!/bin/sh

echo "Deploying commit $CI_COMMIT_SHORT_SHA on branch $CI_COMMIT_REF_NAME"
case $CI_COMMIT_REF_NAME in
  master)
    ecs deploy bilbo-production webapp --image bilbo-production ${REPOSITORY_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/bilbo:${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
    ecs deploy bilbo-production sidekiq --image bilbo-production-sidekiq ${REPOSITORY_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/bilbo:${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region $AWS_REGION --timeout 600
  ;;
  staging)
    ## demo deployment
    ecs deploy bilbo-demo webapp --image bilbo-demo ${REPOSITORY_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/bilbo:${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA}  --region us-east-2 --timeout 600
    ecs deploy bilbo-demo sidekiq --image bilbo-demo-sidekiq ${REPOSITORY_ID}.dkr.ecr.$AWS_REGION.amazonaws.com/bilbo:${CI_COMMIT_REF_NAME}-${CI_COMMIT_SHORT_SHA} --region us-east-2 --timeout 600
  ;;
esac

echo "Deployed succesfully"
