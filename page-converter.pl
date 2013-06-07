#!/usr/bin/env perl -w
use strict;

# Set inputs.  PDF name, output directory, template page file, etc.

# Detect # of pages in source PDF.

# Declare page-converter object
## Pagelist w/ background names, XPDF names and page #
### On each page, add a list of flow/blocks objects.  Each flow/blocks has a list of textlines, an X and Y, a width, and a guess at the appropriate class/type of block.
#### Textline needs X, Y, fontsize, space boolean, font-face and text.
## Fontlist w/ all fonts found in all XPDFS
## Error log

# For full PDF
## Extract all fonts to .ttf or .otf files using a command-line utility (TBD)
### Some options: http://stackoverflow.com/questions/1922625/extract-embedded-pdf-fonts-to-an-external-ttf-file-using-some-utility-or-script
###               http://www.pdffontextract.tk/#
###               http://www.wizards.de/~frank/pstill.html
###               ftp://tug.org/texlive/Contents/live/bin/i386-linux/

# For each page in the PDF
## Milestone 1: Rasterize the background of the same page in the background PDF into a png.
## Milestone 2: Detext the page and rasterize the background into a png.
## Compress the background png using pngquanti.
## Run pdftotext, open the output and examine it
### Add all fonts into the font dictionary
### Stuff the page-converter object

# Duplicate book-template into output folder, do initial renaming / set-up.

# Work off the page-converter object
## For each font in the fontlist
### Find matching .ttf file in the extracted-fonts folder.  Provide user input for matching if no clear match.
### Run webify to extract web fonts from .ttf file.  Prompt user about licensing!!!
### Add all necessary font files into output folder.
### Edit fonts.css in output folder, adding a new font-face for each font.
## For each page in pagelist
### Duplicate page-template into output book-template folder, renaming to page-### in all necessary locations.
### Add page background to img folder
### Milestone 1: Add all text lines into page as simple <p> tags wrapped in <div> tags with increasing numeric ID's.  Absolutey position each line.
### Milestone 2: Add all text flows/blocks into page as simple <p> tags wrapped in <div> tags with increasing numeric ID's.  Absolutey position each line.
## Edit shell.html to default to the first page.
## Edit main.js to properly set first and last pages.
## Edit main.css to properly set page container size.
## Edit shell_footer.png and shell_header.png to match page width.
