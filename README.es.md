# MDown View

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![Build](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml/badge.svg)](https://github.com/David-Dia/MDown-View/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![macOS 14.6+](https://img.shields.io/badge/macOS-14.6%2B-black.svg)](#requisitos)

MDown View es un visor de Markdown nativo y ligero para macOS. Abre cada documento en una ventana de previsualización independiente y realiza todo el renderizado localmente en el Mac.

## Características

- Interfaz nativa creada con AppKit y SwiftUI
- Compatibilidad con títulos, listas, enlaces, citas, tablas, listas de tareas y bloques de código de Markdown
- Renderizado local de diagramas Mermaid
- Modos de apariencia del sistema, claro y oscuro
- Ventanas adaptadas al tamaño de la pantalla y desplazadas para distinguir varios documentos
- Compatibilidad con **Abrir con** de Finder para archivos `.md` y `.markdown`
- Sin cuentas, análisis, telemetría ni renderizado remoto de Markdown

## Requisitos

- macOS 14.6 o posterior

## Instalación

1. Descarga el DMG más reciente desde [GitHub Releases](https://github.com/David-Dia/MDown-View/releases).
2. Abre el DMG y arrastra **MDown View** a **Applications**.
3. Abre MDown View desde la carpeta Aplicaciones.

La versión descargable no está notarizada por Apple. Si macOS bloquea el primer inicio,
abre **Ajustes del Sistema → Privacidad y seguridad** y haz clic en **Abrir igualmente**.

## Compilar desde el código fuente

Para compilar desde el código fuente se necesita Xcode 16 o posterior.

1. Clona el repositorio:

   ```bash
   git clone https://github.com/David-Dia/MDown-View.git
   cd MDown-View
   ```

2. Abre `MDown View.xcodeproj` en Xcode.
3. Selecciona el esquema **MDown View** y **My Mac** como destino.
4. Si Xcode solicita una firma, selecciona un equipo de desarrollo en **Signing & Capabilities**.
5. Compila y ejecuta la aplicación.

También puedes verificar una compilación local sin firma de código:

```bash
xcodebuild \
  -project "MDown View.xcodeproj" \
  -scheme "MDown View" \
  -configuration Release \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Uso

- Abre un archivo Markdown desde Finder con **Abrir con → MDown View**.
- También puedes iniciar la aplicación y elegir **File → Open…**.
- Usa el control de la barra de título para seleccionar **System**, **Light** o **Dark**.

Cada archivo se abre en su propia ventana. Las ventanas nuevas aparecen ligeramente desplazadas para que varios documentos permanezcan visibles.

## Privacidad y seguridad

El renderizado de Markdown se realiza localmente. MDown View no incluye análisis, seguimiento, cuentas ni solicitudes de red a nivel de aplicación.

La aplicación utiliza App Sandbox de macOS y solo accede en modo de lectura a los archivos seleccionados por el usuario. La página de previsualización aplica una Content Security Policy restrictiva y no carga recursos Markdown remotos. El acceso de red saliente solo está habilitado para la compatibilidad con el proceso de WebKit.

Consulta [SECURITY.md](SECURITY.md) para informar de vulnerabilidades.

## Contribuciones

Se aceptan informes de errores, propuestas de funciones y Pull Requests. Lee [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar un cambio.

## Software de terceros

[Mermaid](https://github.com/mermaid-js/mermaid) se incluye para renderizar diagramas localmente. Su licencia MIT está disponible en
[`MDown View/Resources/Mermaid-LICENSE.txt`](MDown%20View/Resources/Mermaid-LICENSE.txt).

## Licencia

MDown View se distribuye bajo la [licencia MIT](LICENSE).
