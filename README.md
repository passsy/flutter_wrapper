# Flutter Wrapper

Similar to the gradle wrapper, an executable shell script in the root of you project, `flutterw` which downloads and runs flutter in the correct version for every user.

The flutter wrapper will add flutter as a submodule to your project which pins the version allowing you to upgrade flutter for all developers in you project at the same time.

Read the story on [Medium](https://medium.com/grandcentrix/flutter-wrapper-bind-your-project-to-an-explicit-flutter-release-4062cfe6dcaf)

## Get started

#### Install wrapper

Run this command from the root of your flutter project

```bash
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh | bash -
```
Don't forget to commit your changes afterwards.


#### Get started with Flutter without adding flutter to your PATH

The [Flutter install process](https://flutter.io/setup-macos/#get-sdk) is not perfectly automated. You have to manually download Flutter and add it to your path before you can use the awesome Flutter CLI to create a new project. With the flutter wrapper this becomes easier.

```bash
mkdir flutter_wrapper_project && cd "$_"
git init
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh | bash -
./flutterw create .
./flutterw run
```

## Maintenance

#### Update flutter wrapper

Run the install command again.

```bash
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh | bash -
```

If you want a specific version, use this for `v0.6.0`

```bash
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh | bash /dev/stdin -t v0.6.0
```

#### Uninstall flutter wrapper

Removing submodules is hard, that's why I did the hard work for you.
Simply run this command from the root of your flutter project and the uninstall script will cleanup everything.

```bash
curl -sL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/uninstall.sh | bash -
```

#### Update flutter version

No special command required. Run `./flutterw channel <master|dev|beta>`, afterwards add and commit changed `.flutter` submodule reference.


## License

```
Copyright 2018 Pascal Welsch

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
