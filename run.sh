#!/bin/bash

cd "$(dirname "$0")"
if [ -z "$1" ]; then
  ./dot-of-doom
else
  ./dot-of-doom --serviceType "$1"
fi
