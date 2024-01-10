use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @lines = split "\n", $content;
my %dirs  = (
    'L' => '0|-1',
    'R' => '0|1',
    'U' => '-1|0',
    'D' => '1|0'
);

sub get_coords { return split( /\|/, $_[0] ); }
sub to_node    { return $_[0] . '|' . $_[1]; }

sub add_nodes {
    my ( $ra, $ca ) = get_coords $_[0];
    my ( $rb, $cb ) = get_coords $_[1];
    my $sign = $_[2];
    return to_node( $ra + $sign * $rb, $ca + $sign * $cb );
}

sub det {
    my ( $r1, $c1 ) = get_coords( $_[0] );
    my ( $r2, $c2 ) = get_coords( $_[1] );
    return $c1 * $r2 - $c2 * $r1;
}

sub boundary {
    my @path     = @_;
    my $boundary = 0;
    for my $pdx ( 1 .. $#path ) {
        my $diff = add_nodes( $path[$pdx], $path[ $pdx - 1 ], -1 );
        $boundary += sum( map { abs $_ } get_coords($diff) );
    }
    return $boundary;
}

sub get_area {
    my @instructions = @_;
    my @path         = ('0|0');
    for my $line (@instructions) {
        my ( $dir, $len ) = $line =~ /([A-Z])\s(\d+)/;
        push @path, add_nodes( $path[-1], $dirs{$dir} =~ s/1/$len/r, 1 );
    }

    my $area_twice = abs sum( map { det( $path[ $_ - 1 ], $path[$_] ) } ( 1 .. $#path ) );
    my $boundary   = boundary(@path);

    return ( $area_twice + $boundary + 2 ) / 2;
}

# Part 1
say get_area(@lines);

# Part 2
my %connections = (
    0 => 'R',
    1 => 'D',
    2 => 'L',
    3 => 'U'
);
my @new_instructions = map {
    my ( $len, $dir ) = $_ =~ /\#(\w{5})(\d{1})/;
    $connections{$dir} . ' ' . hex( '0x' . $len );
} @lines;
say get_area(@new_instructions);

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
