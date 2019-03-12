#!/bin/bash

set -e
source build/venv/bin/activate

make -j all_ttf_hinted

make -j all_var
