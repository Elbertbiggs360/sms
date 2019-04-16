# !/bin/bash

set -e

echo "Deploying to ${DEPLOYMENT_ENVIRONMENT}"

echo $ACCOUNT_KEY_STAGING > service_key.txt
echo "${ACCOUNT_KEY_STAGING}"

base64 -i service_key.txt -d > ${HOME}/gcloud-service-key.json
echo "${HOME}"

gcloud auth activate-service-account ${ACCOUNT_ID} --key-file ${HOME}/gcloud-service-key.json
echo "${ACCOUNT_ID}"

gcloud config set project $PROJECT_ID
echo "${PROJECT_ID}"

gcloud --quiet config set container/cluster $CLUSTER_NAME
echo "${CLUSTER_NAME}"

gcloud config set compute/zone $CLOUDSDK_COMPUTE_ZONE
echo "${CLOUDSDK_COMPUTE_ZONE}"

gcloud --quiet container clusters get-credentials $CLUSTER_NAME
echo "${CLUSTER_NAME}"

# service docker start

docker build -t gcr.io/${PROJECT_ID}/${REG_ID}:$CIRCLE_SHA1 .

gcloud docker -- push gcr.io/${PROJECT_ID}/${REG_ID}:$CIRCLE_SHA1

kubectl set image deployment/${DEPLYMENT_NAME} ${CONTAINER_NAME}=gcr.io/${PROJECT_ID}/${REG_ID}:$CIRCLE_SHA1

echo " Successfully deployed to ${DEPLOYMENT_ENVIRONMENT} "