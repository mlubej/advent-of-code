use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum', 'max', 'min', 'all';
use Math::Cartesian::Product;

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @bricks = sort {
    my @c  = $a =~ /(\d+)/g;
    my $az = min( $c[2], $c[5] );
    @c = $b =~ /(\d+)/g;
    my $bz = min( $c[2], $c[5] );
    $az <=> $bz
} split "\n", $content;

sub extract_cubes {
    my ( $x1, $y1, $z1, $x2, $y2, $z2 ) = $_[0] =~ /(\d+)/g;
    my @cubes;
    for ( cartesian { @_ } [ $x1 .. $x2 ], [ $y1 .. $y2 ], [ $z1 .. $z2 ] ) {
        push @cubes, $_->[0] . ',' . $_->[1] . ',' . $_->[2];
    }
    return @cubes;
}

sub to_brick {
    my ( $x1, $y1, $z1, $x2, $y2, $z2 ) = @_;
    return ( join ',', ( $x1, $y1, $z1 ) ) . '~' . ( join ',', ( $x2, $y2, $z2 ) );
}

sub lower_brick {
    my ( $x1, $y1, $z1, $x2, $y2, $z2 ) = $_[0] =~ /(\d+)/g;
    my $dist = $_[1];
    return to_brick( $x1, $y1, $z1 - $dist, $x2, $y2, $z2 - $dist );
}

sub drop_brick {
    my $brick   = shift @_;
    my @dropped = @{ shift @_ };
    my %border  = %{ shift @_ };

    my ( $x1, $y1, $z1, $x2, $y2, $z2 ) = $brick =~ /(\d+)/g;
    my $z = min( $z1, $z2 );

    my @drops;
    my @positions;
    for my $x ( $x1 .. $x2 ) {
        for my $y ( $y1 .. $y2 ) {
            my $pos     = $x . ',' . $y;
            my $current = $border{$pos} // 0;
            push @positions, $pos;
            push @drops,     $z - $current - 1;
        }
    }

    my $drop = min(@drops);
    $brick = lower_brick( $brick, $drop );
    if ( $z1 eq $z2 ) { $border{ shift @positions } = $z1 - $drop while (@positions); }
    else              { $border{ $positions[0] } = max( $z1, $z2 ) - $drop; }

    unshift @dropped, $brick;
    return \@dropped, \%border, $drop;

}

sub settle_bricks {
    my @bricks        = @{ shift @_ };
    my $raise_on_drop = shift @_;

    my %border;
    my @dropped;

    while (@bricks) {
        my $brick = shift @bricks;
        my ( $r1, $r2, $drop ) = drop_brick( $brick, \@dropped, \%border );
        if ( $raise_on_drop and $drop > 0 ) { return 1; }
        @dropped = @{$r1};
        %border  = %{$r2};
    }
    if ($raise_on_drop) { return 0; }

    return @dropped;
}

my @dropped = reverse settle_bricks( \@bricks, 0 );

my %tree;
for my $brick (@dropped) {
    my ( $x1, $y1, $z1, $x2, $y2, $z2 ) = $brick =~ /(\d+)/g;
    my @relevant = grep { my ($z) = $_ =~ /,(\d+)~/g; $z eq $z2 + 1 } @dropped;

    my @cubes = extract_cubes($brick);
    if ( $z1 ne $z2 ) { @cubes = ( $cubes[-1] ); }

    my @new;
    for my $r (@relevant) {
        my $found = 0;
        for my $rcube ( extract_cubes($r) ) {
            my ( $rx, $ry, undef ) = $rcube =~ /(\d+)/g;
            for my $cube (@cubes) {
                my ( $x, $y, undef ) = $cube =~ /(\d+)/g;
                if ( $rx eq $x && $ry eq $y ) { $found = 1; last; }
            }
        }
        if ( $found eq 1 ) { push @new, $r }
    }

    $tree{$brick} = \@new;
}

sub is_stable {
    my $brick  = shift @_;
    my %felled = %{ shift @_ };

    for my $k ( keys %tree ) {
        if ( exists $felled{$k} ) { next; }
        for my $v ( @{ $tree{$k} } ) {
            if ( $brick eq $v ) { return 1; }
        }
    }
    return 0;
}

sub count_unstable {
    my $brick = shift @_;
    my %felled;

    my @queue = grep { !is_stable( $_, { $brick => 1 } ) } @{ $tree{$brick} };
    while (@queue) {
        my $next = pop @queue;
        $felled{$next} = 1;
        push @queue, ( grep { !is_stable( $_, \%felled ) } @{ $tree{$next} } );
    }
    return sum( values %felled );
}

my @stable;
my $sum_of_fallables;
for my $brick (@dropped) {
    my $safe           = 1;
    my @supports       = @{ $tree{$brick} };
    my $safe_to_remove = all { is_stable( $_, { $brick => 1 } ) } @supports;
    if ( $safe_to_remove eq 1 ) { push @stable, $brick; }
    else                        { $sum_of_fallables += count_unstable($brick); }
}

# Part 1
say scalar(@stable);

# Part 2
say $sum_of_fallables;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
