use warnings;
use strict;

use v5.30;
use String::Util qw(trim);
use Time::HiRes  qw( time );

use List::Util 'any', 'sum';

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    my $line = trim $line;
    push @lines, $line;
}
close $file;

sub get_symbol {
    my ( $row_idx, $col_idx ) = @_;
    my @row = split //, $lines[$row_idx];
    while ( $row[$col_idx] =~ /([^\d\.])/g ) {
        return $row_idx . '|' . $col_idx . '|' . $1;
    }
    return 0;
}

sub get_adjacent_symbols {
    my ( $num, $row_idx, $col_idx ) = @_;
    my ( $h, $w ) = ( scalar @lines, length $lines[0] );

    my @symbols = ();
    for my $idx ( -1 .. 1 ) {
        for my $jdx ( -1 .. length($num) ) {
            if ( $row_idx + $idx >= 0 && $row_idx + $idx < $h && $col_idx + $jdx >= 0 && $col_idx + $jdx < $w ) {
                push @symbols, get_symbol( $row_idx + $idx, $col_idx + $jdx );
            }
        }
    }
    return grep { $_ } @symbols;
}

my $row_idx = 0;
my @ids;
my %gears;
foreach my $line (@lines) {
    while ( $line =~ /(\d+)/g ) {

        # fill ids
        my @part_numbers = get_adjacent_symbols( $1, $row_idx, $-[1] );
        if ( scalar @part_numbers > 0 ) {
            push @ids, $1;
        }

        # fill hash
        foreach my $part (@part_numbers) {
            my ( $row_idx, $col_idx, $symbol ) = split( /\|/, $part );
            if ( $symbol ne "*" ) { next }
            $gears{$part} = exists $gears{$part} ? $gears{$part} . '|' . $1 : $1;
        }
    }
    $row_idx++;
}

my @gear_ratios;
while ( my ( $key, $value ) = each %gears ) {
    my @gear_list = split( /\|/, $value );
    if ( scalar @gear_list == 2 ) { push @gear_ratios, $gear_list[0] * $gear_list[1]; }
}

# Part 1
say sum @ids;

# Part 2
say sum @gear_ratios;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
