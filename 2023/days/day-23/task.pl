use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'any', 'first';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @grid = map { [ split( //, $_ ) ] } split "\n", $content;
my ( $h, $w ) = ( scalar @grid, scalar @{ $grid[0] } );
my $start = '1|1';
my $end   = ( $h - 2 ) . '|' . ( $w - 2 );

my %slopes = (
    '>' => '0|1',
    '<' => '0|-1',
    '^' => '-1|0',
    'v' => '1|0'
);

sub get_coords       { return split( /\|/, $_[0] ); }
sub get_grid_element { my ( $r, $c ) = get_coords( $_[0] ); return $grid[$r][$c]; }
sub to_node          { return $_[0] . '|' . $_[1]; }

my %elements;
for my $r ( 1 .. $h - 2 ) {
    for my $c ( 1 .. $w - 2 ) {
        my $node = to_node( $r, $c );
        $elements{$node} = get_grid_element($node);
    }
}

sub add_nodes {
    my ( $ra, $ca ) = get_coords $_[0];
    my ( $rb, $cb ) = get_coords $_[1];
    my $sign = $_[2];
    return to_node( $ra + $sign * $rb, $ca + $sign * $cb );
}

sub is_on_grid {
    my ( $r, $c ) = split( /\|/, $_[0] );
    return $c >= 1 && $r >= 1 && $c < $w - 1 && $r < $h - 1 ? 1 : 0;
}

sub get_adjacent {
    my $node     = shift @_;
    my $slippery = shift @_;

    my @directions;
    my $el = $elements{$node};
    my ( $r, $c ) = get_coords($node);
    if    ( $slippery && exists $slopes{$el} ) { return ( add_nodes( $node, $slopes{$el}, 1 ) ); }
    elsif ( $r eq $h - 2 )                     { @directions = ( '0|1', '-1|0' ) }
    elsif ( $c eq $w - 2 )                     { @directions = ( '0|-1', '1|0' ) }
    else                                       { @directions = ( '0|1', '0|-1', '1|0', '-1|0' ) }
    my @neighbors = map { add_nodes( $node, $_, 1 ) } @directions;
    @neighbors = grep { is_on_grid($_) && $elements{$_} ne '#' } @neighbors;
    return @neighbors;
}

my ( %adjacent1, %adjacent2 );
for my $node ( keys %elements ) {
    if ( $elements{$node} eq '#' ) { next; }
    my @adjacent1 = get_adjacent( $node, 1 );
    $adjacent1{$node} = \@adjacent1;
    my @adjacent2 = get_adjacent( $node, 0 );
    $adjacent2{$node} = \@adjacent2;
}

sub edge_key {
    my @nodes = sort {
        my ( $ra, $ca ) = get_coords $a;
        my ( $rb, $cb ) = get_coords $b;
        $ra <=> $rb || $ca <=> $cb;
    } @_;
    return join '-', @nodes;
}

my ( %edges1, %edges2 );
for my $k ( keys %adjacent1 ) {
    for my $v ( @{ $adjacent1{$k} } ) {
        $edges1{ edge_key( $k, $v ) } = 1;
    }
}
for my $k ( keys %adjacent2 ) {
    for my $v ( @{ $adjacent2{$k} } ) {
        $edges2{ edge_key( $k, $v ) } = 1;
    }
}

sub collapse_tree {
    my %adjacent = %{ shift @_ };
    my %edges    = %{ shift @_ };
    while ( any { scalar @{$_} eq 2 } values %adjacent ) {
        my $node       = first { scalar @{ $adjacent{$_} } eq 2 } keys %adjacent;
        my @edges      = @{ $adjacent{$node} };
        my @left       = grep { $_ ne $node } @{ $adjacent{ $edges[0] } };
        my @right      = grep { $_ ne $node } @{ $adjacent{ $edges[1] } };
        my $left_dist  = $edges{ edge_key( $edges[0], $node ) };
        my $right_dist = $edges{ edge_key( $edges[1], $node ) };
        delete $adjacent{$node};
        delete $edges{ edge_key( $edges[0], $node ) };
        delete $edges{ edge_key( $edges[1], $node ) };
        $adjacent{ $edges[0] }     = [ @left,  $edges[1] ];
        $adjacent{ $edges[1] }     = [ @right, $edges[0] ];
        $edges{ edge_key(@edges) } = $left_dist + $right_dist;
    }
    return \%adjacent, \%edges;
}

my ( $r1, $r2 ) = collapse_tree( \%adjacent1, \%edges1 );
%adjacent1 = %{$r1};
%edges1    = %{$r2};
( $r1, $r2 ) = collapse_tree( \%adjacent2, \%edges2 );
%adjacent2 = %{$r1};
%edges2    = %{$r2};

my ( %adjacent, %edges );

sub dfs {
    my $node    = shift @_;
    my %visited = %{ shift @_ };
    my $end     = shift @_;
    my $length  = shift @_;
    my $longest = shift @_;

    if ( $node eq $end ) {
        if ( $length > $longest ) {
            $longest = $length;
            return $longest;
        }
    }

    $visited{$node} = 1;
    my @adjacent = grep { !exists $visited{$_} } @{ $adjacent{$node} };

    for my $adj (@adjacent) {
        $longest = dfs( $adj, \%visited, $end, $length + $edges{ edge_key( $node, $adj ) }, $longest );
    }
    return $longest;
}

# Part 1
%adjacent = %adjacent1;
%edges    = %edges1;
say dfs( $start, {}, $end, 0, 0 ) + 2;

# Part 2
%adjacent = %adjacent2;
%edges    = %edges2;
say dfs( $start, {}, $end, 0, 0 ) + 2;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
