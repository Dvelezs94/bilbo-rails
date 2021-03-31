#!/bin/sh

set -e

echo "Deploying commit $CI_COMMIT_SHORT_SHA"

if [[ ${CI_BUILD_TAG} == *"-rc"* ]]; then
  # demo
  ecs deploy bilbo-demo webapp --image bilbo-demo ${REPOSITORY_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bilbo:${CI_COMMIT_SHORT_SHA}  --region us-east-2 --timeout 600
  ecs deploy bilbo-demo sidekiq --image bilbo-demo-sidekiq ${REPOSITORY_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bilbo:${CI_COMMIT_SHORT_SHA} --region us-east-2 --timeout 600
elif [[ ${CI_BUILD_TAG} =~ [0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # prod
  ecs deploy bilbo-production webapp --image bilbo-production ${REPOSITORY_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bilbo:${CI_BUILD_TAG} --region ${AWS_REGION} --timeout 600
  ecs deploy bilbo-production sidekiq --image bilbo-production-sidekiq ${REPOSITORY_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bilbo:${CI_BUILD_TAG} --region ${AWS_REGION} --timeout 600
else
  echo "Could not identify commit: ${CI_COMMIT_REF_NAME}, tag: ${CI_BUILD_TAG}"
  exit 1
fi

echo "Deployed succesfully"
