# MDown View

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#requirements)

MDown View is a lightweight, native Markdown viewer for macOS. It opens each
document in a focused preview window and keeps rendering local to your Mac.

## Features

- Native AppKit and SwiftUI interface
- Markdown headings, lists, links, block quotes, tables, task lists, and fenced code
- Local Mermaid diagram rendering
- System, Light, and Dark appearance modes
- Responsive preview windows with staggered positioning for multiple documents
- Finder **Open With** support for `.md` and `.markdown` files
- No accounts, analytics, telemetry, or remote Markdown rendering

## Requirements

- macOS 14.6 or later

## Install

1. Download the latest DMG from [GitHub Releases](https://github.com/David-Dia/MDown-View/releases).
2. Open the DMG and drag **MDown View** to **Applications**.
3. Open the app from the Applications folder.

The downloadable build is not notarized. If macOS blocks the first launch,
open **System Settings → Privacy & Security** and click **Open Anyway**.

## Build from Source

Building from source requires Xcode 16 or later.

1. Clone the repository:

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. Open `MDown View.xcodeproj` in Xcode.
3. Select the **MDown View** scheme and **My Mac** as the destination.
4. Choose a development team under **Signing & Capabilities** if Xcode requests one.
5. Build and run.

You can also verify a local build without code signing:

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Usage

- Open a Markdown file from Finder with **Open With → MDown View**.
- Or launch the app and choose **File → Open…**.
- Use the title-bar control to select **System**, **Light**, or **Dark**.

Each file opens in its own window. New windows are offset so that multiple
documents remain visible.

## Privacy and Security

Markdown rendering happens locally. MDown View does not include analytics,
tracking, accounts, or application-level network requests.

The app uses the macOS App Sandbox with read-only access to files selected by
the user. The preview page uses a restrictive Content Security Policy and does
not load remote Markdown assets. Outgoing network access is enabled only for
WebKit process compatibility.

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## Contributing

Bug reports, feature proposals, and pull requests are welcome. Read
[CONTRIBUTING.md](CONTRIBUTING.md) before submitting a change.

## Third-Party Software

[Mermaid](https://github.com/mermaid-js/mermaid) is bundled for local diagram
rendering. Its MIT license is included at
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt).

## License

MDown View is available under the [MIT License](LICENSE).
