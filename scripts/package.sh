#!/usr/bin/env bash

set -euo pipefail

RUNTIME_DIR="${1:?Runtime directory is required}"
DIST_DIR="${2:?Distribution directory is required}"
RUNTIME_VERSION="${3:?Runtime version is required}"
SOURCE_REPOSITORY="${4:?Source repository is required}"
SOURCE_REF="${5:?Source ref is required}"
SOURCE_COMMIT="${6:?Source commit is required}"
BUILD_REPOSITORY="${7:?Build repository is required}"
BUILD_COMMIT="${8:?Build commit is required}"
RELEASE_TAG="${9:?Release tag is required}"

ARCHIVE_NAME="ffmpeg-runtime-win-x64-${RUNTIME_VERSION}.zip"
ARCHIVE_PATH="${DIST_DIR}/${ARCHIVE_NAME}"

RELEASE_BASE_URL="https://github.com/${BUILD_REPOSITORY}/releases/download/${RELEASE_TAG}"
ARCHIVE_URL="${RELEASE_BASE_URL}/${ARCHIVE_NAME}"

mkdir -p "${DIST_DIR}"

(
    cd "${RUNTIME_DIR}"
    zip -9 -r "${ARCHIVE_PATH}" .
)

ARCHIVE_SHA256="$(
    sha256sum "${ARCHIVE_PATH}" |
    cut -d ' ' -f 1
)"

cat > "${DIST_DIR}/manifest.json" <<EOF
{
  "schemaVersion": 1,
  "runtimeVersion": "${RUNTIME_VERSION}",
  "platform": "win-x64",
  "flavor": "lgpl-core",
  "ffmpeg": {
    "repository": "${SOURCE_REPOSITORY}",
    "ref": "${SOURCE_REF}",
    "commit": "${SOURCE_COMMIT}"
  },
  "build": {
    "repository": "${BUILD_REPOSITORY}",
    "commit": "${BUILD_COMMIT}"
  },
  "archive": {
    "fileName": "${ARCHIVE_NAME}",
    "url": "${ARCHIVE_URL}",
    "sha256": "${ARCHIVE_SHA256}"
  }
}
EOF

echo "Runtime package created: ${ARCHIVE_PATH}"
echo "Runtime URL: ${ARCHIVE_URL}"