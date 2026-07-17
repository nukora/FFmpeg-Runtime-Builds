# FFmpeg Runtime Builds

FFmpegの公式ソースを基に、Windows x64向けの共有ライブラリ形式の
FFmpeg Runtimeをビルドして配布するためのリポジトリです。

## Source

FFmpeg source repository:

- https://github.com/nukora/FFmpeg
- Forked from https://github.com/FFmpeg/FFmpeg

## Build configuration

現在のビルドは以下の方針です。

- Windows x64
- MinGW-w64によるクロスコンパイル
- Shared libraries
- Static libraries disabled
- GPL components disabled
- Nonfree components disabled
- External codec libraries disabled

## Running a build

GitHub Actionsの `Build FFmpeg Windows Runtime` を手動実行します。

入力項目:

- `ffmpeg_ref`: FFmpegのタグまたはコミット
- `runtime_version`: 配布用Runtimeバージョン
- `publish_release`: GitHub Releaseを作成するか

最初は `publish_release` を無効にして実行してください。

Windows上のテストに成功したあと、同じ設定で
`publish_release` を有効にして再実行します。

## License

このリポジトリ独自のWorkflow、Dockerfile、ビルドスクリプトは
MIT Licenseです。

FFmpeg本体および生成されるバイナリには、実際のビルド構成に応じた
FFmpegのライセンスが適用されます。