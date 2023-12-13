use v5.30;
use warnings;
use strict;

use experimental 'smartmatch';
use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

my @grid = map { [ split( //, $_ ) ] } @lines;
my ($start_node) =
  map { $_ . '|' . index( $lines[$_], 'S' ) } ( grep { index( $lines[$_], 'S' ) ne -1 } ( 0 .. $#lines ) );

my %connections = (
    '-' => [ '0|-1', '0|1' ],
    '|' => [ '-1|0', '1|0' ],
    'J' => [ '0|-1', '-1|0' ],
    'L' => [ '0|1',  '-1|0' ],
    '7' => [ '0|-1', '1|0' ],
    'F' => [ '0|1',  '1|0' ],
    'S' => [ '0|-1', '0|1', '-1|0', '1|0' ]
);

sub get_coords       { return split( /\|/, $_[0] ); }
sub get_grid_element { my ( $r, $c ) = get_coords $_[0]; return $grid[$r][$c]; }
sub to_node          { return $_[0] . '|' . $_[1]; }

sub add_nodes {
    my ( $ra, $ca ) = get_coords $_[0];
    my ( $rb, $cb ) = get_coords $_[1];
    my $sign = $_[2];
    return to_node( $ra + $sign * $rb, $ca + $sign * $cb );
}

sub is_on_grid {
    my ( $r, $c ) = split( /\|/, $_[0] );
    my ( $h, $w ) = ( scalar @grid, scalar @{ $grid[0] } );
    return $c >= 0 && $r >= 0 && $c < $w && $r < $h ? 1 : 0;
}

sub connects_backwards {
    my ( $a,  $b )  = @_;
    my ( $rb, $cb ) = get_coords $b;
    my @adj_b =
      map { my ( $r, $c ) = get_coords $_; to_node( $rb + $r, $cb + $c ); } @{ $connections{ get_grid_element $b } };
    return ( $a ~~ @adj_b ) ? 1 : 0;
}

sub get_adjacent {
    my $node       = $_[0];
    my @candidates = map { add_nodes( $node, $_, 1 ); } @{ $connections{ get_grid_element $node } };
    @candidates = grep { is_on_grid($_) && connects_backwards( $node, $_ ) } @candidates;
    return @candidates;
}

sub det {
    my ( $r1, $c1 ) = get_coords( $_[0] );
    my ( $r2, $c2 ) = get_coords( $_[1] );
    return $c1 * $r2 - $c2 * $r1;
}

# Part 1
my ( $start, $end ) = get_adjacent $start_node;
my @path_a = ( $start_node, $start );
my @path_b = ( $start_node, $end );
while (1) {
    push @path_a, ( grep { $_ ne $path_a[-2] } ( get_adjacent $path_a[-1] ) );
    push @path_b, ( grep { $_ ne $path_b[-2] } ( get_adjacent $path_b[-1] ) );
    if ( $path_a[-1] eq $path_b[-1] ) { last; }
}
say scalar(@path_a) - 1;

# Part 2
# https://en.wikipedia.org/wiki/Shoelace_formula
# https://en.wikipedia.org/wiki/Pick%27s_theorem
my @path       = ( @path_a, reverse @path_b[ 0 .. ( $#path_b - 1 ) ] );
my $area_twice = abs sum( map { det( $path[ $_ - 1 ], $path[$_] ) } ( 1 .. $#path ) );
my $boundary   = scalar(@path) - 1;
say( ( $area_twice - $boundary + 2 ) / 2 );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
