#!/usr/bin/env perl -w
use strict;
use CAM::PDF;
use Data::Dumper;
use File::Copy::Recursive qw(rcopy);
use File::Copy;
use JSON;

# Set inputs.  PDF name, output directory, template page file, etc.
my $processDir = "sample-book";
my $pdf = $processDir ."/sample-book.pdf";
my $pdfbg = $processDir ."/sample-book-bg.pdf";
my $outputDir = $processDir ."/output";
my $pageTemplate = "page-template";
my $bookTemplate = "book-template";

# Detect # of pages in source PDF.
## FOR TESTING ONLY
my $numPages = 6;

# Declare global page-converter object
my $pageConverter = {};


## Create pagelist w/ background names, XPDF names and page #
### For each page in the PDF
my $i = 0;
while ($i < $numPages) {
	my $pageBase = "page-0" . ($i + 1);
	$pageConverter->{"pageList"}[$i]{"bgName"} = $pageBase . "-bg.jpg";
	$pageConverter->{"pageList"}[$i]{"xpdfName"} = "000" . ($i + 1) . ".xml";
	$pageConverter->{"pageList"}[$i]{"pageName"} = $pageBase . ".html";
	## On each page, add a list of flow/blocks objects.  Each flow/blocks has a list of textlines, an X and Y, a width, and a guess at the appropriate class/type of block.
	## Run pdftotext, open the output and examine it
	open (XPDF, "<:utf8", $processDir . "/extracted-text/" . $pageConverter->{"pageList"}[$i]{"xpdfName"});
	my @words;
	while (<XPDF>){
		chomp;
		if ($_ =~ /<word/) {
			push (@words, $_);
		}
	}
	#### Textline needs X, Y, fontsize, space boolean, font-face and text.
	my $numWords = @words;
	my $j = 0;
	while ($j < $numWords) {
		my $word = $words[$j];
		$word =~ /^.*word.*?xMin=\"(?<x>.*?)\".*?yMin=\"(?<y>.*?)\".*?space=\"(?<space>.*?)\".*?fontName=\"(?<font>.*?)\".*?fontSize=\"(?<size>.*?)\".*?CDATA\[(?<text>.*?)\].*$/;
		my %matches = %+;
		my $matchesRef = {};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"x"} = $matches{"x"};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"y"} = $matches{"y"};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"font"} = $matches{"font"};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"size"} = $matches{"size"};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"space"} = $matches{"space"};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"text"} = $matches{"text"};
		$j++;
	}
	
	## Milestone 1: Rasterize the background of the same page in the background PDF into a png.
	## Milestone 2: Detext the page and rasterize the background into a png.
	## Compress the background jpg using imagemagick.
	### Add all fonts into the font dictionary
	### Stuff the page-converter object

	$i++;
}
## Fontlist w/ all fonts found in all XPDFS
examineHashRef($pageConverter);

# For full PDF
## Extract all fonts to .ttf or .otf files using a command-line utility (TBD)
### Some options: http://stackoverflow.com/questions/1922625/extract-embedded-pdf-fonts-to-an-external-ttf-file-using-some-utility-or-script
###               http://www.pdffontextract.tk/#
###               http://www.wizards.de/~frank/pstill.html
###               ftp://tug.org/texlive/Contents/live/bin/i386-linux/

$pageConverter->{"fontLookup"}{"font1"} = "TimesRoman";
$pageConverter->{"fontLookup"}{"font2"} = "HelveticaOblique";

# Duplicate book-template into output folder, do initial renaming / set-up.
rcopy ($bookTemplate, $outputDir);

# Work off the page-converter object
## For each font in the fontlist
foreach my $font (keys %{$pageConverter->{"fontLookup"}}) {
	### Find matching .ttf file in the extracted-fonts folder.  Provide user input for matching if no clear match.
	# print $pageConverter->{"fontLookup"}{$font} . "\n";
	
	### Run webify to extract web fonts from .ttf file.  Prompt user about licensing!!!
	### Add all necessary font files into output folder.
	### Edit fonts.css in output folder, adding a new font-face for each font.
}
## For each page in pagelist
foreach my $page (@{$pageConverter->{"pageList"}}) {
	### Duplicate page-template into output book-template folder, renaming to page-### in all necessary locations.
	copy($pageTemplate . "/template.html", $outputDir . "/" . $page->{"pageName"}); 
	### Add page background to img folder
	copy($processDir . "/bg-images/" . $page->{"bgName"}, $outputDir . "/img/" . $page->{"bgName"});
	### Milestone 1: Add all text lines into page as simple <p> tags wrapped in <div> tags with increasing numeric ID's.  Absolutey position each line.
	### Milestone 2: Add all text flows/blocks into page as simple <p> tags wrapped in <div> tags with increasing numeric ID's.  Absolutey position each line.
}
## Edit shell.html to default to the first page.
## Edit main.js to properly set first and last pages.
## Edit main.css to properly set page container size.
## Edit shell_footer.png and shell_header.png to match page width.

sub examineHashRef {
	my $hashref = $_[0];
	
	my $JSON = to_json($hashref, {utf8 => 1, pretty => 1});
	open (OUT, ">:utf8", "datamodel.txt");
	print OUT $JSON;
	close OUT;

	print Dumper $hashref;
	
}

sub buildDummyPageConverter {
	my $pageConverter;
	
	$pageConverter->{"pageList"}[0]{"bgName"} = "page-01.jpg";
	$pageConverter->{"pageList"}[0]{"xpdfName"} = "page-01.xml";
	$pageConverter->{"pageList"}[0]{"pageName"} = "page-01.xhtml";
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[0]{"x"} = 50;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[0]{"y"} = 100;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[0]{"font"} = "font1";
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[0]{"size"} = 16;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[0]{"space"} = 1;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[0]{"text"} = "this is a text block";
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[1]{"x"} = 50;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[1]{"y"} = 125;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[1]{"font"} = "font1";
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[1]{"size"} = 16;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[1]{"space"} = 0;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"textlines"}[1]{"text"} = "another chunk of text";
	$pageConverter->{"pageList"}[0]{"content"}[0]{"x"} = 50;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"y"} = 100;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"width"} = 150;
	$pageConverter->{"pageList"}[0]{"content"}[0]{"type"} = "running-text";
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[0]{"x"} = 50;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[0]{"y"} = 100;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[0]{"font"} = "font1";
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[0]{"size"} = 16;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[0]{"space"} = 1;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[0]{"text"} = "this is a text block";
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[1]{"x"} = 50;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[1]{"y"} = 125;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[1]{"font"} = "font1";
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[1]{"size"} = 16;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[1]{"space"} = 0;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"textlines"}[1]{"text"} = "another chunk of text";
	$pageConverter->{"pageList"}[0]{"content"}[1]{"x"} = 50;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"y"} = 100;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"width"} = 150;
	$pageConverter->{"pageList"}[0]{"content"}[1]{"type"} = "running-text";

	$pageConverter->{"pageList"}[1]{"bgName"} = "page-02.jpg";
	$pageConverter->{"pageList"}[1]{"xpdfName"} = "page-02.xml";
	$pageConverter->{"pageList"}[1]{"pageName"} = "page-02.xhtml";
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[0]{"x"} = 50;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[0]{"y"} = 100;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[0]{"font"} = "font1";
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[0]{"size"} = 16;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[0]{"space"} = 1;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[0]{"text"} = "this is a text block";
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[1]{"x"} = 50;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[1]{"y"} = 125;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[1]{"font"} = "font1";
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[1]{"size"} = 16;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[1]{"space"} = 0;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"textlines"}[1]{"text"} = "another chunk of text";
	$pageConverter->{"pageList"}[1]{"content"}[0]{"x"} = 50;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"y"} = 100;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"width"} = 150;
	$pageConverter->{"pageList"}[1]{"content"}[0]{"type"} = "running-text";
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[0]{"x"} = 50;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[0]{"y"} = 100;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[0]{"font"} = "font1";
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[0]{"size"} = 16;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[0]{"space"} = 1;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[0]{"text"} = "this is a text block";
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[1]{"x"} = 50;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[1]{"y"} = 125;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[1]{"font"} = "font1";
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[1]{"size"} = 16;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[1]{"space"} = 0;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"textlines"}[1]{"text"} = "another chunk of text";
	$pageConverter->{"pageList"}[1]{"content"}[1]{"x"} = 50;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"y"} = 100;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"width"} = 150;
	$pageConverter->{"pageList"}[1]{"content"}[1]{"type"} = "running-text";

	$pageConverter->{"fontLookup"}{"font1"} = "TimesRoman";
	$pageConverter->{"fontLookup"}{"font2"} = "HelveticaOblique";
	return $pageConverter;
}
