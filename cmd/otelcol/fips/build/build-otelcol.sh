#!/bin/sh
#
# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <build-info>" >&2
    exit 1
fi

private_modules_token_file=/run/secrets/private_modules_token
if [ ! -s "$private_modules_token_file" ]; then
    echo "private_modules_token BuildKit secret is required to fetch private Go modules" >&2
    exit 1
fi

private_modules_token="$(cat "$private_modules_token_file")"

GOPRIVATE="${GOPRIVATE:-github.com/signalfx/splunk-otel-collector-components}" \
GONOSUMDB="${GONOSUMDB:-github.com/signalfx/splunk-otel-collector-components}" \
GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0="url.https://x-access-token:${private_modules_token}@github.com/.insteadOf" \
GIT_CONFIG_VALUE_0="https://github.com/" \
make otelcol BUILD_INFO="$1"
