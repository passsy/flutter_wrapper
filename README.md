# Flutter Wrapper

`flutterw` is a tiny, open source shell script which downloads and executes the Flutter SDK with the exact version defined in your project respository.
It encourages the idea that upgrading Flutter should happen per project, not per developer.
Thus upgrading Flutter with `flutterw` automatically upgrades Flutter for your co-workers and on the CI servers.

The Flutter Wrapper will add the Flutter SDK as a git submodule to your project.
It pins the version and the channel.

This project is inspired by the gradle wrapper.

Read more on [Medium](https://medium.com/grandcentrix/flutter-wrapper-bind-your-project-to-an-explicit-flutter-release-4062cfe6dcaf)


# Install flutterw

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"
```
_Open the Terminal, navigate to your project root and execute the line above._

From now on use `./flutterw` instead of `flutter`

![flutterw terminal demo](https://user-images.githubusercontent.com/1096485/64660427-840dc080-d440-11e9-97a2-a9e2bef203bd.gif)

## IDE Setup
### Use with VScode

If you're a VScode user link the new Flutter SDK path in your settings
`$projectRoot/.vscode/settings.json` (create if it doesn't exists yet)

```json
{
    "dart.flutterSdkPath": ".flutter",
}
```

Commit this file to your git repo and your coworkers will automatically use `flutterw` from now on

### Use with IntelliJ / Android Studio

Go to `File > Settings > Languages & Frameworks > Flutter` and set the Flutter SDK path to `$projectRoot/.flutter`

<img width="800" alt="IntelliJ Settings" src="https://user-images.githubusercontent.com/1096485/64658026-3a1fdd00-d436-11e9-9457-556059f68e2c.png">

Add this step to the onboarding guidelines of your projects because this has to be done for every developer for every project using `flutterw`.


## Tips and Tricks
### Upgrading Flutter

Flutter Wrapper doesn't require any special command to update Flutter.
Run `./flutterw channel <stable|beta|dev|master>` to change the channel or update to the lastest version of a given channel.

```
./flutterw channel beta
./flutterw upgrade
```

Don't forget to commit the submodule changes.  


### Updating flutterw 

To update the flutter wrapper to the latest version run the install command again:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"
```

To update the flutter wrapper to a specific verssion, use the `-t <tag/branch>` (i.e. `v1.0.0`)

```bash
sh -c "curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh" | bash /dev/stdin -t v1.0.0
```


### Uninstall flutterw

Sorry to let you go!
Removing submodules is hard, that's why I did the hard work for you.
Simply run this command from the root of your flutter project and the uninstall script will cleanup everything.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/uninstall.sh)"
```

Bye :wave:

### Create a new project using the flutter wrapper

You can create a new Flutter project without installing Flutter globally on your machine.

```bash
# 1. Create an empty git repo
mkdir flutter_wrapper_project && cd "$_"
git init

# 2. Install flutterw
sh -c "$(curl -fsSL https://raw.githubusercontent.com/passsy/flutter_wrapper/master/install.sh)"

# 3. Create Flutter project
./flutterw create .
./flutterw run
```

## License

```
Copyright 2019 Pascal Welsch

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
