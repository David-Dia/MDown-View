# Changelog

All notable changes to MDown View will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-07-19

### Added

- Inline image rendering with responsive sizing
- In-page anchor navigation for document headings
- Standard Edit, View (zoom), and Window menus
- Per-document window size and position persistence
- Text encoding support for UTF-8, UTF-16 (with BOM), GB18030, and Latin-1

### Changed

- Wide tables now wrap to fit the window instead of scrolling sideways
- Preview windows open at a larger, table-friendly default size
- Theme changes re-render the page so Mermaid diagrams match the appearance

### Fixed

- Preview windows opening at their minimum size
- GFM tables with short delimiter rows or escaped pipes
- Fenced code blocks nested inside list items
- Link URLs containing parentheses, hard line breaks, and bare autolinks
- `.md` file association on systems without the Markdown UTI declared

### Security

- Replaced a private WebKit API with a supported equivalent
- Restricted document images to `https` sources
- Randomized inline placeholders to prevent collisions with document content
- Added a size cap for opened files

## [1.0.0] - 2026-07-19

### Added

- Native macOS Markdown preview windows
- Tables, task lists, fenced code blocks, and Mermaid diagrams
- System, Light, and Dark appearance modes
- Responsive default sizing and staggered multi-window positioning
- Local rendering with App Sandbox file access

[Unreleased]: https://github.com/David-Dia/MDown-View/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/David-Dia/MDown-View/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/David-Dia/MDown-View/releases/tag/v1.0.0
