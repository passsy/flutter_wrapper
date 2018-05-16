# Flutter Wrapper

Similar to the gradle wrapper, an executable shell script in the root of you project, `flutterw` which downloads and runs flutter in the correct version for every user.

The flutter wrapper will add flutter as a submodule to your project which pins the version allowing you to upgrade flutter for all developers in you project at the same time.

## Install wrapper

Run this command from the root of your flutter project

```bash
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh | bash -
```
Don't forget to commit your changes afterwards.

## Update wrapper

Run the install command again.

## Uninstall wrapper

Removing submodules is hard, that's why I did the hard work for you.
Simply run this command from the root of your flutter project and the uninstall script will cleanup everything.

```bash
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/uninstall.sh | bash -
```

## Update flutter

Run `./flutterw channel <master|dev|beta>`, afterwards add and commit changed `.flutter` submodule reference.
