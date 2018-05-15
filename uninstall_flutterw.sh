#!/usr/bin/env sh

FLUTTER_DIR_NAME='.flutter'

# remove wrapper executable
rm flutterw

# remove submodule
git submodule deinit -f $FLUTTER_DIR_NAME

# remove submodule directory
git rm -f $FLUTTER_DIR_NAME

# remove submodule history
rm -rf .git/modules/$FLUTTER_DIR_NAME
