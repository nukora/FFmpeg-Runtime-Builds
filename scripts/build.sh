#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${1:-/source}"
OUTPUT_DIR="${2:-/output}"

BUILD_DIR="/tmp/ffmpeg-build"
INSTALL_DIR="/tmp/ffmpeg-install"

rm -rf "${BUILD_DIR}"
rm -rf "${INSTALL_DIR}"

mkdir -p "${OUTPUT_DIR}"
find "${OUTPUT_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

mkdir -p "${BUILD_DIR}"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${OUTPUT_DIR}/bin"
mkdir -p "${OUTPUT_DIR}/licenses"
mkdir -p "${OUTPUT_DIR}/metadata"

# マウントされたFFmpegソースを直接変更しないようにコピーする。
cp -a "${SOURCE_DIR}/." "${BUILD_DIR}/"

cd "${BUILD_DIR}"

CONFIGURE_ARGS=(
    "--prefix=${INSTALL_DIR}"
    "--target-os=mingw32"
    "--arch=x86_64"
    "--cross-prefix=x86_64-w64-mingw32-"
    "--enable-cross-compile"
    "--enable-shared"
    "--disable-static"
    "--disable-debug"
    "--disable-doc"
    "--disable-autodetect"
    "--disable-gpl"
    "--disable-version3"
    "--disable-nonfree"
    "--disable-ffplay"
)

# 実際に使用したconfigure引数を記録する。
printf '%s\n' "${CONFIGURE_ARGS[@]}" \
    > "${OUTPUT_DIR}/metadata/configure-args.txt"

./configure "${CONFIGURE_ARGS[@]}"

make -j"$(nproc)"
make install

# Windows実行ファイルと共有DLLをコピーする。
find "${INSTALL_DIR}/bin" \
    -maxdepth 1 \
    -type f \
    \( -iname '*.exe' -o -iname '*.dll' \) \
    -exec cp '{}' "${OUTPUT_DIR}/bin/" ';'

# ライセンス関連ファイルをコピーする。
cp "${BUILD_DIR}/LICENSE.md" \
    "${OUTPUT_DIR}/licenses/LICENSE.md"

cp "${BUILD_DIR}/COPYING.LGPLv2.1" \
    "${OUTPUT_DIR}/licenses/COPYING.LGPLv2.1"

# ビルド調査用の設定ファイルを保存する。
cp "${BUILD_DIR}/config.h" \
    "${OUTPUT_DIR}/metadata/config.h"

cp "${BUILD_DIR}/config.mak" \
    "${OUTPUT_DIR}/metadata/config.mak"

echo "FFmpeg build completed."