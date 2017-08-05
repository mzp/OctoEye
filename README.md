# :eyes: OctoEye: Github viewer for Files.app

## :star: Usage
Setup

 1. Open OctoEye app
 2. Github authorization page will appear on Safari.
 3. Authorize me.

Usage:

 1. Open Files app
 2. Press `Location` and show `Browse` sidebar.
 3. Press Edit
 4. Enable `Github` location.

## :wrench: Build
### Prerequires

 * Xcode 9.0 beta 3 (9M174d)
 * Cocoapods

### Build
Install dependencies via Cocoapods.

```shell
pod update
pod install
```

Open `OctoEye.xcworkspace` and build `OctoEye` scheme.

### Testflight
```shell
bundle exec fastlane next
bundle exec fastlane beta
```

## :copyright: LICENSE
MIT
