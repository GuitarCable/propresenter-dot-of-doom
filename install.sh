#!/usr/bin/env bash

cd "$(dirname "$0")"

HOME_DIR="$(pwd)"

ruby_version=$(ruby -v | awk '{print $2}' | cut -d. -f1,2)

DIRECTORY=""

if [ $# -ge 1 ]; then
    DIRECTORY=$1
    echo "$DIRECTORY"
else
    DIRECTORY="$HOME_DIR/install"
fi

if [ -d "$DIRECTORY" ] && [ "$(find "$DIRECTORY" -mindepth 1 -print -quit)" ]; then
    read -s -p "$DIRECTORY is not empty. Are you sure that you want to overwrite this dir's contents? (y/n)" input
    if [[ "$input" =~ ^[Yy]$ ]]; then
        cd "$DIRECTORY"
        find . ! -name 'config.yml' -type f -exec rm -f {} +
    else
        exit 1
    fi
else
    mkdir -p "$DIRECTORY"
fi

cd "$HOME_DIR"

if ! ./build.sh; then
  echo "Build failed."
  exit 1
fi

cd "$HOME_DIR"

if [ ! -f "build/dot-of-doom-$ruby_version.zip" ]; then
  echo "Zip file not found."
  exit 1
fi

unzip "build/dot-of-doom-$ruby_version.zip" -d "$DIRECTORY" > /dev/null
