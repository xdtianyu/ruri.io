#!/bin/bash

for file in $(find -name \*.jpg);do
    echo jpegoptim --strip-all --all-progressive "$file"
    jpegoptim --strip-all --all-progressive "$file"
done
