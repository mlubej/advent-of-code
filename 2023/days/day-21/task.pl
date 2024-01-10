use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum', 'max';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @grid = map { [ split( //, $_ ) ] } split "\n", $content;
my ( $h, $w ) = ( scalar @grid, scalar @{ $grid[0] } );

sub get_coords { return split( /\|/, shift @_ ); }

sub get_grid_element {
    my ( $r, $c ) = @_;
    return $grid[ $r % $h ][ $c % $w ];
}

sub to_str { return join '|', @_; }

sub add_coords {
    my ( $ra, $ca ) = get_coords( shift @_ );
    my ( $rb, $cb ) = get_coords( shift @_ );
    my $sign = shift @_;
    return to_str( $ra + $sign * $rb, $ca + $sign * $cb );
}

my $start_node;
for my $rdx ( 0 .. $#grid ) {
    for my $cdx ( 0 .. $#{ $grid[$rdx] } ) {
        if ( get_grid_element( $rdx, $cdx ) eq 'S' ) { $start_node = to_str( $rdx, $cdx ); last; }
    }
}

sub get_adjacent {
    my $node      = shift @_;
    my @neighbors = ( '0|1', '0|-1', '1|0', '-1|0' );
    @neighbors = map  { add_coords( $node, $_, 1 ) } @neighbors;
    @neighbors = grep { get_grid_element( get_coords($_) ) ne '#' } @neighbors;
    return @neighbors;
}

sub bfs {
    my $current  = shift @_;
    my $max_dist = shift @_;

    my %tiles;
    my %visited;
    my @queue = ( $start_node, 0 );
    while (@queue) {
        $current = shift @queue;
        my $dist = shift @queue;

        if ( exists $visited{$current} || ( $dist > $max_dist ) ) { next; }

        $tiles{$dist} += 1;
        $visited{$current} = 1;

        my @adjacent = get_adjacent($current);
        for my $adj (@adjacent) {
            push @queue, ( $adj, $dist + 1 );
        }
    }
    return \%tiles;
}

# Part 1
my %tiles = %{ bfs( $start_node, 64 ) };
say sum ( map { $tiles{$_} } ( grep { $_ % 2 eq 0 } keys %tiles ) );

# Part 2
my @x = ( 0, 1, 2 );    # values of n;
my @y;
for my $max_count ( 65, 65 + 131, 65 + 131 * 2 ) {
    %tiles = %{ bfs( $start_node, $max_count ) };
    push @x, $max_count;
    push @y, sum( map { $tiles{$_} } ( grep { ( $_ % 2 ) eq ( $max_count % 2 ) } keys %tiles ) );
}

# solve quadratic equation
my $c = $y[0];                                                                           # y(0) = c
my $d = ( $x[1] * ( $x[1] - $x[2] ) * $x[2] );
my $a = -( -$c * $x[1] + $c * $x[2] - $x[2] * $y[1] + $x[1] * $y[2] ) / $d;
my $b = -( $c * $x[1]**2 - $c * $x[2]**2 + $x[2]**2 * $y[1] - $x[1]**2 * $y[2] ) / $d;

my $n = int( 26501365 / 131 );
say $a * $n**2 + $b * $n + $c;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
