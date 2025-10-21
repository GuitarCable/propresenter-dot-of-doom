#!/usr/bin/env bash

cd "$(dirname "$0")"

mkdir -p vendor/bundle
bundle config set path 'vendor/bundle'

mkdir -p build
zip -r build/dot-of-doom.zip run.rb src vendor Gemfile config.template.yml README.md > /dev/null
