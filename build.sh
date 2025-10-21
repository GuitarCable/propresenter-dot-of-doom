#!/usr/bin/env bash

cd "$(dirname "$0")"

ruby_version=$(ruby -v | awk '{print $2}' | cut -d. -f1,2)

mkdir -p vendor/bundle
bundle config set path 'vendor/bundle'

mkdir -p build
zip -r "build/dot-of-doom-$ruby_version.zip" run.rb src vendor Gemfile config.template.yml README.md build.sh install.sh > /dev/null
