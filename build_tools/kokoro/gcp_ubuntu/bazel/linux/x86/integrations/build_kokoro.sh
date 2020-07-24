#!/bin/bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build and test IREE's integrations within the gcr.io/iree-oss/bazel-tensorflow
# image using Kokoro.
# Requires the environment variables KOKORO_ROOT and KOKORO_ARTIFACTS_DIR, which
# are set by Kokoro.

set -x
set -e
set -o pipefail

# Print the UTC time when set -x is on
export PS4='[$(date -u "+%T %Z")] '

WORKDIR="${KOKORO_ARTIFACTS_DIR?}/github/iree"

# TODO(#2653): Don't run docker as root
DOCKER_RUN_ARGS=(
      # Make the source repository available
      --volume="${WORKDIR?}:${WORKDIR?}"
      --workdir="${WORKDIR?}"
      # Delete the container after
      --rm
)

docker run "${DOCKER_RUN_ARGS[@]?}" \
  gcr.io/iree-oss/bazel-tensorflow:prod \
  build_tools/kokoro/gcp_ubuntu/bazel/linux/x86/integrations/build.sh

# Kokoro will rsync this entire directory back to the executor orchestrating the
# build which takes forever and is totally useless.
# TODO(#2653): Remove sudo when docker doesn't run as root
sudo rm -rf "${KOKORO_ARTIFACTS_DIR?}"/*

# Print out artifacts dir contents after deleting them as a coherence check.
ls -1a "${KOKORO_ARTIFACTS_DIR?}/"