use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'max';
use List::MoreUtils qw(uniq);

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @mirrors = map { [ split( //, $_ ) ] } split "\n", $content;

sub get_coords       { return split( /\|/, $_[0] ); }
sub get_grid_element { my ( $r, $c ) = get_coords $_[0]; return $mirrors[$r][$c]; }
sub to_node          { return $_[0] . '|' . $_[1]; }

sub add_nodes {
    my ( $ra, $ca, $da ) = get_coords $_[0];
    my ( $rb, $cb, $db ) = get_coords $_[1];
    my $sign = $_[2];
    return to_node( $ra + $sign * $rb, $ca + $sign * $cb );
}

sub is_on_grid {
    my ( $r, $c, $d ) = get_coords $_[0];
    my ( $h, $w ) = ( scalar @mirrors, scalar @{ $mirrors[0] } );
    return ( $c >= 0 && $r >= 0 && $c < $w && $r < $h ) ? 1 : 0;
}

my %directions = (
    '>' => '0|1',
    '<' => '0|-1',
    'v' => '1|0',
    '^' => '-1|0'
);

sub is_hrz { return ( $_[0] eq '>' ) || ( $_[0] eq '<' ); }
sub is_vrt { return ( $_[0] eq 'v' ) || ( $_[0] eq '^' ); }

sub get_next_moves {
    my $node = $_[0];
    my ( $r, $c, $d ) = get_coords($node);
    my $next = add_nodes( $node, $directions{$d}, 1 );
    if ( !is_on_grid($next) ) { return (); }

    my $m = get_grid_element($next);
    if ( $m eq '.' || ( is_hrz($d) && $m eq '-' ) || ( is_vrt($d) && $m eq '|' ) ) { return ( $next . '|' . $d ); }
    if ( is_hrz($d) && $m eq '|' ) { return ( $next . '|' . '^', $next . '|' . 'v' ); }
    if ( is_vrt($d) && $m eq '-' ) { return ( $next . '|' . '<', $next . '|' . '>' ); }
    if ( $d eq '>' )               { my $dir = $m eq '/' ? '^' : 'v'; return ( $next . '|' . $dir ); }
    if ( $d eq '<' )               { my $dir = $m eq '/' ? 'v' : '^'; return ( $next . '|' . $dir ); }
    if ( $d eq '^' )               { my $dir = $m eq '/' ? '>' : '<'; return ( $next . '|' . $dir ); }
    if ( $d eq 'v' )               { my $dir = $m eq '/' ? '<' : '>'; return ( $next . '|' . $dir ); }
}

sub get_energy {
    my $start = $_[0];
    my %beams;
    my @next = map { get_next_moves($_) } ($start);
    while (@next) {
        for my $n (@next) { $beams{$n} = 1; }
        @next = map { get_next_moves($_) } @next;
        my %next = map { $_, 1 } @next;
        @next = grep { !exists $beams{$_} } keys %next;
    }
    my %res = map { my ( $r, $c, $d ) = get_coords($_); $r . '|' . $c, 1 } keys(%beams);
    return scalar( keys %res );
}

# Part 1
say get_energy('0|-1|>');

# Part 2
my @candidates;
my ( $h, $w ) = ( scalar @mirrors, scalar @{ $mirrors[0] } );
push @candidates, map { '-1|' . $_ . '|v' } ( 0 .. ( $w - 1 ) );
push @candidates, map { $h . '|' . $_ . '|^' } ( 0 .. ( $w - 1 ) );
push @candidates, map { $_ . '|-1|>' } ( 0 .. ( $h - 1 ) );
push @candidates, map { $_ . '|' . $w . '|<' } ( 0 .. ( $h - 1 ) );
say max ( map { get_energy $_ } @candidates );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
