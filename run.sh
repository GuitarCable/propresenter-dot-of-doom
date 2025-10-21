#!/usr/bin/env bash

export GEM_HOME=$(pwd)/vendor/bundle
export GEM_PATH=$GEM_HOME
export BUNDLE_GEMFILE=$(pwd)/Gemfile
ruby src/TextSender.rb
