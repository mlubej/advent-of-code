use warnings;
use strict;

use v5.30;
use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum';
use experimental 'smartmatch';

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

sub get_matching_numbers {
    my ( $winning_numbers, $loto_numbers ) = @_;
    $winning_numbers = ( split( ':', $winning_numbers ) )[1];
    my @winning = split( ' ', $winning_numbers );
    my @loto    = split( ' ', $loto_numbers );
    return grep { $_ ~~ @winning } @loto;
}

my @points;
my %counts;
foreach my $line (@lines) {
    my @numbers = get_matching_numbers( split( /\|/, $line ) );

    # part 1
    if ( scalar @numbers > 0 ) { push @points, 2**( scalar(@numbers) - 1 ); }

    # part 2
    my ($card) = $line =~ /Card\s+(\d+):/g;
    $counts{$card} += 1;
    for my $idx ( 1 .. scalar @numbers ) { $counts{ $card + $idx } += $counts{$card}; }
}

# Part 1
say sum @points;

# Part 2
say sum values %counts;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
