use warnings;
use strict;
use LWP::Simple;
use URI::Escape;

my @img_files = ();

my $width = 390;
my $height = 546;

my $ct = 0;

my $dat_file = $ARGV[0];

my $dat_name = substr($dat_file, 0, rindex($dat_file, '.'));

open FILE, "<$dat_file";


my $files = "";
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
    
    if (!-e "cards/$name.jpg") {
        get_card_image($name);    
    }
    
    for (my $i = 0; $i < $num; $i++) {
        $files .= "\"cards/$name.jpg\" ";
    }
    
    $ct++;
}

system("montage -tile 3x3 -geometry ${width}x${height}+25+15 $files $dat_name.pdf");

sub get_card_image {
    my ($name) = @_;
    
    print "Caching $name\n";
    
    my $encoded_name = uri_escape($name);
    my $url = "http://www.temple-of-lore.com/spoiler/popup.php?name=$encoded_name";
    my $html = get($url);
    $html =~ /IMG src="(.*?)"/;
    print $1 . "\n";
    my $img_url = "http://www.temple-of-lore.com/spoiler/$1";
    getstore($img_url, "cards/$name.jpg");
}
