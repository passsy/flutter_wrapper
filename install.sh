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
# flutterw should be placed next to
if ! [ -f pubspec.yaml ]; then
  printf "Warning: Not executed in flutter root. Couldn't find pubspec.yaml.\n"
  printf "Continuing in case this flutter wrapper is used to create a new project. If so continue with './flutterw create .'\n\n"
fi

###
# Parse arguments
###

# Parse arguments
while [ "$1" != "" ]; do
  case $1 in

  # version tag which should be used for downloading
  -t | --tag)
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
  VERSION_TAG=$(curl -s "https://raw.githubusercontent.com/passsy/flutter_wrapper/master/version")

  starts_with_v=$(echo "$VERSION_TAG" | cut -c 1)
  if [ "$starts_with_v" != "v" ]; then
    # add v prefix for tag if not present
    VERSION_TAG="v$VERSION_TAG"
  fi
fi

printf "Installing Flutter Wrapper %s\n" "$VERSION_TAG"

###
# Add .flutter submodule
###
FLUTTER_SUBMODULE_NAME='.flutter'
GIT_HOME=$(git rev-parse --show-toplevel)

# Check if submodule already exists (when updating flutter wrapper)
HAS_SUBMODULE=$(git -C "${GIT_HOME}" submodule | grep "\ ${FLUTTER_SUBMODULE_NAME}")
if [ -z "${HAS_SUBMODULE}" ]; then
  printf "adding '%s' submodule\n" "${FLUTTER_SUBMODULE_NAME}"
  UPDATED=false

  # create relative to <gitRoot>/.flutter
  source=$PWD
  target=${GIT_HOME}/${FLUTTER_SUBMODULE_NAME}
  common_part=$source
  back=
  while [ "${target#$common_part}" = "${target}" ]; do
    common_part=$(dirname "$common_part")
    back="../${back}"
  done
  CLONE_TO=${back}${target#$common_part/}

  # add the flutter submodule
  git submodule add -b stable https://github.com/flutter/flutter.git "${CLONE_TO}"

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
  SUBMODULE_PATH=$(git config -f "${GIT_HOME}/.gitmodules" "submodule.$FLUTTER_SUBMODULE_NAME.path" )

  USES_SSH=$(git config -f "${GIT_HOME}/.gitmodules" "submodule.${SUBMODULE_PATH}.url" | cut -c 1-4)
  if [ "$USES_SSH" = "git@" ]; then
    printf "Update %s submodule url to https\n" "$FLUTTER_SUBMODULE_NAME"
    git config -f "${GIT_HOME}/.gitmodules submodule.${SUBMODULE_PATH}.url" https://github.com/flutter/flutter.git
    git add "${GIT_HOME}/.gitmodules"
    git submodule sync "${FLUTTER_SUBMODULE_NAME}"
  fi
fi

###
# Download flutterw executable
###
printf "Downloading new flutterw\n"
# Download latest flutterw version
FLUTTERW_URL="https://raw.githubusercontent.com/passsy/flutter_wrapper/$VERSION_TAG/flutterw"
curl -sfO "$FLUTTERW_URL"
if [ "$?" != "0" ]; then
  printf "Couldn't download flutterw from '%s'\n" "$FLUTTERW_URL"
  exit 1
fi

# make it executable
chmod 755 flutterw

# Replace version string in wrapper
sed -i.bak "s/VERSION_PLACEHOLDER/$VERSION_TAG/g" flutterw && rm flutterw.bak

# Replace date placeholder in wrapper
DATE=$(date '+%Y-%m-%d %H:%M:%S')
sed -i.bak "s/DATE_PLACEHOLDER/$DATE/g" flutterw && rm flutterw.bak

# add it to git
git add flutterw

###
# Run flutterw
###

# bind this flutter instance to the project (update .packages file)
if [ -f pubspec.yaml ]; then
  ./flutterw packages get
fi

if $UPDATED; then
  printf "\nFlutter Wrapper updated to version %s\n\n" "$VERSION_TAG"
else
  printf "\nFlutter Wrapper installed (version %s), initialized with channel stable.\n\n" "$VERSION_TAG"
fi
printf "Run your app with:     ./flutterw run\n"
printf "Switch channel:        ./flutterw channel beta\n"
