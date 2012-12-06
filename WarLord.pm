package WarLord;

use warnings;
use strict;
use LWP::Simple;
use URI::Escape;

sub createPDF {
    my ($data, $outfile) = @_;    

    my $card_cache = '/home/sites/warlord/bin/wincards/cards';
    my $out_dir = '/home/sites/warlord/bin/wincards';

    my @img_files = ();

    my $width = 390;
    my $height = 546;

    my $ct = 0;

    my $files = "";
    foreach my $rec (@$data) {
        my ($num, $name) = ($$rec{num}, $$rec{name});
    
        if (!-e "/$name.jpg") {
            get_card_image($name);    
        }
    
        for (my $i = 0; $i < $num; $i++) {
            $files .= "\"$card_cache/$name.jpg\" ";
        }
    
        $ct++;
    }

    system("montage -tile 3x3 -geometry ${width}x${height}+25+15 $files $outfile.pdf");
}

sub get_card_image {
    my ($name) = @_;

    my $card_cache = '/home/sites/warlord/bin/wincards/cards';
    
    print STDERR "Caching $name\n";
    
    my $encoded_name = uri_escape($name);
    my $url = "http://www.temple-of-lore.com/spoiler/popup.php?name=$encoded_name";
    my $html = get($url);
    $html =~ /IMG src="(.*?)"/;
    print STDERR $1 . "\n";
    my $img_url = "http://www.temple-of-lore.com/spoiler/$1";
    getstore($img_url, "$card_cache/$name.jpg");
}

1;
