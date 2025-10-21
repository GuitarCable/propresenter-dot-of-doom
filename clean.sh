#!/usr/bin/env bash

cd "$(dirname "$0")"

cd build

find . -type f -exec rm -f {} +
