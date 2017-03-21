#!/bin/bash

for file in $(find -name \*thumb.jpg);do
    echo guetzli -quality 90 "$file" "$file"
    guetzli -quality 90 "$file" "$file"
done
