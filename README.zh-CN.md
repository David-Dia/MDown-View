# MDown View

[English](README.md) | [简体中文](README.zh-CN.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#系统要求)

MDown View 是一款轻量、原生的 macOS Markdown 预览工具。每份文档都会在独立窗口中打开，全部渲染均在本机完成。

## 功能

- 使用 AppKit 与 SwiftUI 构建的原生界面
- 支持标题、列表、链接、引用、表格、任务列表和代码块
- 本地渲染 Mermaid 图表
- 支持跟随系统、浅色和深色外观
- 根据屏幕空间调整窗口大小，多文档窗口自动错开
- 支持从 Finder 使用“打开方式”预览 `.md` 和 `.markdown` 文件
- 不包含账户、分析、遥测或远程 Markdown 渲染

## 系统要求

- macOS 14.6 或更高版本
- Xcode 16 或更高版本

## 从源码构建

1. 克隆仓库：

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. 使用 Xcode 打开 `MDown View.xcodeproj`。
3. 选择 **MDown View** Scheme 和 **My Mac** 运行目标。
4. 如果 Xcode 提示签名，请在 **Signing & Capabilities** 中选择开发团队。
5. 构建并运行。

也可以通过命令行执行无签名构建：

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 使用方法

- 在 Finder 中选择 Markdown 文件，通过 **打开方式 → MDown View** 打开。
- 或启动应用后选择 **File → Open…**。
- 使用标题栏控件选择 **System**、**Light** 或 **Dark**。

每份文件都会在独立窗口中显示，新窗口会自动错开，避免完全重叠。

## 隐私与安全

Markdown 内容仅在本机渲染。MDown View 不包含分析、跟踪、账户或应用层网络请求。

应用启用了 macOS App Sandbox，只能以只读方式访问用户选择的文件。预览页面采用严格的内容安全策略，不会加载远程 Markdown 资源。网络权限仅用于 WebKit 进程兼容。

安全问题报告方式请参阅 [SECURITY.md](SECURITY.md)。

## 参与贡献

欢迎提交问题、功能建议和 Pull Request。开始前请阅读
[CONTRIBUTING.md](CONTRIBUTING.md)。

## 第三方软件

项目内置 [Mermaid](https://github.com/mermaid-js/mermaid) 用于本地图表渲染，其 MIT 许可证位于
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt)。

## 许可证

MDown View 使用 [MIT License](LICENSE) 开源。
