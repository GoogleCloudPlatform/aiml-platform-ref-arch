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
  export GIT_REPOSITORY_PATH="${MANIFESTS_DIRECTORY}"
else
  source ${SCRIPT_PATH}/helpers/clone_git_repo.sh
fi

# Set directory and path variables
clusters_directory="manifests/clusters"
clusters_path="${GIT_REPOSITORY_PATH}/${clusters_directory}"
template_directory="templates/_cluster_template"
template_path="${GIT_REPOSITORY_PATH}/${template_directory}"

cp -r ${template_path}/kuberay ${clusters_path}/

# Added entries to the kustomization file
export resources="${clusters_path}/kuberay"
export kustomization_file="${clusters_path}/kustomization.yaml"
source ${SCRIPT_PATH}/helpers/add_to_kustomization.sh

if [ ! -z ${GIT_REPOSITORY:-} ]; then
  # Add, commit, and push changes to the repository
  cd ${GIT_REPOSITORY_PATH}
  git add .
  git commit -m "Manifests for KubeRay operator"
  git push origin
fi
