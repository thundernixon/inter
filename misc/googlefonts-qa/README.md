# General QA for onboarding to Google Fonts

This directory is made to run a Google Fonts onboarding process for Inter.

Specifically, the `move-check` script does a few things:
- Fixes a few pieces of font metadata to align them to Google Fonts standards
- Moves Inter font files into a google/fonts directory, to prep/update a PR to [the official google/fonts repo](https://github.com/google/fonts)
- Runs [FontBakery](https://github.com/googlefonts/fontbakery) to check the fonts against Google Fonts standards, and saves results to the [checks](checks) subfolder.

This process must be run multiple times, tweaking source files and rebuilding output fonts to solve issues flagged by FontBakery.

## Usage

### First, setup prerequisites

If you haven't already done so, open a terminal, clone this repo, and move to the `qa` branch:

```
git clone git@github.com:thundernixon/inter.git
cd inter
git checkout qa
```

FontBakery checks are made to be run on fonts within the folder structure of the [google/fonts repo](https://github.com/google/fonts). Therefore, you must have a local copy of this repo on your computer to run this QA procedure. If you don't yet have a local google/fonts repo, open a new terminal session, navigate to a parent folder for this (e.g. `cd ~/yourusername/type_repos`, but use whatever location makes sense), and clone the repo:

```
git clone git@github.com:google/fonts.git
```

Follow the guidelines at [CONTRIBUTING.md#local-toolchain](CONTRIBUTING.md#local-toolchain) to setup the local toolchain:

> **Local toolchain:** Currently the toolchain has only been tested on macOS and Linux. All you need to have preinstalled is Python 3.
> 
> The first step is to initialize the toolchain itself:
> 
> `./init.sh`

This will setup a `build` directory, including a virtual environment at `build/venv`, with dependencies necessary to build Inter fonts.

### Second, set up your testing environment

Create a Python 3 virtual environment:

```
virtualenv -p python3 build/venv3
```

Then, activate the new virtual environment:

```
source build/venv3/bin/activate
```

Now, install the QA dependencies:

```
pip install -U -r misc/googlefonts-qa/requirements.txt
```

You will also need to add the QA script to `venv3` in order to execute it. Copy and run the following:

```
cd build/venv3/bin
ln -s ../../../misc/googlefonts-qa/move-check
cd ../../..
chmod +x misc/googlefonts-qa/move-check
```

### Third, run the QA scripts to move and check the fonts

With your terminal at the top level of your Inter directory, build fresh copies of the relevant fonts by running:

```
chmod +x misc/googlefonts-qa/build.sh ; misc/googlefonts-qa/build.sh
```

Then, run the move-check script:

```
move-check <absolute_path_to_parent_dir>/fonts
```

If all goes well, you will have created a local `inter` branch in your google fonts directory, moved the fresh fonts there, and run QA checks which will create new markdown documents at `misc/googlefonts-qa/checks`.

## Re-running checks after changes to source

If you have changed the source file (`Inter.glyphs`) to solve for an issue flagged by FontBakery checks, you need to rebuild the fonts in order to rerun the checks, and verify your attempted solution.

Simply re-run the build:

```
misc/googlefonts-qa/build.sh
```

...then re-run the move and checks:

```
move-check <absolute_path_to_parent_dir>/fonts
```