#!/usr/bin/env bash

set -euo pipefail

RUNTIME_DIR="${1:-/output}"
BIN_DIR="${RUNTIME_DIR}/bin"
CONFIGURE_ARGS_FILE="${RUNTIME_DIR}/metadata/configure-args.txt"

require_file() {
    local path="$1"

    if [[ ! -f "${path}" ]]; then
        echo "Required file is missing: ${path}" >&2
        exit 1
    fi
}

require_pattern() {
    local pattern="$1"

    if ! compgen -G "${pattern}" > /dev/null; then
        echo "Required file pattern was not found: ${pattern}" >&2
        exit 1
    fi
}

require_file "${BIN_DIR}/ffmpeg.exe"
require_file "${BIN_DIR}/ffprobe.exe"
require_file "${CONFIGURE_ARGS_FILE}"

require_pattern "${BIN_DIR}/avcodec-*.dll"
require_pattern "${BIN_DIR}/avformat-*.dll"
require_pattern "${BIN_DIR}/avutil-*.dll"
require_pattern "${BIN_DIR}/avfilter-*.dll"
require_pattern "${BIN_DIR}/avdevice-*.dll"
require_pattern "${BIN_DIR}/swscale-*.dll"
require_pattern "${BIN_DIR}/swresample-*.dll"

if grep -Fxq -- "--enable-gpl" "${CONFIGURE_ARGS_FILE}"; then
    echo "GPL configuration was detected." >&2
    exit 1
fi

if grep -Fxq -- "--enable-nonfree" "${CONFIGURE_ARGS_FILE}"; then
    echo "Nonfree configuration was detected." >&2
    exit 1
fi

if ! grep -Fxq -- "--enable-shared" "${CONFIGURE_ARGS_FILE}"; then
    echo "Shared library configuration is missing." >&2
    exit 1
fi

if ! grep -Fxq -- "--disable-static" "${CONFIGURE_ARGS_FILE}"; then
    echo "Static library configuration is missing." >&2
    exit 1
fi

echo "Runtime structure verification succeeded."