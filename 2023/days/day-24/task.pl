use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'max', 'min', 'all';

use Algorithm::GaussianElimination::GF2;
use Math::Matrix;
use Math::BigFloat;

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @lines = split "\n", $content;
my ( $min, $max ) = ( 200000000000000, 400000000000000 );

my $counter = 0;
for my $idx ( 0 .. $#lines ) {
    for my $jdx ( ( $idx + 1 ) .. $#lines ) {
        my ( $xa, $ya, $za, $kxa, $kya, $kza ) = $lines[$idx] =~ /([\d-]+)/g;
        my ( $xb, $yb, $zb, $kxb, $kyb, $kzb ) = $lines[$jdx] =~ /([\d-]+)/g;
        if ( $kya * $kxb - $kxa * $kyb eq 0 ) { next; }

        my $x = ( $kya * $kxb * $xa - $kxa * $kyb * $xb - $kxa * $kxb * $ya + $kxa * $kxb * $yb ) /
          ( $kya * $kxb - $kxa * $kyb );
        my $ta = ( $x - $xa ) / $kxa;
        my $tb = ( $x - $xb ) / $kxb;

        my $y = $ya + $kya * $ta;
        if ( $ta >= 0 && $tb >= 0 && $x >= $min && $x <= $max && $y >= $min && $y <= $max ) { $counter++; }
    }
}

# Part 1
say $counter;

# Part 2
# # line intersection between rock and hail(i)
# r + ti+v = ri + ti *vi
# ti*(vi -v) + (ri - r) = 0
# -ti = (v-vi)/(r-ri)  # for all coordinates

# # example for x and y
# (kx-kxi)/(x-xi) = (kx-kxj)/(x-xj)  # can be expanded

# # left hand is non-linear, but constant between hailstones
# y*kx - x*ky = yi*kx + y*kxi + yi*kxi - xi*ky - x*kyi - xi*kyi

# #equate for two hailstones to get equation
# yi*kx + y*kxi - xi*ky - x*kyi -yj*kx -y*kxj +xj*ky + x*kyj = yj*kxj  - xj*kyj - yi*kxi + xi*kyi
# x*(kyj-kyi) + y*(kxi-kxj) + kx*(yi-yj) + ky(xj-xi) = yj*kxj - yi*kxi + xi*kyi - xj*kyj

# solve for i=0, j=1 and for i=1, j=2

my ( @A, @b, @v );
for my $idx ( 1 .. 2 ) {
    my ( $xi, $yi, $zi, $kxi, $kyi, $kzi ) = $lines[$idx]       =~ /([\d-]+)/g;
    my ( $xj, $yj, $zj, $kxj, $kyj, $kzj ) = $lines[ $idx - 1 ] =~ /([\d-]+)/g;

    @v = ( $kyi - $kyj, $kxj - $kxi, $yj - $yi, $xi - $xj, $yj * $kxj - $yi * $kxi + $xi * $kyi - $xj * $kyj );
    @v = map { Math::BigFloat->new($_); } @v;
    push @A, [ $v[0], $v[1], 0, $v[2], $v[3], 0 ];
    push @b, [ $v[4] ];

    @v = ( $kzi - $kzj, $kxj - $kxi, $zj - $zi, $xi - $xj, $zj * $kxj - $zi * $kxi + $xi * $kzi - $xj * $kzj );
    @v = map { Math::BigFloat->new($_); } @v;
    push @A, [ $v[0], 0, $v[1], $v[2], 0, $v[3] ];
    push @b, [ $v[4] ];

    @v = ( $kyi - $kyj, $kzj - $kzi, $yj - $yi, $zi - $zj, $yj * $kzj - $yi * $kzi + $zi * $kyi - $zj * $kyj );
    @v = map { Math::BigFloat->new($_); } @v;
    push @A, [ 0, $v[1], $v[0], 0, $v[3], $v[2] ];
    push @b, [ $v[4] ];
}

my $A   = Math::Matrix->new(@A);
my $b   = Math::Matrix->new(@b);
my $sol = $A->concat($b)->solve;
say int( $sol->[0][0] ) + int( $sol->[1][0] ) + int( $sol->[2][0] );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
