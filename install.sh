#!/usr/bin/env sh

echo "\nInstalling Flutter Wrapper\n"

# Verify flutter project is a git repo
inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
if ! [ "$inside_git_repo" ]; then
  printf "Error: Not a git repository, to fix this run: git init\n"
  exit 1
fi

# Make sure this is the root of the flutter dir (search for pubspec.yaml)
if ! [ -f pubspec.yaml ]; then
  printf "Warning: Not executed in flutter root. Couldn't find pubspec.yaml.\n"
  printf "Continuing in case this flutter wrapper is used to create a new project. If so continue with './flutterw create .'\n\n"
fi

# Download latest flutterw version
curl -O "https://raw.githubusercontent.com/passsy/flutter_wrapper/master/flutterw"

# make it executable
chmod 755 flutterw

# add it to git
git add flutterw

FLUTTER_DIR_NAME='.flutter'

# add the flutter submodule
git submodule add -b master git@github.com:flutter/flutter.git $FLUTTER_DIR_NAME

echo -e "\nFlutter Wrapper installed, switched to channel master.\n"
echo -e "Run your app with:\t./flutterw run"
echo -e "Switch channel:\t\t./flutterw channel beta"
