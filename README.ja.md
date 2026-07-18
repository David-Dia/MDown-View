# MDown View

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#動作環境)

MDown View は、macOS 向けの軽量なネイティブ Markdown ビューアーです。各文書を専用のプレビューウィンドウで開き、すべてのレンダリングを Mac 上で行います。

## 機能

- AppKit と SwiftUI を使用したネイティブインターフェース
- Markdown の見出し、リスト、リンク、引用、表、タスクリスト、コードブロックに対応
- Mermaid 図をローカルでレンダリング
- システム、ライト、ダークの外観モード
- 画面サイズに応じたウィンドウ調整と、複数文書を見分けやすくするウィンドウ配置
- Finder の **このアプリケーションで開く** から `.md` と `.markdown` ファイルを表示
- アカウント、解析、テレメトリ、リモート Markdown レンダリングは不使用

## 動作環境

- macOS 14.6 以降

## インストール

1. [GitHub Releases](https://github.com/David-Dia/MDown-View/releases) から最新の DMG をダウンロードします。
2. DMG を開き、**MDown View** を **Applications** にドラッグします。
3. アプリケーションフォルダから MDown View を起動します。

ダウンロード版は Apple の公証を受けていません。macOS が初回起動をブロックした場合は、
**システム設定 → プライバシーとセキュリティ**を開き、**このまま開く**をクリックしてください。

## ソースからビルド

ソースからのビルドには Xcode 16 以降が必要です。

1. リポジトリをクローンします。

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. Xcode で `MDown View.xcodeproj` を開きます。
3. **MDown View** スキームと **My Mac** を実行先として選択します。
4. Xcode が署名を求める場合は、**Signing & Capabilities** で開発チームを選択します。
5. ビルドして実行します。

コマンドラインからコード署名なしのローカルビルドを確認することもできます。

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 使い方

- Finder で Markdown ファイルを選択し、**このアプリケーションで開く → MDown View** から開きます。
- または、アプリを起動して **File → Open…** を選択します。
- タイトルバーのコントロールから **System**、**Light**、**Dark** を選択します。

各ファイルは個別のウィンドウで開きます。複数の文書が見えるように、新しいウィンドウは少しずつ位置をずらして表示されます。

## プライバシーとセキュリティ

Markdown のレンダリングはすべてローカルで行われます。MDown View には解析、トラッキング、アカウント、アプリケーションレベルのネットワーク要求は含まれません。

アプリは macOS App Sandbox を使用し、ユーザーが選択したファイルに読み取り専用でアクセスします。プレビューページには厳格な Content Security Policy が適用され、リモートの Markdown リソースは読み込まれません。外部ネットワークアクセスは WebKit プロセスとの互換性のためにのみ有効です。

脆弱性の報告方法については [SECURITY.md](SECURITY.md) を参照してください。

## コントリビューション

バグ報告、機能提案、Pull Request を歓迎します。変更を送信する前に [CONTRIBUTING.md](CONTRIBUTING.md) をお読みください。

## サードパーティソフトウェア

ローカルでの図のレンダリングには [Mermaid](https://github.com/mermaid-js/mermaid) を同梱しています。MIT ライセンスは
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt) に含まれています。

## ライセンス

MDown View は [MIT License](LICENSE) のもとで提供されています。
