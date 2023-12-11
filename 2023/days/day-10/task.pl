use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'all';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

my @grid = map { [ split( //, $_ ) ] } @lines;

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

sub graph {
    my @grid = @{ $_[0] };
    my $start_node;
    my %nodes;
    for my $idx ( 0 .. $#grid ) {
        for my $jdx ( 0 .. $#{ $grid[$idx] } ) {
            my $node = to_node( $idx, $jdx );
            if ( get_grid_element($node) eq 'S' ) { $start_node = $node; }
            my @candidates = map { add_nodes( $node, $_, 1 ); } @{ $connections{ get_grid_element $node } };
            @candidates   = grep { is_on_grid($_) && connects_backwards( $node, $_ ) } @candidates;
            $nodes{$node} = \@candidates;
        }
    }
    return $start_node, \%nodes;
}

my ( $start_node, $nodes ) = graph( \@grid );
my %nodes = %{$nodes};
delete $connections{'.'};    # not sure why this is inside ...

# replace 'S'
my @start_connections = map { add_nodes( $_, $start_node, -1 ) } @{ $nodes{$start_node} };
my @start_candidates  = grep {
    all { $_ ~~ @start_connections ? 1 : 0 } @{ $connections{$_} };
} ( keys %connections );
my ( $sr, $sc ) = get_coords($start_node);
$grid[$sr][$sc] = $start_candidates[0];

# Part 1
my ( $start, $end ) = @{ $nodes{$start_node} };
my @path_a = ( $start_node, $start );
my @path_b = ( $start_node, $end );
while (1) {
    my $last_a = $path_a[-2];
    my $last_b = $path_b[-2];
    push @path_a, ( grep { $_ ne $last_a } @{ $nodes{ $path_a[-1] } } );
    push @path_b, ( grep { $_ ne $last_b } @{ $nodes{ $path_b[-1] } } );
    if ( $path_a[-1] eq $path_b[-1] ) { last; }
}
say scalar(@path_a) - 1;

# Part 2
my @temp;
my @path = ( @path_a, @path_b );
for my $idx ( 0 .. $#grid ) { my @dots = (".") x scalar( @{ $grid[$idx] } ); push @temp, \@dots; }
for my $node (@path) { my ( $r, $c ) = get_coords($node); $temp[$r][$c] = get_grid_element($node); }
@grid = @temp;

my $area  = 0;
my @left  = ( 'F', 'L' );
my @right = ( '7', 'J' );
for my $idx ( 0 .. $#grid ) {
    my $last   = '';
    my $inside = 0;
    for my $jdx ( 0 .. $#{ $grid[$idx] } ) {
        my $node = to_node( $idx, $jdx );
        if    ( get_grid_element($node) eq '-' )   { next; }
        elsif ( get_grid_element($node) eq '|' )   { $inside = $inside ? 0 : 1; }
        elsif ( get_grid_element($node) ~~ @left ) { $last   = get_grid_element($node); }
        elsif ( get_grid_element($node) ~~ @right ) {
            if    ( $last eq 'F' && get_grid_element($node) eq 'J' ) { $inside = $inside ? 0 : 1; }
            elsif ( $last eq 'L' && get_grid_element($node) eq '7' ) { $inside = $inside ? 0 : 1; }
            $last = '';
        }
        elsif ( $inside && get_grid_element($node) eq '.' ) { $area++; }
    }
}
say $area;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
