use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use experimental 'smartmatch';
use List::Util 'sum', 'max', 'all', 'reduce';

# use List::MoreUtils  qw(uniq);
use Test::Assertions qw(test);
use Data::Dumper;

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

sub extrapolate {
    my @numbers  = split /\s+/, $_[0];
    my $forward  = $_[1];
    my $depth    = 0;
    my $edge_idx = $forward eq 1 ? -1 : 0;
    my @edge     = ( $numbers[$edge_idx] );
    while ( !( all { $_ eq 0 } @numbers ) ) {
        @numbers = map { $numbers[$_] - $numbers[ $_ - 1 ] } ( 1 .. $#numbers );
        push @edge, $numbers[$edge_idx];
        $depth++;
    }
    my $prediction = 0;
    if ($forward) { $prediction += pop(@edge) while (@edge) }
    else          { $prediction = pop(@edge) - $prediction while (@edge) }
    return $prediction;
}

# Part 1
say sum map { extrapolate( $_, 1 ) } @lines;

# Part 2
say sum map { extrapolate( $_, 0 ) } @lines;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
