#!/bin/bash

# This script copies the latest builds to the google fonts dir in order to run QA checks and prep for a PR
#
# USAGE: 
# Install requirements with `pip install -U -r misc/googlefonts-qa/requirements.txt`
# 
# use `ln -s <absolute_path>` to symbolically link this script into build/venv/bin, then activate the venv
# have a google/fonts repo on your local machine
# 
# after  `make -j all_ttf`
# call this script from the root of your inter repo, with the absolute path your your google/fonts repo
# `move-check <your_username>/<path>/fonts`

set -e
source build/venv3/bin/activate

gFontsDir=$1
if [[ -z "$gFontsDir" || $gFontsDir = "--help" ]] ; then
    echo 'Add absolute path to your Google Fonts Git directory, like:'
    echo 'move-check /Users/username/type-repos/google-font-repos/fonts'
    exit 2
fi

interDir=$(pwd)

interQADir=$interDir/misc/googlefonts-qa

interUprightVF=$interDir/build/fonts/var/Inter-upright.var.ttf
interItalicVF=$interDir/build/fonts/var/Inter-italic.var.ttf


# -------------------------------------------------------------------
# get latest font version -------------------------------------------

ttx -t head $interUprightVF
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${interUprightVF/".ttf"/".ttx"})
rm ${interUprightVF/".ttf"/".ttx"}

# -------------------------------------------------------------------
# fix variable font metadata as needed ------------------------------
# note: this assumes variable fonts have no hinting -----------------
# note: these should probably be moved into main build --------------

# TODO: test VFs with TTFautohint-VF vs no hinting

gftools fix-nonhinting $interUprightVF $interUprightVF
gftools fix-nonhinting $interItalicVF $interItalicVF

# TODO: decide if `--autofix` is really the best option, or if we should assert more control
gftools fix-gasp --autofix $interUprightVF
gftools fix-gasp --autofix $interItalicVF

gftools fix-dsig --autofix $interUprightVF
gftools fix-dsig --autofix $interItalicVF

tempFiles=$(ls build/fonts/var/*.fix && ls build/fonts/var/*-gasp*)
for temp in $tempFiles
do
    rm -rf $temp
done

# -------------------------------------------------------------------
# navigate to google/fonts repo, get latest, then update inter branch

cd $gFontsDir
git checkout master
git pull upstream master
git reset --hard
git checkout -B inter
git clean -f -d

# -------------------------------------------------------------------
# move fonts --------------------------------------------------------

mkdir -p ofl/inter

cp $interUprightVF    ofl/inter/Inter-Regular.ttf
cp $interItalicVF     ofl/inter/Inter-Italic.ttf

mkdir -p ofl/inter/static
statics=$(ls $interDir/build/fonts/const-hinted/*.ttf)
for ttf in $statics
do
    cp $ttf ofl/inter/static/$(basename $ttf)
done

# -------------------------------------------------------------------
# make or move basic metadata ---------------------------------------

# gftools add-font --update ofl/inter # do this the first time, then edit and copy

cp $interQADir/METADATA.pb ofl/inter/METADATA.pb

cp $interDir/LICENSE.txt ofl/inter/OFL.txt

cp $interQADir/gfonts-description.html ofl/inter/DESCRIPTION.en_us.html

# -------------------------------------------------------------------
# run checks, saving to inter/misc/googlefonts-qa/checks ------------

set +e # otherwise, the script stops after the first fontbakery check output

mkdir -p $interQADir/checks/static

cd ofl/inter

# ttfs=$(ls -R */*.ttf && ls *.ttf) # use this to statics and VFs
ttfs=$(ls *.ttf) # use this to check only the VFs
# ttfs=$(ls -R */*.ttf ) # use this to check only statics

for ttf in $ttfs
do
    fontbakery check-googlefonts $ttf --ghmarkdown $interQADir/checks/${ttf/".ttf"/".checks.md"}
done

# git add .
# git commit -m "inter: $fontVersion added."

# # push to upstream branch (you must manually go to GitHub to make PR from there)
# # this is set to push to my upstream (google/fonts) rather than origin so that TravisCI can run
# git push --force upstream inter