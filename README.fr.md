# MDown View

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#configuration-requise)

MDown View est une visionneuse Markdown légère et native pour macOS. Chaque document s’ouvre dans une fenêtre d’aperçu dédiée et l’intégralité du rendu est effectuée localement sur le Mac.

## Fonctionnalités

- Interface native basée sur AppKit et SwiftUI
- Prise en charge des titres, listes, liens, citations, tableaux, listes de tâches et blocs de code Markdown
- Rendu local des diagrammes Mermaid
- Modes d’apparence Système, Clair et Sombre
- Fenêtres adaptées à la taille de l’écran et décalées pour distinguer plusieurs documents
- Prise en charge de **Ouvrir avec** dans le Finder pour les fichiers `.md` et `.markdown`
- Aucun compte, outil d’analyse, télémétrie ou rendu Markdown distant

## Configuration requise

- macOS 14.6 ou version ultérieure

## Installation

1. Téléchargez le dernier DMG depuis [GitHub Releases](https://github.com/David-Dia/MDown-View/releases).
2. Ouvrez le DMG et faites glisser **MDown View** vers **Applications**.
3. Ouvrez MDown View depuis le dossier Applications.

La version téléchargeable n’est pas notariée par Apple. Si macOS bloque le premier lancement,
ouvrez **Réglages Système → Confidentialité et sécurité**, puis cliquez sur **Ouvrir quand même**.

## Compilation depuis les sources

La compilation depuis les sources nécessite Xcode 16 ou version ultérieure.

1. Clonez le dépôt :

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. Ouvrez `MDown View.xcodeproj` dans Xcode.
3. Sélectionnez le schéma **MDown View** et **My Mac** comme destination.
4. Si Xcode demande une signature, sélectionnez une équipe de développement dans **Signing & Capabilities**.
5. Compilez et exécutez l’application.

Vous pouvez également vérifier une compilation locale sans signature de code :

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Utilisation

- Ouvrez un fichier Markdown depuis le Finder avec **Ouvrir avec → MDown View**.
- Vous pouvez également lancer l’application et choisir **File → Open…**.
- Utilisez le contrôle de la barre de titre pour sélectionner **System**, **Light** ou **Dark**.

Chaque fichier s’ouvre dans sa propre fenêtre. Les nouvelles fenêtres sont légèrement décalées afin que plusieurs documents restent visibles.

## Confidentialité et sécurité

Le rendu Markdown est effectué localement. MDown View n’intègre aucun outil d’analyse, suivi, compte ou requête réseau au niveau de l’application.

L’application utilise l’App Sandbox de macOS et accède en lecture seule aux fichiers sélectionnés par l’utilisateur. La page d’aperçu applique une Content Security Policy restrictive et ne charge aucune ressource Markdown distante. L’accès réseau sortant est activé uniquement pour assurer la compatibilité avec le processus WebKit.

Consultez [SECURITY.md](SECURITY.md) pour signaler une vulnérabilité.

## Contribution

Les rapports de bogues, propositions de fonctionnalités et Pull Requests sont les bienvenus. Lisez [CONTRIBUTING.md](CONTRIBUTING.md) avant de proposer une modification.

## Logiciels tiers

[Mermaid](https://github.com/mermaid-js/mermaid) est inclus pour le rendu local des diagrammes. Sa licence MIT se trouve dans
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt).

## Licence

MDown View est distribué sous [licence MIT](LICENSE).
