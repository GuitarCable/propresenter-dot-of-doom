#!/bin/bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh

cd "$(dirname "$0")"
chruby 3.4.7
./src/TextSender.rb
