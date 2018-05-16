#!/usr/bin/env sh

echo "Uninstalling Flutter Wrapper..."

FLUTTER_DIR_NAME='.flutter'

# remove wrapper executable via git or fallback just the wrapper file when not
# known to git
git rm -f flutterw >> /dev/null 2>&1 || rm flutterw

# remove submodule
git submodule deinit -f $FLUTTER_DIR_NAME

# remove submodule directory
git rm -rf $FLUTTER_DIR_NAME

# remove submodule history
rm -rf .git/modules/$FLUTTER_DIR_NAME

# remove empty .gitmodules file
if ! [ -s .gitmodules ]; then
  # try via git first, fallback to just rm when not added to git
  git rm -f .gitmodules >> /dev/null 2>&1 || rm .gitmodules
fi
