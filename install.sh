#!/usr/bin/env sh

echo "\nInstalling Flutter Wrapper\n"

# Download latest flutterw version
curl -O "https://raw.githubusercontent.com/passsy/flutter_wrapper/master/flutterw"

# make it executable
chmod 755 flutterw

# add it to git
git add flutterw

FLUTTER_DIR_NAME='.flutter'

# add the flutter submodule
git submodule add -b master git@github.com:flutter/flutter.git $FLUTTER_DIR_NAME


echo -e "\nFlutter Wrapper installed, run your app with\n\n\t./flutterw run\n"
