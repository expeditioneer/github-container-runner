#!/usr/bin/env bash

PERSONAL_ACCESS_TOKEN=${TOKEN}
REPOSITORY="${REPO}"

echo "ACCESS_TOKEN ${PERSONAL_ACCESS_TOKEN}"
echo "REPO ${REPOSITORY}"
echo "RUNNER_NAME ${RUNNER_NAME}"

REGISTRATION_TOKEN=""

# REGISTRATION_TOKEN is valid for (only) 1 hour
# see https://github.com/actions/runner/discussions/1799
function get_valid_registration_token() {
  REGISTRATION_TOKEN=$(curl \
  --request POST \
  --header "Authorization: token ${PERSONAL_ACCESS_TOKEN}" \
  --header "Accept: application/vnd.github+json" \
  --silent \
  https://api.github.com/repos/"${REPOSITORY}"/actions/runners/registration-token | jq .token --raw-output)
}

cd /home/docker/actions-runner || exit

get_valid_registration_token
./config.sh \
  --disableupdate \
  --ephemeral \
  --name "${RUNNER_NAME}" \
  --replace \
  --token "${REGISTRATION_TOKEN}" \
  --url https://github.com/"${REPOSITORY}" \
  --unattended


cleanup() {
  echo "Removing runner ..."
  get_valid_registration_token
  ./config.sh remove --token "${REGISTRATION_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
