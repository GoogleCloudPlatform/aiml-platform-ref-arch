#!/bin/bash
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
SCRIPT_PATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

if [ -z ${GIT_REPOSITORY:-} ]; then
  exit 0
fi

source ${SCRIPT_PATH}/helpers/git_config_env.sh

echo "Waiting for namespace '${K8S_NAMESPACE}' to be created..."
while ! kubectl get ns ${K8S_NAMESPACE} >/dev/null 2>&1; do
  sleep 2
done

if kubectl get secret git-creds -n ${K8S_NAMESPACE} >/dev/null 2>&1; then
  kubectl create secret generic git-creds --namespace="${K8S_NAMESPACE}" --save-config --dry-run=client --from-literal=username="${GIT_USERNAME}" --from-literal=token="${GIT_TOKEN}" -o yaml | kubectl apply -f -
else
  kubectl create secret generic git-creds --namespace="${K8S_NAMESPACE}" --save-config --from-literal=username="${GIT_USERNAME}" --from-literal=token="${GIT_TOKEN}"
fi
