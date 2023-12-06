use v5.30;
use warnings;
use strict;

use POSIX;
use Time::HiRes qw( time );
use List::Util 'product';

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

# read all content
my $content = do { local $/; <$file> };
my ( $time, $dist ) = split "\n", $content, 2;
my @time = $time =~ /\d+/g;
my @dist = $dist =~ /\d+/g;

my $eps = 0.00000001;

sub solve_quadratic {
    my ( $t, $d ) = @_;
    my $sqD = ( $t**2 - 4 * $d )**0.5;
    my ( $x1, $x2 ) = ( ( $t - $sqD ) / 2, ( $t + $sqD ) / 2 );
    return floor( $x2 - $eps ) - ceil( $x1 + $eps ) + 1;
}

# Part 1
say product ( map { solve_quadratic( $time[$_], $dist[$_] ) } ( 0 .. $#time ) );

# Part 2
say solve_quadratic( join( '', @time ), join( '', @dist ) );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
