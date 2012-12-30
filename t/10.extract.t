#!/usr/bin/env perl
#
use 5.006;
use strict;
use warnings FATAL => 'all';

use Test::More;
use FindBin;
use File::Slurp qw( read_file );

BEGIN {
    use_ok( 'HTML::ExtractMeta' );
}

{
    my $html = read_file( $FindBin::Bin . '/html/techcrunch.html' );

    my $EM = HTML::ExtractMeta->new( html => $html );

    ok( $EM->get_title()       eq "The 10 Best iOS And Android Games Of 2012 | TechCrunch" );
    ok( $EM->get_description() eq "Editor's note: Stephen Danos is the associate editor for the mobile app discovery site Appolicious. This year’s most captivating games either pushe.." );
    ok( $EM->get_url()         eq "http://techcrunch.com/2012/12/29/the-10-best-ios-and-android-games-of-2012/" );
    ok( $EM->get_image_url()   eq "http://tctechcrunch2011.files.wordpress.com/2012/12/app-stores.jpg?w=136" );
    ok( $EM->get_site_name()   eq "TechCrunch" );
    ok( $EM->get_type()        eq "article" );

    is_deeply( $EM->get_keywords(), [] );
}

done_testing();