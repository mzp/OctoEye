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

### :+1: Commit symbols

#### What's mean of this task
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:rotating_light:   |add/improve test                        |
|:sparkles:         |add new feature                         |
|:lipstick:         |improve the format/structure of the code|
|:bug:              |fix bug                                 |
|:wrench:           |improve development environment         |
|:memo:             |improve document                        |

#### What's do for this task
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:hocho:            |split code                              |
|:truck:            |move files                              |
|:fire:             |remove code/files/...                   |
|:chocolate_bar:    |install/remove new cocoapods            |
|:see_no_evil:      |ignore something                        |

### Where's updated for this task
|emoji              |mean                                    |
|-------------------|----------------------------------------|
|:art:              |update user interface                   |
|:file_cabinet:     |improve data storage                    |
|:peach:            |improve reactive feature. (peach came from stream) |

### Other
|:police_car:|improve code format drived by lint police|
|:lock:      |improve something related with signing   |

## :copyright: LICENSE
MIT
