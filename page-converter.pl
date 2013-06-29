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
my $outputDir = $processDir ."/output2";
my $pageTemplate = "page-template";
my $bookTemplate = "book-template";

# Detect # of pages and page size of source PDF.
## FOR TESTING ONLY
my $numPages = 6;
my $pageWidth = 1024;
my $pageHeight = 672;

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
	$pageConverter->{"pageList"}[$i]{"cssName"} = $pageBase . "-styles.css";
	$pageConverter->{"pageList"}[$i]{"pageWidth"} = $pageWidth;
	$pageConverter->{"pageList"}[$i]{"pageHeight"} = $pageHeight;
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
		$word =~ /^.*word.*?xMin=\"(?<x>.*?)\".*?yMin=\"(?<y>.*?)\".*?space=\"(?<space>.*?)\".*?fontName=\"[A-Z]*\+(?<font>.*?)\".*?fontSize=\"(?<size>.*?)\".*?CDATA\[(?<text>.*?)\].*$/;
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
# examineHashRef($pageConverter);

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
	copy($pageTemplate . "/css/template-styles.css", $outputDir . "/css/" . $page->{"cssName"}); 
	### Add page background to img folder
	copy($processDir . "/bg-images/" . $page->{"bgName"}, $outputDir . "/img/" . $page->{"bgName"});
	### Milestone 1: Add all text lines into page as simple <p> tags wrapped in <div> tags with increasing numeric ID's.  Absolutey position each line.
	
	# Initialize $html page markup string.
	my $html = "";
	open (HTML, "<:utf8", $outputDir . "/" . $page->{"pageName"});
	while (<HTML>) {$html .= $_}
	close HTML;
	
	# Initialize $css page styles string.
	my $css = "";
	open (CSS, "<:utf8", $outputDir . "/css/" . $page->{"cssName"});
	while (<CSS>) {$css .= $_}
	close CSS;
	
	# Re-open HTML and CSS files for write.
	open (HTML, ">:utf8", $outputDir . "/" . $page->{"pageName"});
	# Link HTML to stylesheet
	$html =~ s/template-styles.css/$page->{"cssName"}/g;
	
	open (CSS, ">:utf8", $outputDir . "/css/" . $page->{"cssName"});	
	# Add correct background image name into css sheet
	$css =~ s/template-bg.jpg/$page->{"bgName"}/g;
	
	# Loop through a blocks to find lines, then all lines to edit HTML and CSS pages.
	my @textBlocks = @{$page->{"content"}};
	my $blockCount = @textBlocks;
	my $i = 0;
	# print $page->{"pageName"} . " has " . $blockCount . " blocks.\n";
	
	while ($i < $blockCount) {
		my $block = $textBlocks[$i];
		# print Dumper $block;
		# print "Block id: $i has $lineCount lines.\n";
		my @textLines = @{$block->{"textlines"}};
		my $lineCount = @textLines;
		my $j = 0;
		
		while ($j < $lineCount) {
			my $line = $textLines[$j];
			# print Dumper $line;
			$html =~ s/(%INSERTBLOCKS%)/<span id="block-$i-line-$j">$line->{"text"}<\/span>\n$1/;
			$css =~ s/(%INSERTBLOCKS%)/#block-$i-line-$j {position: absolute;left: $line->{"x"}px;top: $line->{"y"}px;font-size: $line->{"size"}px;font-family: '$line->{"font"}';}\n$1/;
			$j++;
		}
		$i++;
	}
	# Remove template %INSERTBLOCKS% and print to files.
	$html =~ s/%INSERTBLOCKS%//g;
	$css =~ s/%INSERTBLOCKS%//g;
	print HTML $html;
	close HTML;
	print CSS $css;
	close CSS;
	
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