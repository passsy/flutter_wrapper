#!/usr/bin/env sh

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

# Parse arguments
while [[ $# -gt 0 ]]; do case $1 in

  # version tag which should be used for downloading
  -t|--tag)
  shift
  VERSION_TAG="$1"
  ;;

  *)
  echo "Unknown option '$key'"
  ;;
  esac
  shift
done

if [ -z "$VERSION_TAG" ]; then
  # Get latest version from master in git
  VERSION_TAG=`curl -s "https://raw.githubusercontent.com/passsy/flutter_wrapper/master/version"`
fi


printf "Installing Flutter Wrapper $VERSION_TAG\n"

printf "Downloading flutterw\n"
# Download latest flutterw version
curl -sO "https://raw.githubusercontent.com/passsy/flutter_wrapper/$VERSION_TAG/flutterw"

# make it executable
chmod 755 flutterw

# Replace version string in wrapper
sed -i '' "s/VERSION_PLACEHOLDER/$VERSION_TAG/g" flutterw

# add it to git
git add flutterw

FLUTTER_DIR_NAME='.flutter'

printf "adding '.flutter' submodule\n"
# add the flutter submodule
git submodule add -b master git@github.com:flutter/flutter.git $FLUTTER_DIR_NAME

# bind this flutter instance to the project (update .packages file)
./flutterw packages get

printf "\nFlutter Wrapper installed, initialized with channel master.\n\n"
printf "Run your app with:     ./flutterw run\n"
printf "Switch channel:        ./flutterw channel beta\n"
