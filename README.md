# Flutter Wrapper

Similar to the gradle wrapper, an executable shell script in the root of you project, `flutterw` which downloads and runs flutter with the same version, part of your repository, for every user and CI.

The flutter wrapper will add flutter as a submodule to your project which pins the version allowing you to upgrade flutter for all developers in you project at the same time.

Read the story on [Medium](https://medium.com/grandcentrix/flutter-wrapper-bind-your-project-to-an-explicit-flutter-release-4062cfe6dcaf)

## How to use Flutter Wrapper

### Add the Flutter Wrapper to your project

Run this command from the root of your flutter project

> `sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"`
> 
All required files are already added to git. You can commit them now 

> `git commit -m "Add flutter wrapper"`

From now on you should always use `./flutterw` instead of `flutter`

### Update Flutter

Flutter Wrapper doesn't require any special command to update Flutter.
Run `./flutterw channel <stable|beta|master>` to change the channel or update to the lastest version of a given channel.

> `./flutterw channel stable` 

The only change you'll see in git is the changed sha1 of the `.flutter` submodule.
You have to commit it to update flutter for all project members.


### Update flutter wrapper

To update the flutter wrapper to the latest version run the install command again:

> `sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"`

To update the flutter wrapper to a specific verssion, use the `-t <tag/branch>` (i.e. `v0.8.0`)

> `sh -c "curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh" | bash /dev/stdin -t v1.0.0`

## Advanced Usage

### Uninstall flutter wrapper

Removing submodules is hard, that's why I did the hard work for you.
Simply run this command from the root of your flutter project and the uninstall script will cleanup everything.

> `sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/uninstall.sh)"`

Bye :wave:

### Get started with Flutter without adding flutter to your PATH

The [Flutter install process](https://flutter.io/setup-macos/#get-sdk) is not perfectly automated.
You have to manually download Flutter and add it to your path before you can use the awesome Flutter CLI to create a new project.
With the Flutter Wrapper this becomes easier.

```bash
mkdir flutter_wrapper_project && cd "$_"
git init
sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"
./flutterw create .
./flutterw run
```

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
