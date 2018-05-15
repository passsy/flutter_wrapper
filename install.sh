#!/usr/bin/env sh

echo "Installing Flutter Wrapper..."

# Download latest flutterw version
curl -O "https://raw.githubusercontent.com/passsy/flutter_wrapper/master/flutterw"

# make it executable
chmod 755 flutterw

# add it to git
git add flutterw

# initialize flutter for first run
./flutterw

echo "Flutter Wrapper installed, run your app with\n\t./flutterw run"
