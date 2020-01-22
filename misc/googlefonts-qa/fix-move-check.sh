#!/bin/bash

# This script copies the latest builds to the google fonts dir in order to run QA checks and prep for a PR
#
# USAGE: 
# Install requirements with `pip install -U -r misc/googlefonts-qa/requirements.txt`
# 
# after  `misc/googlefonts-qa/build.sh`
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

interDir=$(pwd)

interQADir=$interDir/misc/googlefonts-qa

# interUprightVF=$interDir/build/fonts/var/Inter-Roman-VF.ttf
# interItalicVF=$interDir/build/fonts/var/Inter-Italic-VF.ttf

interFullVF=$interDir/build/googlefonts/Inter.var.ttf


# -------------------------------------------------------------------
# get latest font version to use in PR commit message ---------------
set +e

ttx -t head $interFullVF
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${interFullVF/".ttf"/".ttx"})

echo $fontVersion

rm ${interFullVF/".ttf"/".ttx"}

set -e

# # -------------------------------------------------------------------
# # fix variable font versions: add git hash if missing ---------------

latestHash=$(git log --author=Rasmus -n 1 --pretty=format:"%h")
python misc/googlefonts-qa/patch-git-hash-version-names.py $interFullVF -g $latestHash -i


# # -------------------------------------------------------------------
# # fix variable font metadata as needed ------------------------------
# # these fixes all address things flagged by fontbakery --------------
# # note: this assumes variable fonts have no hinting -----------------
# # note: these should probably be moved into main build --------------

pip install -U git+https://github.com/googlefonts/gftools.git

# build stat tables for proper style linking – currently only works for single-axis VFs
# gftools fix-vf-meta $interFullVF
# mv "$interFullVF.fix" $interFullVF

# prevent warnings/issues caused by no hinting tables – this fixes the file in-place
gftools fix-nonhinting $interFullVF $interFullVF

rm ${interFullVF/".ttf"/"-backup-fonttools-prep-gasp.ttf"}

# assert google fonts spec for how fonts should rasterize in different contexts
gftools fix-gasp --autofix $interFullVF

mv ${interFullVF/".ttf"/".ttf.fix"} $interFullVF

# prevent warnings/issues caused by no digital signature tables
gftools fix-dsig --autofix $interFullVF 

# TODO: test the MVAR-dropping code below
# drop mvar table using fonttools/ttx
ttx -x MVAR $interFullVF
ttx ${interFullVF/'.ttf'/'.ttx'}                   # convert back to TTF
rm ${interFullVF/'.ttf'/'.ttx'}                    # erase temp TTX 
mv ${interFullVF/'.ttf'/'#1.ttf'} $interFullVF     # overwrite original TTF with edited copy


# add family suffix to static fonts to avoid font menu clashes
# TODO: test on whole folder

statics=$(ls $interDir/build/googlefonts/statics/*.ttf)
for ttf in $statics; do
    python misc/googlefonts-qa/patch-static-family-names.py $ttf --inplace
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
mkdir -p ofl/inter/static

cp $interFullVF    ofl/inter/Inter\[slnt,wght\].ttf
# cp $interUprightVF    ofl/inter/Inter\[wght\].ttf
# cp $interItalicVF     ofl/inter/Inter-Italic\[wght\].ttf

statics=$(ls $interDir/build/googlefonts/statics/*.ttf)
for ttf in $statics
do
    cp $ttf ofl/inter/static/$(basename $ttf)
done

# -------------------------------------------------------------------
# make or move basic metadata ---------------------------------------

# gftools add-font ofl/inter # do this the first time, then edit and copy

cp $interQADir/METADATA.pb ofl/inter/METADATA.pb

cp $interDir/LICENSE.txt ofl/inter/OFL.txt

cp $interQADir/gfonts-description.html ofl/inter/DESCRIPTION.en_us.html

# # -------------------------------------------------------------------
# # run checks, saving to inter/misc/googlefonts-qa/checks ------------

# pip install -U fontbakery # update

set +e # otherwise, the script stops after the first fontbakery check output

cd ofl/inter

# # just to make it easy to see fontbakery checks

# fontbakery check-googlefonts Inter*slnt*wght*.ttf --ghmarkdown $interQADir/checks/Inter-Full-VF.checks.md

# -------------------------------------------------------------------
# adds and commits new changes, then force pushes -------------------

if [[ $pushToGitHub = "push" ]] ; then
    git add .
    git commit -m "inter: $fontVersion added."

    # push to upstream branch (you must manually go to GitHub to make PR from there)
    # this is set to push to my upstream (google/fonts) rather than origin so that TravisCI can run
    git push --force upstream inter
fi
