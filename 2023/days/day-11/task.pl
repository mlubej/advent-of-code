use v5.30;
use warnings;
use strict;

use String::Util             qw(trim);
use Time::HiRes              qw( time );
use Algorithm::Combinatorics qw(combinations);

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

my @grid = map { [ split( //, $_ ) ] } @lines;

sub get_coords { return split( /\|/, $_[0] ); }
sub to_node    { return $_[0] . '|' . $_[1]; }

# expand space
my @empty_rows = grep { index( join( '', @{ $grid[$_] } ), '#' ) eq -1 } ( 0 .. $#grid );
my @empty_cols;
for my $c ( 0 .. $#{ $grid[0] } ) {
    my $col = join '', map { $grid[$_][$c] } ( 0 .. $#grid );
    if ( index( $col, '#' ) eq -1 ) { push @empty_cols, $c; }
}

# get galaxies
my @galaxies;
for my $r ( 0 .. $#grid ) {
    for my $c ( 0 .. $#{ $grid[0] } ) {
        if ( $grid[$r][$c] eq '#' ) { push @galaxies, to_node( $r, $c ) }
    }
}

sub get_total {
    my @galaxies         = @{ $_[0] };
    my $expansion_factor = $_[1];
    my $total_base       = 0;
    my $total_expansion  = 0;
    my $iter             = combinations( \@galaxies, 2 );
    while ( my $c = $iter->next ) {
        my ( $g1, $g2 ) = @$c;
        my ( $r1, $c1 ) = get_coords($g1);
        my ( $r2, $c2 ) = get_coords($g2);
        ( $r1, $r2 ) = sort { $a <=> $b } ( $r1, $r2 );
        ( $c1, $c2 ) = sort { $a <=> $b } ( $c1, $c2 );
        my $row_expansions = scalar( grep { $_ > $r1 && $_ < $r2 } (@empty_rows) );
        my $col_expansions = scalar( grep { $_ > $c1 && $_ < $c2 } (@empty_cols) );
        $total_base      += ( $r2 - $r1 ) + ( $c2 - $c1 );
        $total_expansion += ( $row_expansions + $col_expansions );
    }
    return $total_base + $total_expansion * ( $expansion_factor - 1 );
}

# Part 1
say get_total( \@galaxies, 2 );

# Part 2
say get_total( \@galaxies, 1e6 );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
