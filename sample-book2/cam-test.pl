#!/usr/bin/env perl -w
use CAM::PDF;

my $pdf = "merged_r.pdf";
print $pdf ."\n";
my $cam = CAM::PDF->new($pdf);
print $cam->numPages() ."\n";
