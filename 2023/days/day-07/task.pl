use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum', 'max', 'min';
use List::MoreUtils  qw(uniq);
use Test::Assertions qw(test);
use Data::Dumper;

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

sub parse_line {
    my ( $hand, $bid ) = split( /\s+/, $_[0] );
    return ( join '-', split( //, $hand ) ) . '|' . $bid;
}

sub get_hand_type {
    my ( $hand_and_bid, $use_joker ) = @_;
    my $hand = ( split( /\|/, $hand_and_bid ) )[0];
    my %counts;
    my $num_unique;
    my $max_count;
    $counts{$_}++ for split( '-', $hand );
    my $num_jokers = exists $counts{'J'} ? $counts{'J'} : 0;
    if ( $use_joker && $num_jokers > 0 ) {
        delete( $counts{'J'} );
        $num_unique = %counts ? scalar( keys %counts )              : 1;
        $max_count  = %counts ? max( values %counts ) + $num_jokers : $num_jokers;
    }
    else {
        $num_unique = scalar( keys %counts );
        $max_count  = max( values %counts );
    }
    if ( $num_unique == 1 ) { return 7; }
    if ( $num_unique == 2 ) { return $max_count eq 3 ? 5 : 6; }
    if ( $num_unique == 3 ) { return $max_count eq 2 ? 3 : 4; }
    if ( $num_unique == 4 ) { return 2; }
    if ( $num_unique == 5 ) { return 1; }
}

sub enumerate_hand {
    my $hand_and_bid = $_[0];
    my %conversion   = %{ $_[1] };
    my ( $hand, $bid ) = split( /\|/, $hand_and_bid );
    $hand = join '-', ( map { exists $conversion{$_} ? $conversion{$_} : $_; } split( '-', $hand ) );
    return $hand . '|' . $bid;
}

sub sort_hands {
    my @hand_and_bid = @{ $_[0] };
    my %conversion   = %{ $_[1] };
    my $use_joker    = $_[2];
    return sort {
        my ( $va, $vb ) = map { enumerate_hand( $_, \%conversion ) } ( $a, $b );
        ( $va, $vb ) = map { ( split( /\|/, $_ ) )[0] } ( $va, $vb );
        my @va = split '-', $va;
        my @vb = split '-', $vb;
        get_hand_type( $a, $use_joker ) <=> get_hand_type( $b, $use_joker )
          || $va[0]                     <=> $vb[0]
          || $va[1]                     <=> $vb[1]
          || $va[2]                     <=> $vb[2]
          || $va[3]                     <=> $vb[3]
          || $va[4]                     <=> $vb[4];
    } @hand_and_bid;
}

sub get_total_winnings {
    my @hand_and_bid = @_;
    return sum(
        map {
            my $bid = ( split( /\|/, $hand_and_bid[$_] ) )[-1];
            ( $_ + 1 ) * $bid;
        } ( 0 .. $#hand_and_bid )
    );
}

# convert input lines
@lines = map { parse_line $_ } @lines;

# Part 1
my %card_values  = ( 'A', 14, 'K', 13, 'Q', 12, 'J', 11, 'T', 10 );
my @hand_and_bid = sort_hands( \@lines, \%card_values, 0 );
say get_total_winnings(@hand_and_bid);

# Part 2
%card_values  = ( 'A', 14, 'K', 13, 'Q', 12, 'T', 10, 'J', 1 );
@hand_and_bid = sort_hands( \@hand_and_bid, \%card_values, 1 );
say join ', ', @hand_and_bid;
say get_total_winnings(@hand_and_bid);

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
