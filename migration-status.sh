#!/bin/bash

# TODO remove this file

set -e

files=$(git ls-files src)
for f in $files; do
    nlines=$(code-stat "$f" | sed -n 's/Code lines: *//p')
    nerror=$(pyrefly check "$f" 2>&1 | sed -n 's/ *INFO *\([0-9]*\) *errors/\1/p')
    echo "$f,$nlines,$nerror"
done
