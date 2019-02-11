#!/usr/bin/env sh

###
# Check preconditions
###

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


###
# Parse arguments
###

# Parse arguments
while [ "$1" != "" ]; do case $1 in

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
  
  starts_with_v=`echo "$VERSION_TAG" | cut -c 1`
  if [ "$starts_with_v" != "v" ]; then
    # add v prefix for tag if not present
    VERSION_TAG="v$VERSION_TAG"
  fi
fi

printf "Installing Flutter Wrapper $VERSION_TAG\n"


###
# Add .flutter submodule
###
FLUTTER_DIR_NAME='.flutter'

# Check if submodule already exists (when updating flutter wrapper)
HAS_SUBMODULE=`git submodule | grep "\ \.flutter"`
if [ -z "$HAS_SUBMODULE" ]; then
  printf "adding '.flutter' submodule\n"
  UPDATED=false
  # add the flutter submodule
  git submodule add -b stable https://github.com/flutter/flutter.git $FLUTTER_DIR_NAME

  # When submodule failed, abort
  if [ ! $? -eq 0 ]; then
    echo "Abort installation of flutterw, couldn't clone flutter" >&2
    exit 1
  fi
else
  # update url to https
  printf "Upgrading existing flutter wrapper\n"
  UPDATED=true

  # Update old ssh url to https
  USES_SSH=`git config --file=.gitmodules submodule.\.flutter.url | cut -c 1-4`
  if [ "$USES_SSH" = "git@" ]; then
    printf "Update .flutter submodule url to https\n"
    git config --file=.gitmodules submodule.\.flutter.url https://github.com/flutter/flutter.git
    git add .gitmodules
    git submodule sync .flutter
  fi
fi


###
# Downlaod flutterw exectuable
###
printf "Downloading new flutterw\n"
# Download latest flutterw version
FLUTTERW_URL="https://raw.githubusercontent.com/passsy/flutter_wrapper/$VERSION_TAG/flutterw"
curl -sfO "$FLUTTERW_URL"
if [ "$?" != "0" ]; then
  printf "Couldn't downlaod flutterw from '$FLUTTERW_URL'\n"
  exit 1
fi

# make it executable
chmod 755 flutterw

# Replace version string in wrapper
sed -i.bak "s/VERSION_PLACEHOLDER/$VERSION_TAG/g" flutterw && rm flutterw.bak

# Replace date placeholder in wrapper
DATE=`date '+%Y-%m-%d %H:%M:%S'`
sed -i.bak "s/DATE_PLACEHOLDER/$DATE/g" flutterw && rm flutterw.bak

# add it to git
git add flutterw


###
# Downlaod flutterw exectuable
###

# bind this flutter instance to the project (update .packages file)
./flutterw packages get

if $UPDATED ; then
  printf "\nFlutter Wrapper updated to version $VERSION_TAG\n\n"
else
  printf "\nFlutter Wrapper installed (version $VERSION_TAG), initialized with channel stable.\n\n"
fi
printf "Run your app with:     ./flutterw run\n"
printf "Switch channel:        ./flutterw channel beta\n"
