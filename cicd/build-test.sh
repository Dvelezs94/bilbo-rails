#!/bin/sh

export ECR_REPOSITORY=${REPOSITORY_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/bilbo

initialize_conn() {
  $(aws ecr get-login --no-include-email --region ${AWS_REGION})
  docker pull ${ECR_REPOSITORY}:latest || true
}

build_image() {
  docker build --cache-from ${ECR_REPOSITORY}:latest -t ${ECR_REPOSITORY}:${CI_COMMIT_SHORT_SHA} --build-arg CI_AGENT="${CI_AGENT}" --build-arg ENVNAME="production" --build-arg PAYPAL_USERNAME="$PAYPAL_USERNAME" --build-arg PAYPAL_PASSWORD="$PAYPAL_PASSWORD" --build-arg PAYPAL_SIGNATURE="$PAYPAL_SIGNATURE" --build-arg MAPS_API_KEY="$MAPS_API_KEY"  .
  docker tag ${ECR_REPOSITORY}:${CI_COMMIT_SHORT_SHA} ${ECR_REPOSITORY}:latest
}

run_tests() {
  docker-compose -f docker-compose-cicd.yml up -d
  docker-compose exec -T app rails db:create
  docker-compose exec -T app rails db:migrate
  docker-compose exec -T app rails db:test:prepare
  docker-compose exec -T app rails test -f
}

push_to_ecr() {
  docker push ${ECR_REPOSITORY}:${CI_COMMIT_SHORT_SHA}
  docker push ${ECR_REPOSITORY}:latest
}

# Pull latest rc and push to prod
pull_and_push() {
  RC_TAG=${ECR_REPOSITORY}:${CI_COMMIT_SHORT_SHA}
  docker pull ${RC_TAG}
  docker tag ${RC_TAG} ${ECR_REPOSITORY}:${CI_BUILD_TAG}
  docker push ${ECR_REPOSITORY}:${CI_BUILD_TAG}
}

if [[ ${CI_COMMIT_SHORT_SHA} == *"-rc"* ]]; then
  echo "Building and Deploying to Demo environment..."
  initialize_conn
  build_image
  run_tests
  push_to_ecr
elif [[ ${CI_COMMIT_SHORT_SHA} =~ [0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  initialize_conn
  pull_and_push
else
  echo "Could not identify tag: ${CI_COMMIT_SHORT_SHA}"
  exit 1
fi
