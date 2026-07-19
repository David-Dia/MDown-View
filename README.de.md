# MDown View

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#systemanforderungen)

MDown View ist ein schlanker, nativer Markdown-Betrachter für macOS. Jedes Dokument wird in einem eigenen Vorschaufenster geöffnet und vollständig lokal auf dem Mac gerendert.

## Funktionen

- Native Benutzeroberfläche mit AppKit und SwiftUI
- Unterstützung für Markdown-Überschriften, Listen, Links, Bilder, Zitate, Tabellen, Aufgabenlisten und Codeblöcke
- Seiteninterne Ankernavigation zu Überschriften
- Lokales Rendern von Mermaid-Diagrammen
- Darstellungsmodi „System“, „Hell“ und „Dunkel“
- Standardmenüs „Bearbeiten“, „Darstellung“ und „Fenster“ mit Zoomsteuerung
- Fenster merken sich Größe und Position und werden für mehrere Dokumente versetzt angeordnet
- Breite Tabellen passen sich an die Fensterbreite an
- Breite Unterstützung für Textkodierungen (UTF-8, UTF-16, GB18030, Latin-1)
- Finder-Unterstützung für **Öffnen mit** bei `.md`- und `.markdown`-Dateien
- Keine Konten, Analysen, Telemetrie oder externes Markdown-Rendering

## Systemanforderungen

- macOS 14.6 oder neuer

## Installation

1. Lade das neueste DMG von [GitHub Releases](https://github.com/David-Dia/MDown-View/releases) herunter.
2. Öffne das DMG und ziehe **MDown View** in den Ordner **Applications**.
3. Öffne MDown View aus dem Programme-Ordner.

Der Download ist nicht von Apple notarisiert. Falls macOS den ersten Start blockiert,
öffne **Systemeinstellungen → Datenschutz & Sicherheit** und klicke auf **Dennoch öffnen**.

## Aus dem Quellcode erstellen

Zum Erstellen aus dem Quellcode wird Xcode 16 oder neuer benötigt.

1. Klone das Repository:

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. Öffne `MDown View.xcodeproj` in Xcode.
3. Wähle das Schema **MDown View** und **My Mac** als Ziel aus.
4. Falls Xcode eine Signatur verlangt, wähle unter **Signing & Capabilities** ein Entwicklungsteam aus.
5. Erstelle und starte die App.

Ein lokaler Build ohne Codesignatur kann auch über die Befehlszeile geprüft werden:

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Verwendung

- Öffne eine Markdown-Datei im Finder über **Öffnen mit → MDown View**.
- Oder starte die App und wähle **File → Open…**.
- Wähle über das Steuerelement in der Titelleiste **System**, **Light** oder **Dark**.

Jede Datei wird in einem eigenen Fenster geöffnet. Neue Fenster werden leicht versetzt angezeigt, damit mehrere Dokumente sichtbar bleiben.

## Datenschutz und Sicherheit

Markdown wird lokal gerendert. MDown View enthält keine Analysen, Nachverfolgung, Konten oder Netzwerkanfragen auf Anwendungsebene.

Die App verwendet die macOS App Sandbox und greift ausschließlich lesend auf die von dir ausgewählten Dateien zu. Die Vorschauseite nutzt eine restriktive Content Security Policy: Skripte stammen nur aus der mitgelieferten Mermaid-Bibliothek und entfernte Bilder können ausschließlich über `https` geladen werden. Netzwerkzugriff besteht nur für WebKit – niemals für Analysen oder Nachverfolgung.

Informationen zum Melden von Sicherheitslücken findest du in [SECURITY.md](SECURITY.md).

## Mitwirken

Fehlerberichte, Funktionsvorschläge und Pull Requests sind willkommen. Lies vor dem Einreichen einer Änderung [CONTRIBUTING.md](CONTRIBUTING.md).

## Software von Drittanbietern

[Mermaid](https://github.com/mermaid-js/mermaid) ist für das lokale Rendern von Diagrammen enthalten. Die MIT-Lizenz befindet sich unter
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt).

## Lizenz

MDown View wird unter der [MIT-Lizenz](LICENSE) bereitgestellt.
