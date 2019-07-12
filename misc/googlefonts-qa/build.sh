#!/bin/bash

set -e
source build/venv/bin/activate

# make -j all_ttf_hinted

misc/fontbuild compile-var -o build/fonts/var/Inter.var.ttf src/Inter.designspace

# because I don't want woffs yet:

woffs=$(ls build/fonts/var/*.woff*)

for woff in $woffs; do
    rm -rf $woff
done