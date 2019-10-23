#!/bin/bash

set -e
source build/venv/bin/activate

# make -j all_ttf_hinted

# make -j all_var
# FONTBUILD_FLAGS=--compact-style-names make -j all_var

## clean up generated UFOS
if [[ $(ls -d src/*.ufo) ]]; then
    echo "cleaning UFOs"
    ufos=$(ls -d src/*.ufo)
    for ufo in $ufos; do
        echo "removing $ufo"
        rm -rf $ufo
    done
else
    echo "no UFOs to clean"
fi

## clean up generated designspaces
if [[ $(ls src/*.designspace) ]]; then
    echo "cleaning designspaces"
    designspaces=$(ls src/*.designspace)
    for d in $designspaces; do
        echo "removing $d"
        rm $d
    done
else
    echo "no designspaces to clean"
fi


# make clean

make designspace

misc/fontbuild compile-var --compact-style-names -o build/fonts/var/Inter.var.ttf src/Inter.designspace


# misc/fontbuild compile-var -o build/fonts/var/Inter.var.ttf src/Inter.designspace # only useful if you are testing edits to fontbuild

## because I don't want woffs yet:

# woffs=$(ls build/fonts/var/*.woff*)

# for woff in $woffs; do
#     rm -rf $woff
# done
