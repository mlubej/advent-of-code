use v5.30;
use warnings;
use strict;

use bigint;
use Test::Assertions qw(test);
use String::Util     qw(trim);
use Time::HiRes      qw( time );
use List::Util 'sum', 'max', 'min';

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

# read all content
my $content = do { local $/; <$file> };
my ( $seeds, $conversions ) = split "\n\n", $content, 2;

sub range_sort {
    return sort { ( $a =~ /(\d+)/ )[0] <=> ( $b =~ /(\d+)/ )[0] } @_;
}

# {
#     my @observed = range_sort( '1|2', '5|10', '3|4' );
#     my @expected = ( '1|2', '3|4', '5|10' );
#     ASSERT( EQUAL( \@observed, \@expected ) );
# }

sub extract_conversion_range_list {
    my ($stage) = @_;
    my @range_list;
    foreach my $line ( split "\n", $stage ) {
        if ( $line =~ /map/ ) { next; }
        my ( $dst, $src, $rng ) = $line =~ /(\d+)/g;
        push @range_list, $src . '|' . ( $src + $rng ) . '|' . ( $dst - $src );
    }
    return range_sort @range_list;
}

# {
#     my @observed = extract_conversion_range_list("0 15 37\n37 52 2\n39 0 15");
#     my @expected = ( '0|15|39', '15|52|-15', '52|54|-15' );
#     ASSERT( EQUAL( \@observed, \@expected ) );
# }

sub range_offset {
    my ($entry) = @_;
    my ( $start, $end, $offset ) = split( /\|/, $entry );
    return join '|', ( map { $_ + $offset } ( $start, $end ) );
}

# {
#     ASSERT( range_offset('1|10|3') eq '4|13' );
#     ASSERT( range_offset('-1|5|3') eq '2|8' );
#     ASSERT( range_offset('2|3|-2') eq '0|1' );
# }

sub range_intersection {
    my ( $s1, $s2 )          = @_;
    my ( $x1, $x2 )          = split( /\|/, $s1 );
    my ( $y1, $y2, $offset ) = split( /\|/, $s2 );
    my ( $r1, $r2 )          = ( max( $x1, $y1 ), min( $x2, $y2 ) );
    return $r1 < $r2 ? $r1 . '|' . $r2 . '|' . $offset : 0;
}

# {
#     ASSERT( range_intersection( '5|10', '6|7|0' ) eq '6|7|0' );
#     ASSERT( range_intersection( '5|10', '6|15|1' ) eq '6|10|1' );
#     ASSERT( range_intersection( '5|10', '3|15|2' ) eq '5|10|2' );
#     ASSERT( range_intersection( '5|10', '2|7|3' ) eq '5|7|3' );
#     ASSERT( range_intersection( '5|10', '10|15|4' ) eq 0 );
#     ASSERT( range_intersection( '5|10', '12|15|5' ) eq 0 );
# }

sub range_gaps {
    my ( $range, @intersections ) = @_;
    my @gaps = ();
    my ( $r1, $r2 ) = split( /\|/, $range );                # range
    my ( $s1, $s2 ) = split( /\|/, $intersections[0] );     # first intersection
    my ( $e1, $e2 ) = split( /\|/, $intersections[-1] );    # last intersection
    if ( $r1 < $s1 ) { push @gaps, $r1 . '|' . $s1; }
    if ( $r2 > $e2 ) { push @gaps, $e2 . '|' . $r2; }
    for ( 0 .. ( $#intersections - 1 ) ) {
        my $current_end = ( split( /\|/, $intersections[$_] ) )[1];
        my $next_start  = ( split( /\|/, $intersections[ $_ + 1 ] ) )[0];
        push @gaps, $current_end . '|' . $next_start;
    }

    return range_sort @gaps;
}

# {
# say join ', ', range_gaps( '1|10', ( '2|3', '4|6', '8|9' ) );
# my @diff = range_difference( '1|10', ('1|5|0') );
# ASSERT( EQUAL( \@diff, [ '5|6', '7|10' ] ) );÷
# my @diff = range_difference( '5|10', '2|15|0' );
# ASSERT( EQUAL( \@diff, [] ) );
# my @diff = range_difference( '5|10', '8|15|0' );
# ASSERT( EQUAL( \@diff, ['5|8'] ) );
# }

sub range_union {
    my @range_list     = range_sort @_;
    my @new_range_list = ( $range_list[0] );
    foreach my $current ( @range_list[ 1 .. $#range_list ] ) {
        my ( $cs, $ce ) = split( /\|/, $current );
        my ( $ps, $pe ) = split( /\|/, $new_range_list[-1] );
        if ( $cs <= $pe ) { $new_range_list[-1] = $ps . '|' . max( $ce, $pe ); }
        else              { push @new_range_list, $cs . '|' . $ce; }
    }
    return range_sort @new_range_list;
}

# {
#     my @observed = range_union( '6|10', '1|5', '9|15', '25|30', '15|20' );
#     my @expected = ( '1|5', '6|20', '25|30' );
#     ASSERT( EQUAL( \@observed, \@expected ) );
# }

sub get_seed_locations {
    my @range_list = @_;
    foreach my $stage ( split "\n\n", $conversions ) {
        my @new_range_list        = ();
        my @conversion_range_list = extract_conversion_range_list($stage);
        foreach my $range (@range_list) {
            my @intersections = grep { $_ } ( map { range_intersection( $range, $_ ); } @conversion_range_list );
            push @new_range_list, ( map { range_offset $_ } @intersections );
            my @unconverted = @intersections ? range_gaps( $range, range_union(@intersections) ) : ($range);
            push @new_range_list, @unconverted;
        }
        @range_list = range_union(@new_range_list);
    }
    return min( map { ( $_ =~ /\d+/g )[0]; } @range_list );
}

# Part 1
my @seeds          = $seeds =~ /(\d+)/g;
my @seed_range_pt1 = map { $_ . '|' . ( $_ + 1 ) } @seeds;
say get_seed_locations(@seed_range_pt1);

# Part 2
my @seed_range_list = $seeds =~ /(\d+\s+\d+)/g;
@seed_range_list = map {
    my ( $start, $rng ) = $_ =~ /(\d+)/g;
    $start . '|' . ( $start + $rng );
} @seed_range_list;
@seed_range_list = range_union @seed_range_list;
say get_seed_locations(@seed_range_list);

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
