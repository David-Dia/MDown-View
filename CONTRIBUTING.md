# Contributing to MDown View

Thank you for helping improve MDown View.

## Before You Start

- Search existing issues before opening a new one.
- Keep reports focused on one problem or proposal.
- Remove private or sensitive content from sample Markdown files.
- For security issues, follow [SECURITY.md](SECURITY.md) instead of opening a
  public issue.

## Development Setup

1. Fork and clone the repository.
2. Open `MDown View.xcodeproj` in Xcode 16 or later.
3. Select the shared **MDown View** scheme.
4. Build for **My Mac**.

To build without code signing:

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Debug \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Pull Requests

- Create a focused branch from `main`.
- Follow the existing Swift style and use native macOS components where possible.
- Preserve local-only rendering and sandbox restrictions.
- Include reproduction steps for fixes and verification steps for changes.
- Update documentation when behavior or requirements change.
- Confirm that Debug and Release builds succeed before submitting.

By contributing, you agree that your contribution will be licensed under the
project's [MIT License](LICENSE).
