#!/usr/bin/env bash

set -euo pipefail

MANIFEST_PATH="${1:?Manifest path is required}"
SIGNATURE_PATH="${2:?Signature path is required}"
PUBLIC_KEY_PATH="${3:?Public key path is required}"

for path in \
    "${MANIFEST_PATH}" \
    "${SIGNATURE_PATH}" \
    "${PUBLIC_KEY_PATH}"
do
    if [[ ! -f "${path}" ]]; then
        echo "Required file was not found: ${path}" >&2
        exit 1
    fi
done

SIGNATURE_BINARY_PATH="$(mktemp)"

cleanup() {
    rm -f "${SIGNATURE_BINARY_PATH}"
}

trap cleanup EXIT

base64 --decode \
    "${SIGNATURE_PATH}" \
    > "${SIGNATURE_BINARY_PATH}"

openssl dgst \
    -sha256 \
    -verify "${PUBLIC_KEY_PATH}" \
    -signature "${SIGNATURE_BINARY_PATH}" \
    -sigopt rsa_padding_mode:pss \
    -sigopt rsa_pss_saltlen:-1 \
    "${MANIFEST_PATH}"

echo "Manifest signature is valid."