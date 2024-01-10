use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum';
use Memoize;

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

my @lines = ();
while ( my $line = <$file> ) {
    push @lines, trim $line;
}
close $file;

# https://www.reddit.com/r/adventofcode/comments/18hbbxe/2023_day_12python_stepbystep_tutorial_with_bonus/
# https://github.com/Domyy95/Challenges/blob/master/2023-12-Advent-of-code/12.py
memoize('calc');

sub calc {
    my ( $record, $groups ) = @_;
    my @groups = split ',', $groups;
    my $out    = 0;

    if ( scalar(@groups) eq 0 ) {    # no more groups
        if   ( !$record || !( $record =~ '#' ) ) { return 1; }    # if no more #, it's fine
        else                                     { return 0; }
    }
    elsif ( !$record ) { return 0; }                              # no more record, but groups still present

    my $next_character = substr( $record, 0, 1 );
    my $group_size     = $groups[0];
    if ( $next_character =~ /\?|\./ ) { $out += calc( substr( $record, 1 ), $groups ); }    # skip separator
    if ( $next_character =~ /\?|\#/ ) {                                                     # process hashtag
        if ( !( substr( $record, 0, $groups[0] ) =~ /\./ ) ) {
            if    ( length($record) eq $groups[0] && scalar @groups eq 1 ) { $out += 1; }          # end of group
            elsif ( length($record) > $groups[0] && substr( $record, $group_size, 1 ) ne "#" ) {

                # continue if next is separtor, which can be skipped
                $out += calc( substr( $record, $group_size + 1 ), join( ',', @groups[ 1 .. $#groups ] ) );
            }
        }
    }
    return $out;
}

# Part 1
say sum map { calc( split( ' ', $_ ) ); } @lines;

# Part 2
@lines = map {
    my ( $springs, $groups ) = split( /\s+/, $_ );
    $springs = join '?', ($springs) x 5;
    $groups  = join ',', ($groups) x 5;
    join ' ', ( $springs, $groups );
} @lines;

say sum map { calc( split( ' ', $_ ) ); } @lines;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
