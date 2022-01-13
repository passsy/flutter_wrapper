## 1.3.0

- Don't clear .gitmodules when calling `flutter channel` without a channel [#26](https://github.com/passsy/flutter_wrapper/pull/26)
- Move echos to `stderr`, so that the output of `stdout` is not changed for scripts consuming it [#24](https://github.com/passsy/flutter_wrapper/pull/24)
- Don't error `flutter upgrade` when `pubspec.lock` doesn't exist [#28](https://github.com/passsy/flutter_wrapper/pull/28) 
- This project is now tested! This gives me personally confidence to change things without breaking your project

## 1.2.0

- Fix submodule initialization detection #22
- Support for multi-package repositories #18
- Support placing flutterw in a sub folder #17
- Added tests so I don't accidentally break your project

## 1.1.2

- Always switch to defined channel to fix `./flutterw upgrade` #19
- Escape all git arguments

## 1.1.1

- Escape arguments in post flutterw section 7701728ffab0053db5a5f5b647c2c38ea0e0b27e
- Fix `./flutterw upgrade` when branch (`stable`) is not fetched ba5729987c10d62cd860b3b81ebc8ae62484b86c

## 1.1.0

- `./flutterw upgrade` and `./flutterw channel X` now works without manual adjustments inside the submodule #15
- The channel (master|dev|beta|stable) is now synced with what's defined in `.gitmodules`

## 1.0.3

- Fix submodule matching in install script 605854d1db5053fd36814d4a9733e9d1b182bcd3

## 1.0.2

- Improve `.flutter` submodule matching 5008757479b29c7296fb9143e6adb859a392ba7e a1c7c7fa8903c5bf0b3344e921dfbd6c45cedcc7

## 1.0.1

- Fix `.flutter` submodule existence check, allow other submodules containing `flutter` as name #7

## 1.0.0

- Use flutters stable branch as default channel

## 0.8.0

- #4 Use `https` instead of `ssh` to clone flutter
- fc7d105 fail fast on download error

## 0.7.1

- Fix: Download flutterw from latest tag defined in `version` file 053fc8a4aeb219d70c6793fb71bd334e1d860f37

## 0.7.0

- Linux support (Hello PixelBook 😁) #3

## 0.6.1

- Fix: Abort install script when git clone fails 8ec7c79748e11ab8e04356e5ca574ad9de3b4140
- Fix: '.flutter' already exists in the index during update d02f505be2cf2648d67fc260c812a387d5e05cf1

## 0.6.0

- Download version which is defined in `version` on master branch. Prevents downloading of preview versions
- Adds version and date to `flutterw` header
- `install.sh` does now support the argument `--tag|-t` for the git tag to download
