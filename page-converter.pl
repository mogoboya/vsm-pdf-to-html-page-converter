#!/usr/bin/env perl -w
use strict;
use utf8;
use JSON;
use CAM::PDF;
use XML::LibXML;
use File::Copy;
use File::Copy::Recursive qw(rcopy);
use Data::Dumper;

# Set inputs from command-line arguments.  PDF name, output directory, template page file, etc.
my ($processDir, $pdf, $pdfbg, $outputDir) = readArgs(@ARGV);

my $pageTemplate = "page-template";
my $bookTemplate = "book-template";

# Detect # of pages and page size of source PDF.
my $cam = CAM::PDF->new($pdf);
my $numPages = $cam->numPages();

# Declare global page-converter object
my $pageConverter = {};

## Create pagelist w/ background names, XPDF names and page #
### For each page in the PDF
my $i = 0;
while ($i < $numPages) {
    my $pageWidth = ($cam->getPageDimensions($i+1))[2];
    my $pageHeight = ($cam->getPageDimensions($i+1))[3];
    
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
		$word =~ /^.*word.*?xMin=\"(?<x>.*?)\".*?yMin=\"(?<y>.*?)\".*?yMax=\"(?<yMax>.*?)\".*?base=\"(?<base>.*?)\".*?space=\"(?<space>.*?)\".*?fontName=\"[A-Z]*\+(?<font>.*?)\".*?fontSize=\"(?<size>.*?)\".*?CDATA\[(?<text>.*?)\].*$/;
		my %matches = %+;
		my $matchesRef = {};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"x"} = $matches{"x"};
		$pageConverter->{"pageList"}[$i]{"content"}[$j]{"textlines"}[0]{"y"} = $matches{"y"}-($matches{"yMax"}-$matches{"base"});
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
#examineHashRef($pageConverter);

# For full PDF
## Extract all fonts to .ttf or .otf files using a command-line utility (TBD)
### Some options: http://stackoverflow.com/questions/1922625/extract-embedded-pdf-fonts-to-an-external-ttf-file-using-some-utility-or-script
###               http://www.pdffontextract.tk/#
###               http://www.wizards.de/~frank/pstill.html
###               ftp://tug.org/texlive/Contents/live/bin/i386-linux/

# $pageConverter->{"fontLookup"}{"font1"} = "TimesRoman";
# $pageConverter->{"fontLookup"}{"font2"} = "HelveticaOblique";

rcopy ($processDir . "/fonts", $outputDir . "/fonts");

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

## Open fonts.css, prep to write fontFaces on the fly during page layout.
my $fontFaces = readFileToString($outputDir . "/css/fonts.css");
open (FONTS, ">:utf8", $outputDir . "/css/fonts.css");

## For each page in pagelist
my @pages = @{$pageConverter->{"pageList"}};
my $p = 0;
while ($p < $numPages) {
	my $page = $pages[$p];
	
	### Duplicate page-template into output book-template folder, renaming to page-### in all necessary locations.
	copy($pageTemplate . "/template.html", $outputDir . "/" . $page->{"pageName"}); 
	copy($pageTemplate . "/css/template-styles.css", $outputDir . "/css/" . $page->{"cssName"}); 
	### Add page background to img folder
	copy($processDir . "/bg-images/" . $page->{"bgName"}, $outputDir . "/img/" . $page->{"bgName"});
	### Milestone 1: Add all text lines into page as simple <p> tags wrapped in <div> tags with increasing numeric ID's.  Absolutey position each line.
	
	# Initialize $html page markup string.
	my $html = readFileToString($outputDir . "/" . $page->{"pageName"});
	
	# Initialize $css page styles string.
	my $css = readFileToString($outputDir . "/css/" . $page->{"cssName"});
	
	# Re-open HTML and CSS files for write.
	open (HTML, ">:utf8", $outputDir . "/" . $page->{"pageName"});
	# Link HTML to stylesheet, add in correct background image name
	$html =~ s/template-styles.css/$page->{"cssName"}/g;
	$html =~ s/template-bg.jpg/$page->{"bgName"}/g;
	if ($p == 0) {
		$html =~ s/(<div.*?)prev-page.html(.*\/div>)//g;
	} else {
		$html =~ s/(<div.*?)prev-page.html(.*\/div>)/$1$pages[($p-1)]->{"pageName"}$2/g;
	}
	if ($p == ($numPages - 1)) {
		$html =~ s/(<div.*?)next-page.html(.*\/div>)//g;
	} else {
		$html =~ s/(<div.*?)next-page.html(.*\/div>)/$1$pages[($p+1)]->{"pageName"}$2/g;
	}
		
	open (CSS, ">:utf8", $outputDir . "/css/" . $page->{"cssName"});	

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
			$html =~ s/(%INSERTBLOCKS%)/\t\t<span id="block-$i-line-$j">$line->{"text"}<\/span>\n$1/;
			$css =~ s/(%INSERTBLOCKS%)/#block-$i-line-$j {position: absolute;left: $line->{"x"}px;top: $line->{"y"}px;font-size: $line->{"size"}px;font-family: '$line->{"font"}';}\n$1/;
			unless ($fontFaces =~ /font-family: '$line->{"font"}';/) {
			    $fontFaces =~ s/(%INSERTFONTS%)/\@font-face \{font-family: '$line->{"font"}';src: url('..\/fonts\/$line->{"font"}.eot');src: local('☺'),url('..\/fonts\/$line->{"font"}.woff') format('woff'),url('..\/fonts\/$line->{"font"}.ttf') format('truetype'),url('..\/fonts\/$line->{"font"}.svg\#$line->{"font"}') format('svg');}\n$1/;
			}
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
	$p++;
}

# Close out and write fontFace rules to fonts.css

$fontFaces =~ s/%INSERTFONTS%//g;
print FONTS $fontFaces;
close FONTS;

sub examineHashRef {
	my $hashref = $_[0];
	
	my $JSON = to_json($hashref, {utf8 => 1, pretty => 1});
	open (OUT, ">:utf8", "datamodel.txt");
	print OUT $JSON;
	close OUT;

	print Dumper $hashref;
	
}

sub readFileToString {
    my $file = $_[0];
    
    my $string = "";
	open (FILE, "<:utf8", $file);
	while (<FILE>) {$string .= $_}
	close FILE;
	return $string;
}

sub readArgs {
    my @args = @_;
    
    my $processDir = $args[0];
    my $pdf = $processDir . "/" . $args[1];
    my $pdfbg = $processDir . "/" . $args[2];
    my $outputDir = $processDir . "/" . $args[3];
    
    return ($processDir, $pdf, $pdfbg, $outputDir);
}