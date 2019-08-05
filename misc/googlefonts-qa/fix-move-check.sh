#!/bin/bash

# This script copies the latest builds to the google fonts dir in order to run QA checks and prep for a PR
#
# USAGE: 
# Install requirements with `pip install -U -r misc/googlefonts-qa/requirements.txt`
# 
# after  `make -j all_ttf`
# call this script from the root of your inter repo, with the absolute path your your google/fonts repo
# `misc/googlefonts-qa/fix-move-check.sh <your_username>/<path>/fonts`

set -e
source build/venv3/bin/activate

gFontsDir=$1
if [[ -z "$gFontsDir" || $gFontsDir = "--help" ]] ; then
    echo 'Add absolute path to your Google Fonts Git directory, like:'
    echo 'misc/googlefonts-qa/fix-move-check.sh /Users/username/type-repos/google-font-repos/fonts'
    exit 2
fi

interDir=$(pwd)

interQADir=$interDir/misc/googlefonts-qa

# interUprightVF=$interDir/build/fonts/var/Inter-Roman-VF.ttf
# interItalicVF=$interDir/build/fonts/var/Inter-Italic-VF.ttf

interFullVF=$interDir/build/fonts/var/Inter.var.ttf


# -------------------------------------------------------------------
# get latest font version -------------------------------------------
set +e

ttx -t head $interFullVF
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${interFullVF/".ttf"/".ttx"})

echo $fontVersion

rm ${interFullVF/".ttf"/".ttx"}

set -e

# # -------------------------------------------------------------------
# # fix variable font metadata as needed ------------------------------
# # these fixes all address things flagged by fontbakery --------------
# # note: this assumes variable fonts have no hinting -----------------
# # note: these should probably be moved into main build --------------

# build stat tables for proper style linking

# gftools fix-vf-meta $interFullVF
# # gftools fix-vf-meta $interItalicVF

# mv "$interFullVF.fix" $interFullVF
# # # mv "$interItalicVF.fix" $interItalicVF

# prevent warnings/issues caused by no hinting tables – this fixes the file in-place

gftools fix-nonhinting $interFullVF $interFullVF
# # gftools fix-nonhinting $interItalicVF $interItalicVF

rm ${interFullVF/".ttf"/"-backup-fonttools-prep-gasp.ttf"}
# rm ${interItalicVF/".ttf"/"-backup-fonttools-prep-gasp.ttf"}

# assert google fonts spec for how fonts should rasterize in different contexts

gftools fix-gasp --autofix $interFullVF
# gftools fix-gasp --autofix $interItalicVF

mv ${interFullVF/".ttf"/".ttf.fix"} $interFullVF
# # mv ${interItalicVF/".ttf"/".ttf.fix"} $interItalicVF

# prevent warnings/issues caused by no digital signature tables

gftools fix-dsig --autofix $interFullVF 
# gftools fix-dsig --autofix $interItalicVF

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

cp $interFullVF    ofl/inter/Inter\[slnt,wght\].ttf
# cp $interUprightVF    ofl/inter/Inter\[wght\].ttf
# cp $interItalicVF     ofl/inter/Inter-Italic\[wght\].ttf

# statics=$(ls $interDir/build/fonts/const-hinted/*.ttf)
# for ttf in $statics
# do
#     cp $ttf ofl/inter/$(basename $ttf)
# done

# -------------------------------------------------------------------
# make or move basic metadata ---------------------------------------

# gftools add-font ofl/inter # do this the first time, then edit and copy

cp $interQADir/METADATA.pb ofl/inter/METADATA.pb

cp $interDir/LICENSE.txt ofl/inter/OFL.txt

cp $interQADir/gfonts-description.html ofl/inter/DESCRIPTION.en_us.html

# -------------------------------------------------------------------
# run checks, saving to inter/misc/googlefonts-qa/checks ------------

pip install -U fontbakery # update

set +e # otherwise, the script stops after the first fontbakery check output

cd ofl/inter

# ttfs=$(ls -R Inter-*.ttf ) # use this to check only statics

# for ttf in $ttfs
# do
#     fontbakery check-googlefonts $ttf --ghmarkdown $interQADir/checks/${ttf/".ttf"/".checks.md"}
# done

fontbakery check-googlefonts Inter*slnt*wght*.ttf --ghmarkdown $interQADir/checks/Inter-Full-VF.checks.md
# fontbakery check-googlefonts Inter*wght*.ttf --ghmarkdown $interQADir/checks/Inter-Roman-VF.checks.md
# fontbakery check-googlefonts Inter-Italic*wght*.ttf --ghmarkdown $interQADir/checks/Inter-Italic-VF.checks.md


# -------------------------------------------------------------------
# adds and commits new changes, then force pushes -------------------

git add .
git commit -m "inter: $fontVersion added."

# push to upstream branch (you must manually go to GitHub to make PR from there)
# this is set to push to my upstream (google/fonts) rather than origin so that TravisCI can run
git push --force upstream inter