# EasySketchCam

App para calcar dibujos con la cámara y generar códigos QR, para **iOS y Android**
desde un solo código en Swift/SwiftUI usando [Skip](https://skip.dev) en modo
**Skip Lite** (el Swift se transpila a Kotlin + Jetpack Compose).

## Estructura

```
EasySketchCam/
├── Package.swift               # Paquete SwiftPM con el módulo compartido
├── Skip.env                    # Nombre, bundle id y versión (iOS + Android)
├── Project.xcworkspace         # ← Abre ESTE archivo en Xcode
├── Sources/EasySketchCam/      # Código compartido (SwiftUI)
│   ├── EasySketchCamApp.swift  # Vista raíz + delegate del ciclo de vida
│   ├── ContentView.swift
│   ├── Generics/               # Router, tema, íconos, utilidades
│   ├── Modules/                # Home (bocetos), Sketch (calcar), QR, Settings
│   ├── Resources/              # Module.xcassets, Localizable.xcstrings
│   └── Skip/
│       ├── skip.yml            # Dependencias Gradle (CameraX, ZXing, Exif)
│       ├── TKAndroidCamera.kt  # Vista previa de cámara en Android (CameraX)
│       └── TKAndroidImage.kt   # QR (ZXing), rotación EXIF y compartir imagen
├── Darwin/                     # App de iOS (xcodeproj, xcconfig, íconos)
└── Android/                    # App de Android (Gradle, Manifest, íconos)
```

## Requisitos (una sola vez, en tu Mac)

```bash
brew install skiptools/skip/skip   # o: brew install skip
skip checkup                       # verifica Xcode, Android SDK, Gradle, etc.
```

También necesitas Android Studio (para el SDK y un emulador).

## Correr la app

1. Abre un emulador de Android desde Android Studio (Device Manager) o conecta un teléfono.
2. Abre `Project.xcworkspace` en Xcode.
3. Elige el scheme **EasySketchCam App** y un simulador de iPhone → **Run**.

Xcode compila la app de iOS y, en la misma corrida, transpila y lanza la app de
Android en el emulador (controlado por `SKIP_ACTION` en `Darwin/EasySketchCam.xcconfig`:
`launch`, `build` o `none`).

Desde terminal también puedes usar:

```bash
skip android build      # compila el APK
skip export             # genera .ipa / .apk / .aab para publicar
```

## Cómo se resolvieron las diferencias de plataforma

| Función | iOS | Android |
|---|---|---|
| Vista previa de cámara (calcar) | `AVCaptureSession` (`AVFoundationClasses.swift`) | CameraX (`Skip/TKAndroidCamera.kt`) vía `ComposeView` |
| Tomar foto | `UIImagePickerController` | `withMediaPicker(.camera)` de SkipKit |
| Elegir de galería | `PhotosPicker` | `withMediaPicker(.library)` de SkipKit |
| Generar QR | CoreImage | ZXing (`tkQRCodePNG`) |
| Compartir QR | `ShareLink` con imagen | Intent `ACTION_SEND` con PNG (`tkShareImage`) |
| Íconos | SF Symbols | Material Icons (`Generics/TKSymbol.swift`) |
| Colores de fondo | `systemGroupedBackground` | `MaterialTheme.colorScheme` (`TKTheme.swift`) |

El código específico de cada plataforma está dentro de bloques `#if SKIP` (Android)
/ `#if !SKIP` (iOS).

## Reglas al escribir código nuevo (Skip Lite)

- Usa `@Observable` + `@State` (no Combine / `ObservableObject`).
- No uses `@GestureState`: usa `@State` y reinícialo en `.onEnded`.
- No uses `ContentUnavailableView`, regex (`range(of:options: .regularExpression)`)
  ni APIs de UIKit fuera de `#if !SKIP`.
- `LazyVGrid` dentro de `ScrollView` debe ser su único hijo, y no se anida en `List`.
- Para íconos nuevos agrega un caso en `TKSymbol` (o un SVG en `Module.xcassets`).
- Si algo no está soportado, revisa la tabla de compatibilidad de
  [SkipUI](https://github.com/skiptools/skip-ui#supported-swiftui) o escribe esa
  parte en Kotlin dentro de `Sources/EasySketchCam/Skip/`.

Los datos existentes de iOS (bocetos y QRs guardados) se conservan: se mantienen
el bundle id `ToolKit.ToolKit` y las mismas llaves de `UserDefaults`.
