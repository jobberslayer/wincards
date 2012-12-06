use warnings;
use strict;
use LWP::Simple;
use URI::Escape;
use WarLord;

my @img_files = ();

my $width = 390;
my $height = 546;

my $ct = 0;

my $dat_file = $ARGV[0];

my $dat_name = substr($dat_file, 0, rindex($dat_file, '.'));
my @data = ();

open FILE, "<$dat_file";

while (my $line = <FILE>) {
    chomp $line;
    my ($num, $name);
    if ($line =~ /^(\d)(.*)/) {
        $num = $1;
        $name = $2;
    } else {
        $num = 1;
        $name = $line;
    }
    
    my $info = {
        num => $num,
        name => $name, 
    };

    push @data, $info;
}

WarLord::createPDF(\@data, $dat_name);
