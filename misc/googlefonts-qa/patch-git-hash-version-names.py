# coding=utf8

'''
	Check whether names 3 & 5 have git hashes. If they don't, this adds one. 

	USAGE:

	latestHash=$(git log --author=Rasmus -n 1 --pretty=format:"%h")
	python misc/googlefonts-qa/patch-git-hash-version-names.py build/googlefonts/Inter.var.ttf -g $latestHash

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

		name3 = getFontNameID(ttfont, 3)
		# if last character is ":", add the git hash
		if name3[-1:] is ":":
			setFontNameID(ttfont, 3, name3 + args.gitHash)
		else: 
			print(f"name 3 looks fine: {name3}")

		name5 = getFontNameID(ttfont, 5)

		# if last character is "-", add the git hash
		if name5[-1:] is "-":
			setFontNameID(ttfont, 5, name5 + args.gitHash)
		else: 
			print(f"name 5 looks fine: {name5}")

		# SAVE FONT
		if name3[-1:] is ":" or name5[-1:] is "-":
			if args.inplace:
				print(f"Saving {font_path}")
				ttfont.save(font_path)
			else:
				print(f"Saving {font_path}.fix")
				ttfont.save(font_path + '.fix')


if __name__ == '__main__':
	main()
