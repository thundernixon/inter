# coding=utf8

'''
	FontBakery expects `-Regular` to be included in the postscript name.

	I don't know that it's actually very useful to do so, but this patch adds that.

	USAGE:

	python misc/googlefonts-qa/patch-git-hash-version-names.py build/googlefonts/Inter.var.ttf

	Add --inplace or -i to save the change directly into the same font file.
'''


import os
import argparse
from fontTools.ttLib import TTFont

def getFontNameID(font, ID, platformID=3, platEncID=1):
	name = str(font['name'].getName(ID, platformID, platEncID))
	return name

def setFontNameID(font, ID, newName, platformID=3, platEncID=1, langID=0x409):
	print(f"\n\t• name {ID}:")
	oldName = font['name'].getName(ID, platformID, platEncID)
	print(f"\n\t\t was '{oldName}'")
	font['name'].setName(newName, ID, platformID, platEncID, langID)
	print(f"\n\t\t now '{newName}'")

parser = argparse.ArgumentParser(description='Add "static" suffix to a static font family name.')

parser.add_argument('fonts', nargs="+")

parser.add_argument(
		"-i",
		"--inplace",
		action='store_true',
		help="Edit fonts and save under the same filepath, without an added suffix.",
	)

parser.add_argument(
		"-g",
		"--gitHash",
		help="Provide a git hash to add to names 3 & 5.",
	)

def main():
	args = parser.parse_args()

	for font_path in args.fonts:
		# open font path as a font object, for manipulation
		ttfont = TTFont(font_path)

		name6 = getFontNameID(ttfont, 6)
		# if last character is ":", add the git hash
		if "-Regular" not in name6:
			setFontNameID(ttfont, 6, name6 + "-Regular")
		else: 
			print(f"name 6 looks fine: {name6}")

		# SAVE FONT
		if "-Regular" not in name6:
			if args.inplace:
				print(f"Saving {font_path}")
				ttfont.save(font_path)
			else:
				print(f"Saving {font_path}.fix")
				ttfont.save(font_path + '.fix')


if __name__ == '__main__':
	main()
