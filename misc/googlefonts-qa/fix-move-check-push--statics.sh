#!/bin/bash

# This script copies the latest builds to the google fonts dir in order to run QA checks and prep for a PR
#
# USAGE: 
# Install requirements with `pip install -U -r misc/googlefonts-qa/requirements.txt`
# 
# after  `misc/googlefonts/build.sh`
# call this script from the root of your inter repo, with the absolute path your your google/fonts repo
# `misc/googlefonts-qa/fix-move-check.sh <your_username>/<path>/fonts`
#
# add `push` to the end if you wish to push the result to GitHub


set -e
source build/venv/bin/activate

gFontsDir=$1
if [[ -z "$gFontsDir" || $gFontsDir = "--help" ]] ; then
    echo 'Add absolute path to your Google Fonts Git directory, like:'
    echo 'misc/googlefonts-qa/fix-move-check.sh /Users/username/type-repos/google-font-repos/fonts'
    exit 2
fi

# option to push to GitHub. Without this, it will do a dry run.
pushToGitHub=$2
gitBranch="inter-statics"

interDir=$(pwd)
interQADir=$interDir/misc/googlefonts-qa

interStaticsDir=$interDir/build/googlefonts/statics

# -------------------------------------------------------------------
# get latest font version -------------------------------------------
set +e

exampleFont=$interStaticsDir/Inter-BlackItalic.ttf
ttx -t head $exampleFont
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${exampleFont/".ttf"/".ttx"})

echo $fontVersion

rm ${exampleFont/".ttf"/".ttx"}

set -e

# # -------------------------------------------------------------------
# # fix static font metadata as needed --------------------------------
# # these fixes all address things flagged by fontbakery --------------

statics=$(ls $interStaticsDir)

for font in $statics; do
    fontPath=$interStaticsDir/$font
    # assert google fonts spec for how fonts should rasterize in different contexts
    gftools fix-gasp --autofix $fontPath

    mv ${fontPath/".ttf"/".ttf.fix"} $fontPath

    # prevent warnings/issues caused by no digital signature tables
    gftools fix-dsig --autofix $fontPath 


done

# -------------------------------------------------------------------
# navigate to google/fonts repo, get latest, then update inter branch

cd $gFontsDir
git checkout master
git pull upstream master
git reset --hard
git checkout -B $gitBranch
git clean -f -d

# -------------------------------------------------------------------
# move fonts --------------------------------------------------------

mkdir -p ofl/inter

for font in $statics; do
    fontPath=$interStaticsDir/$font
    cp $fontPath ofl/inter/$font
done

# -------------------------------------------------------------------
# make or move basic metadata ---------------------------------------

gftools add-font ofl/inter

cp $interDir/LICENSE.txt ofl/inter/OFL.txt

cp $interQADir/gfonts-description.html ofl/inter/DESCRIPTION.en_us.html

# -------------------------------------------------------------------
# run checks, saving to inter/misc/googlefonts-qa/checks ------------

# pip install -U fontbakery # update

# set +e # otherwise, the script stops after the first fontbakery check output

# cd ofl/inter

# statics=$(ls)

# # # just to make it easy to see fontbakery checks
# for font in $statics; do
#     fontbakery check-googlefonts $font --ghmarkdown $interQADir/checks/${font/'.ttf'/'.checks.md'}
# done

# -------------------------------------------------------------------
# adds and commits new changes, then force pushes -------------------

if [[ $pushToGitHub = "push" ]] ; then
    git add .
    git commit -m "inter statics: $fontVersion added."

    # push to upstream branch (you must manually go to GitHub to make PR from there)
    # this is set to push to my upstream (google/fonts) rather than origin so that TravisCI can run
    git push --force upstream $gitBranch
fi
