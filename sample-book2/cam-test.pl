#!/usr/bin/env perl -w
use CAM::PDF;

my $pdf = "C:/VPGProjects/projects/vsm-pdf-to-html-page-converter/sample-book2/merged_r.pdf";
print $pdf;
system("pause");
my $cam = CAM::PDF->new($pdf);