#!/usr/bin/env bash

set -euo pipefail

MANIFEST_PATH="${1:?Manifest path is required}"
SIGNATURE_PATH="${2:?Signature path is required}"

if [[ -z "${MANIFEST_SIGNING_PRIVATE_KEY:-}" ]]; then
    echo "MANIFEST_SIGNING_PRIVATE_KEY is not configured." >&2
    exit 1
fi

if [[ ! -f "${MANIFEST_PATH}" ]]; then
    echo "Manifest was not found: ${MANIFEST_PATH}" >&2
    exit 1
fi

PRIVATE_KEY_PATH="$(mktemp)"
SIGNATURE_BINARY_PATH="$(mktemp)"

cleanup() {
    rm -f "${PRIVATE_KEY_PATH}"
    rm -f "${SIGNATURE_BINARY_PATH}"
}

trap cleanup EXIT

printf '%s' "${MANIFEST_SIGNING_PRIVATE_KEY}" \
    > "${PRIVATE_KEY_PATH}"

chmod 600 "${PRIVATE_KEY_PATH}"

mkdir -p "$(dirname "${SIGNATURE_PATH}")"

openssl dgst \
    -sha256 \
    -sign "${PRIVATE_KEY_PATH}" \
    -sigopt rsa_padding_mode:pss \
    -sigopt rsa_pss_saltlen:-1 \
    -out "${SIGNATURE_BINARY_PATH}" \
    "${MANIFEST_PATH}"

base64 \
    --wrap=0 \
    "${SIGNATURE_BINARY_PATH}" \
    > "${SIGNATURE_PATH}"

printf '\n' >> "${SIGNATURE_PATH}"

echo "Manifest signature created: ${SIGNATURE_PATH}"