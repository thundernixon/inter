# Notes on QA for publication through Google Fonts

## Issues raised by Fontbakery

<details>
<summary>🔥<b>FAIL:</b> Checking file is named canonically.</summary>

* [com.google.fonts/check/001](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/001)
* 🔥**FAIL** Style name used in "Inter-Regular.ttf" is not canonical. You should rebuild the font using any of the following style names: "Thin", "ExtraLight", "Light", "Regular", "Medium", "SemiBold", "Bold", "ExtraBold", "Black", "Thin Italic", "ExtraLight Italic", "Light Italic", "Italic", "Medium Italic", "SemiBold Italic", "Bold Italic", "ExtraBold Italic", "Black Italic".

</details>

- this appears to be an invalid check for now
- [ ] check on canonical naming for VFs

<details>
<summary>🔥<b>FAIL:</b> Check copyright namerecords match license file.</summary>

* [com.google.fonts/check/029](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/029)
* 🔥**FAIL** License file OFL.txt exists but NameID 13 (LICENSE DESCRIPTION) value on platform 3 (WINDOWS) is not specified for that. Value was: "OFL 1.1 (SIL Open Font License, Version 1.1)" Must be changed to "This Font Software is licensed under the SIL Open Font License, Version 1.1. This license is available with a FAQ at: http://scripts.sil.org/OFL" [code: wrong]

</details>

<details>
<summary>:fire: <b>FAIL:</b> Copyright notices match canonical pattern?</summary>

* [com.google.fonts/check/102](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/102)
* :fire: **FAIL** METADATA.pb: Copyright notices should match a pattern similar to: 'Copyright 2017 The Familyname Project Authors (git url)'
But instead we have got: 'Copyright 2017-2019 the Inter project authors (https://github.com/rsms/inter)'
* :fire: **FAIL** Name table entry: Copyright notices should match a pattern similar to: 'Copyright 2017 The Familyname Project Authors (git url)'
But instead we have got: 'Copyright 2017-2019 the Inter project authors (https://github.com/rsms/inter)'

</details>

- [x] rebuild and check again
- This check is being overly strict. The copyright is now extremely close.

<details>
<summary>🔥<b>FAIL:</b> Version format is correct in 'name' table?</summary>

* [com.google.fonts/check/055](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/055)
* 🔥**FAIL** The NameID.VERSION_STRING (nameID=5) value must follow the pattern "Version X.Y" with X.Y between 1.000 and 9.999. Current version string is: "3.4;6e0206421" [code: bad-version-strings]

</details>

- [ ] file issue to find out how Rasmus is setting version numbers; make them the canonical format unless this check is unfairly strict

<details>
<summary>🔥<b>FAIL:</b> Is 'gasp' table set to optimize rendering?</summary>

* [com.google.fonts/check/062](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/062)
* 🔥**FAIL** Font is missing the 'gasp' table. Try exporting the font with autohinting enabled.

</details>

- [ ] use gftools fix-gasp


<details>
<summary>:fire: <b>FAIL:</b> Copyright notices match canonical pattern?</summary>

* [com.google.fonts/check/102](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/102)
* :fire: **FAIL** METADATA.pb: Copyright notices should match a pattern similar to: 'Copyright 2017 The Familyname Project Authors (git url)'
But instead we have got: 'Copyright 2017-2019 the Inter project authors (https://github.com/rsms/inter)'
* :fire: **FAIL** Name table entry: Copyright notices should match a pattern similar to: 'Copyright 2017 The Familyname Project Authors (git url)'
But instead we have got: 'Copyright 2017-2019 the Inter project authors (https://github.com/rsms/inter)'

</details>

- [x] add git repo URL
- [x] check again
- [ ] file fontbakery issue – this check seems overly-strict

<details>
<summary>🔥<b>FAIL:</b> Stricter unitsPerEm criteria for Google Fonts. </summary>

* [com.google.fonts/check/116](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/116)
* 🔥**FAIL** Font em size (unitsPerEm) is 2816. If possible, please consider using 1000 or even 2000 (which is ideal for Variable Fonts). The acceptable values for unitsPerEm, though, are: [16, 32, 64, 128, 256, 500, 512, 1000, 1024, 2000, 2048].

</details>

<details>
<summary>🚨<b>WARN:</b> Checking unitsPerEm value is reasonable.</summary>

* [com.google.fonts/check/043](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/043)
* 🚨**WARN** In order to optimize performance on some legacy renderers, the value of unitsPerEm at the head table should idealy be a power of between 16 to 16384. And values of 1000 and 2000 are also common and may be just fine as well. But we got upm=2816 instead.

</details>

- [ ] find UPM requirements in the OpenType spec; ask Marc if we should change it in Inter

<details>
<summary>🔥<b>FAIL:</b> Checking OS/2 usWinAscent & usWinDescent.</summary>

* [com.google.fonts/check/040](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/040)
* 🔥**FAIL** OS/2.usWinAscent value should be equal or greater than 3072, but got 2708 instead [code: ascent]
* 🔥**FAIL** OS/2.usWinDescent value should be equal or greater than 1084, but got 660 instead [code: descent]

</details>

- [ ] set vmetrics according to latest specs, then check again

<details>
<summary>🔥<b>FAIL:</b> Font enables smart dropout control in "prep" table instructions?</summary>

* [com.google.fonts/check/072](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/072)
* 🔥**FAIL** 'prep' table does not contain TrueType  instructions enabling smart dropout control. To fix, export the font with autohinting enabled, or run ttfautohint on the font, or run the  `gftools fix-nonhinting` script.

</details>

- [ ] run the  `gftools fix-nonhinting` script

<details>
<summary>🔥<b>FAIL:</b> Checking font version fields (head and name table).</summary>

* [com.google.fonts/check/044](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/044)
* 🔥**FAIL** head version is ('3', '004'), name version string for platform 3, encoding 1, is ('3', '400') [code: mismatch]

</details>

- [ ] find out how Rasmus is setting version numbers; make them the same

<details>
<summary>🔥<b>FAIL:</b> Does the font have a DSIG table?</summary>

* [com.google.fonts/check/045](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/045)
* 🔥**FAIL** This font lacks a digital signature (DSIG table). Some applications may require one (even if only a dummy placeholder) in order to work properly.

</details>

- [ ] set up gftools fix-dsig

<details>
<summary>🚨<b>WARN:</b> Checking OS/2 achVendID.</summary>

* [com.google.fonts/check/018](https://github.com/googlefonts/fontbakery/search?q=com.google.fonts/check/018)
* 🚨**WARN** OS/2 VendorID value 'RSMS' is not a known registered id. You should set it to your own 4 character code, and register that code with Microsoft at https://www.microsoft.com/typography/links/vendorlist.aspx [code: unknown]

</details>

- [ ] get Rasmus to register a vendor ID


