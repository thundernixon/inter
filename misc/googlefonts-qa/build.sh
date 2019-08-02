#!/bin/bash

set -e
source build/venv/bin/activate

# make -j all_ttf_hinted

make -j all_var

# misc/fontbuild compile-var -o build/fonts/var/Inter.var.ttf src/Inter.designspace # only useful if you are testing edits to fontbuild

# because I don't want woffs yet:

woffs=$(ls build/fonts/var/*.woff*)

for woff in $woffs; do
    rm -rf $woff
done