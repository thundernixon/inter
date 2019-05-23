#!/bin/bash

set -e
source build/venv/bin/activate

# make -j all_ttf_hinted

make -j all_var

mv build/fonts/var/Inter-upright.var.ttf build/fonts/var/Inter-Roman-VF.ttf 
mv build/fonts/var/Inter-italic.var.ttf build/fonts/var/Inter-Italic-VF.ttf 

# because I don't want woffs yet:

woffs=$(ls build/fonts/var/*.woff*)

for woff in $woffs; do
    rm -rf $woff
done