use v5.30;
use warnings;
use strict;

use bigint;
use Test::Assertions qw(test);
use String::Util     qw(trim);
use Time::HiRes      qw( time );
use List::Util 'sum', 'max', 'min';
use Data::Dumper;

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

# read all content
my $content = do { local $/; <$file> };
my ( $time, $dist ) = split "\n", $content, 2;
my @time = $time =~ /\d+/g;
my @dist = $dist =~ /\d+/g;

sub get_distances {
    my ( $t, $d ) = @_;
    return grep { $_ > $d } ( map { $_ * ( $t - $_ ) } ( 1 .. $t ) );
}

my $prod = 1;
for my $idx ( 0 .. $#time ) {
    $prod *= scalar get_distances( $time[$idx], $dist[$idx] );
}

# Part 1
say $prod;

# Part 2
say scalar get_distances( join( '', @time ), join( '', @dist ) );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
