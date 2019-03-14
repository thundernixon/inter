# General QA for onboarding to Google Fonts

This directory is made to run a Google Fonts onboarding process for Inter.

Specifically, the `move-check` script does a few things:
- Fixes a few pieces of font metadata to align them to Google Fonts standards
- Moves Inter font files into a google/fonts directory, to prep/update a PR to [the official google/fonts repo](https://github.com/google/fonts)
- Runs [FontBakery](https://github.com/googlefonts/fontbakery) to check the fonts against Google Fonts standards, and saves results to the [checks](checks) subfolder.

This process must be run multiple times, tweaking source files and rebuilding output fonts to solve issues flagged by FontBakery.

## Usage

### First, build Inter fonts

Follow the guidelines at https://github.com/rsms/inter/blob/master/CONTRIBUTING.md#local-toolchain to setup the local toolchain.

This will setup a `build` directory, including a virtual environment at `build/venv`. Activate this:

```
source build/venv/bin/activate
```

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

FontBakery checks are made to be run on fonts within the folder structure of the [google/fonts repo](https://github.com/google/fonts). Therefore, you must have a local copy of this repo on your computer to run this QA procedure. If you don't yet have a local google/fonts repo, open a new terminal session, navigate to a parent folder for this (I use `~/stephennixon/type_repos`, but you can use whatever makes sense), and clone the repo:

```
git clone git@github.com:google/fonts.git
```

Next, get your terminal back into your Inter project, and build fresh copies of the relevant fonts by running:

```
chmod +x misc/googlefonts-qa/build.sh ; misc/googlefonts-qa/build.sh
```

Then, run the move-check script:

```
move-check <absolute_path_to_parent_dir>/fonts
```

If all goes well, you will have created a local `inter` branch in your google fonts directory, moved the fresh fonts there, and run QA checks which will create new markdown documents at `misc/googlefonts-qa/checks`.