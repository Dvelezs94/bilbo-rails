#!/bin/sh

export ECR_REPOSITORY=${REPOSITORY_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bilbo

initialize() {
  $(aws ecr get-login --no-include-email --region ${AWS_REGION})
  docker pull ${ECR_REPOSITORY}:latest || true
}

build() {
  docker build --cache-from ${ECR_REPOSITORY}:latest -t ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME} --build-arg CI_AGENT="${CI_AGENT}" --build-arg ENVNAME="production" --build-arg PAYPAL_USERNAME="$PAYPAL_USERNAME" --build-arg PAYPAL_PASSWORD="$PAYPAL_PASSWORD" --build-arg PAYPAL_SIGNATURE="$PAYPAL_SIGNATURE" --build-arg MAPS_API_KEY="$MAPS_API_KEY"  .
  docker tag ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME} ${ECR_REPOSITORY}:latest
}

test() {
  docker-compose -f docker-compose-cicd.yml up -d
  docker-compose exec -T app rails db:create
  docker-compose exec -T app rails db:migrate
  docker-compose exec -T app rails db:test:prepare
  docker-compose exec -T app rails test -f
}

push() {
  docker push ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME}
  docker push ${ECR_REPOSITORY}:latest
}

# Pull latest rc and push to prod
pull_and_push() {
  docker pull ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME}-rc
  docker tag ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME}-rc ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME}
  docker push ${ECR_REPOSITORY}:${CI_COMMIT_REF_NAME}
}

if [[ ${CI_COMMIT_REF_NAME} == *"-rc"* ]]; then
  echo "Building and Deploying to Demo environment..."
  initialize
  build
  test
  push
elif [[ ${CI_COMMIT_REF_NAME} =~ [0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  initialize
  pull_and_push
else
  echo "Could not identify tag: ${CI_COMMIT_REF_NAME}"
  exit 1
fi
