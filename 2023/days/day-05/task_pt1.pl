use v5.30;
use warnings;
use strict;

use Time::HiRes qw( time );
use List::Util 'min';
use Data::Dumper;

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

# read all content
my $content = do { local $/; <$file> };
my ( $seeds, $conversions ) = split "\n\n", $content, 2;
my @seeds = $seeds =~ /(\d+)/g;

sub extract_conversion_range_list {
    my ($stage) = @_;
    my @range_list;
    foreach my $line ( split "\n", $stage ) {
        if ( $line =~ /map/ ) { next; }
        my ( $dst, $src, $rng ) = $line =~ /(\d+)/g;
        push @range_list, $src . '|' . ( $src + $rng ) . '|' . ( $dst - $src );
    }
    return sort { ( $a =~ /(\d+)/ )[0] <=> ( $b =~ /(\d+)/ )[0] } @range_list;
}

sub get_seed_location {
    my ($seed) = @_;
    foreach my $stage ( split "\n\n", $conversions ) {
        my @conv_range_list = extract_conversion_range_list($stage);
        foreach my $conv_range (@conv_range_list) {
            my ( $start, $end, $offset ) = $conv_range =~ /[-\d]+/g;
            if ( $seed < $start ) { last; }
            if ( $seed >= $start && $seed <= ( $end - 1 ) ) {
                $seed += $offset;
                last;
            }
        }
    }
    return $seed;
}

sub get_location_from_range {
    my ( $start, $rng ) = @_;
    my $nearest = get_seed_location($start);
    for ( $start .. ( $start + $rng - 1 ) ) {
        my $loc = get_seed_location($_);
        if ( $loc < $nearest ) { $nearest = $loc; }
    }
    return $nearest;
}

# Part 1
say min( map { get_seed_location($_) } @seeds );

# Part 2
my @seed_range_list = $seeds =~ /(\d+\s+\d+)/g;
my $nearest         = ( split( /\s+/, $seed_range_list[0] ) )[0];
foreach my $seed_range (@seed_range_list) {
    my $loc = get_location_from_range( split( /\s+/, $seed_range ) );
    if ( $loc < $nearest ) { $nearest = $loc; }
}
say $nearest;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
