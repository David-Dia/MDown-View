# MDown View

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#시스템-요구-사항)

MDown View는 macOS용 경량 네이티브 Markdown 뷰어입니다. 각 문서를 전용 미리보기 창에서 열며 모든 렌더링을 Mac에서 로컬로 처리합니다.

## 주요 기능

- AppKit과 SwiftUI로 구성된 네이티브 인터페이스
- Markdown 제목, 목록, 링크, 인용문, 표, 작업 목록 및 코드 블록 지원
- Mermaid 다이어그램 로컬 렌더링
- 시스템, 라이트 및 다크 화면 모드
- 화면 크기에 맞춘 창 조정과 여러 문서를 구분하기 위한 계단식 창 배치
- Finder의 **다음으로 열기**를 통한 `.md` 및 `.markdown` 파일 지원
- 계정, 분석, 원격 측정 또는 원격 Markdown 렌더링 없음

## 시스템 요구 사항

- macOS 14.6 이상

## 설치

1. [GitHub Releases](https://github.com/David-Dia/MDown-View/releases)에서 최신 DMG를 다운로드합니다.
2. DMG를 열고 **MDown View**를 **Applications**로 드래그합니다.
3. 응용 프로그램 폴더에서 MDown View를 실행합니다.

다운로드 빌드는 Apple 공증을 받지 않았습니다. macOS가 첫 실행을 차단하면
**시스템 설정 → 개인정보 보호 및 보안**을 열고 **그래도 열기**를 클릭하세요.

## 소스에서 빌드

소스에서 빌드하려면 Xcode 16 이상이 필요합니다.

1. 저장소를 복제합니다.

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. Xcode에서 `MDown View.xcodeproj`를 엽니다.
3. **MDown View** 스킴과 **My Mac**을 실행 대상으로 선택합니다.
4. Xcode에서 서명을 요청하면 **Signing & Capabilities**에서 개발 팀을 선택합니다.
5. 빌드하고 실행합니다.

명령줄에서 코드 서명 없이 로컬 빌드를 확인할 수도 있습니다.

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 사용 방법

- Finder에서 Markdown 파일을 선택하고 **다음으로 열기 → MDown View**를 사용합니다.
- 또는 앱을 실행한 후 **File → Open…**을 선택합니다.
- 제목 표시줄 컨트롤에서 **System**, **Light** 또는 **Dark**를 선택합니다.

각 파일은 별도의 창에서 열립니다. 여러 문서를 볼 수 있도록 새 창의 위치가 조금씩 어긋나게 배치됩니다.

## 개인정보 보호 및 보안

Markdown 렌더링은 로컬에서 이루어집니다. MDown View에는 분석, 추적, 계정 또는 애플리케이션 수준의 네트워크 요청이 포함되지 않습니다.

앱은 macOS App Sandbox를 사용하며 사용자가 선택한 파일에 읽기 전용으로 접근합니다. 미리보기 페이지에는 제한적인 Content Security Policy가 적용되며 원격 Markdown 리소스를 불러오지 않습니다. 외부 네트워크 접근은 WebKit 프로세스 호환성을 위해서만 활성화됩니다.

취약점 신고 방법은 [SECURITY.md](SECURITY.md)를 참조하세요.

## 기여

버그 신고, 기능 제안 및 Pull Request를 환영합니다. 변경 사항을 제출하기 전에 [CONTRIBUTING.md](CONTRIBUTING.md)를 읽어 주세요.

## 타사 소프트웨어

로컬 다이어그램 렌더링을 위해 [Mermaid](https://github.com/mermaid-js/mermaid)가 포함되어 있습니다. MIT 라이선스는
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt)에 포함되어 있습니다.

## 라이선스

MDown View는 [MIT License](LICENSE)에 따라 제공됩니다.
