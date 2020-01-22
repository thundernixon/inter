# coding=utf8

'''
	Left alone, the variable and static versions of Inter will clash in font menus. 
	See (https://github.com/google/fonts/pull/1908#issuecomment-575778671)

	This script will update static-family names to include "Static" after the primary family name, to avoid this issue.

	NOTE: this script is simple because "Inter" is such a short name. If a font has longer names, 
	it should instead append an abbreviated suffix, such as "St" or "Stat"
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
		"-f",
		"--famName",
		help="Provide family name to search for & append 'Static' to.",
	)

def main():
	args = parser.parse_args()

	for font_path in args.fonts:
		# open font path as a font object, for manipulation
		ttfont = TTFont(font_path)

		# check for gvar table to see whether it's a variable font
		if 'gvar' not in ttfont.keys():
			fontIsStatic = True
			print("\n-------------------------------------------\nFont is static.")
		else:
			fontIsStatic = False
			print("\n-------------------------------------------\nFont is variable. Not changing names.")
			return

		if args.famName != None:
			famName = args.famName
			print(f"Assuming family name is {famName}. If not, please set arg --famName.")
			
		else:
			if getFontNameID(ttfont, 16) != "":
				famName = getFontNameID(ttfont, 16)
			else:
				famName =  getFontNameID(ttfont, 1)

		# name 1: replace(famName, f"{famName} Static")
		name1 = getFontNameID(ttfont, 1)
		setFontNameID(ttfont, 1, name1.replace(famName, f"{famName} Static"))

		# name 3: replace(famName, f"{famName}Static")
		name3 = getFontNameID(ttfont, 3)
		setFontNameID(ttfont, 3, name3.replace(famName, f"{famName}Static"))

		# name 4: replace(famName, f"{famName} Static")
		name4 = getFontNameID(ttfont, 4)
		setFontNameID(ttfont, 4, name4.replace(famName, f"{famName} Static"))

		# name 6: replace(famName, f"{famName}Static")
		name6 = getFontNameID(ttfont, 6)
		setFontNameID(ttfont, 6, name6.replace(famName, f"{famName}Static"))

		# if name 16: Inter-ExtraLightItalic
		try:
			name16 = getFontNameID(ttfont, 16)
			setFontNameID(ttfont, 16, name16.replace(famName, f"{famName} Static"))
		except:
			print("No name 16 to update.")

		# SAVE FONT
		if args.inplace:
			ttfont.save(font_path)
		else:
			ttfont.save(font_path + '.fix')


if __name__ == '__main__':
	main()
