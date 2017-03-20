#!/bin/bash

for file in $(find -name \*.jpg);do
    echo guetzli -quality 90 "$file" "$file"
    convert "$file" "$file.png"
    guetzli -quality 90 "$file.png" "$file"
    rm "$file.png"
done
