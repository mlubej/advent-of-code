use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use experimental 'smartmatch';
use List::Util 'reduce';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

my @directions = map { $_ eq 'L' ? 0 : 1 } split //, $lines[0];
my %nodes_map  = map {
    my ( $key, $left, $right ) = $_ =~ /([A-Z]+)/g;
    ( $key, $left . '|' . $right );
} @lines[ 2 .. $#lines ];

sub traverse_map {
    my @directions = @{ $_[0] };
    my %nodes_map  = %{ $_[1] };
    my $node       = $_[2];
    my @end_nodes  = @{ $_[3] };
    my $idx        = 0;
    while ( !( $node ~~ @end_nodes ) ) {
        $node = ( split( /\|/, $nodes_map{$node} ) )[ $directions[ $idx % ( $#directions + 1 ) ] ];
        $idx++;
    }
    return $idx;
}

sub lcm {
    my ( $a,   $b )   = @_;
    my ( $gcd, $tmp ) = ( $a, $b );
    while ($tmp) {
        ( $gcd, $tmp ) = ( $tmp, $gcd % $tmp );
    }
    return $a * ( $b / $gcd );
}

# Part 1
say traverse_map( \@directions, \%nodes_map, 'AAA', ['ZZZ'] );

# Part 2
my @start_nodes = grep { $_ =~ /\w\wA/ ? 1 : 0 } keys %nodes_map;
my @end_nodes   = grep { $_ =~ /\w\wZ/ ? 1 : 0 } keys %nodes_map;
my @steps       = map  { traverse_map( \@directions, \%nodes_map, $_, \@end_nodes ) } @start_nodes;
say reduce { lcm( $a, $b ) } @steps;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
