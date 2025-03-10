#!/usr/bin/env bash

set -eo pipefail

kpt fn eval -i gcr.io/kpt-fn/generate-kpt-pkg-docs:unstable --image-pull-policy never \
--mount type=bind,src="$(pwd)",dst=/tmp,rw=true --as-current-user -- readme-path=/tmp/GENERATED.md
