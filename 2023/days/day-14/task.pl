use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $platform = do { local $/; <$file> };
close $file;

sub get_cols {
    my @rows = @_;
    my @cols;
    for my $cdx ( 0 .. ( length( $rows[0] ) - 1 ) ) {
        push @cols, ( join '', ( map { substr( $_, $cdx, 1 ) } @rows ) );
    }
    return @cols;
}

sub sort_rocks {
    my @x       = split //, $_[0];
    my $flip    = $_[1];
    my %weights = ( 'O', 0, '.', $flip ? -1 : 1 );
    return join '', ( sort { $weights{$a} <=> $weights{$b} } @x );
}

sub tilt_line {
    my $line    = $_[0];
    my $flip    = $_[1];
    my $newline = $line;
    while ( $line =~ /([O\.]*)/g ) {
        substr( $newline, $-[0], length($1), sort_rocks( $1, $flip ) );
    }
    return $newline;
}

sub tilt_platform_north {
    my $platform = $_[0];
    my @data     = split "\n", $platform;
    @data = get_cols(@data);
    @data = map { tilt_line $_ } @data;
    @data = get_cols(@data);
    return join "\n", @data;
}

sub tilt_cycle {
    my $platform = $_[0];
    my @data     = split "\n", $platform;
    @data = get_cols(@data);
    @data = map { tilt_line $_ } @data;          # N
    @data = get_cols(@data);
    @data = map { tilt_line $_ } @data;          # W
    @data = get_cols(@data);
    @data = map { tilt_line( $_, 1 ) } @data;    # S
    @data = get_cols(@data);
    @data = map { tilt_line( $_, 1 ) } @data;    # E
    return join "\n", @data;
}

sub calc_load_north {
    my @data = get_cols( split "\n", $_[0] );
    my $load = 0;
    for my $line (@data) {
        $load += ( length($line) - $-[0] ) while ( $line =~ /(O)/g );
    }
    return $load;
}

sub load_after_cycles {
    my $platform = $_[0];
    my $cycles   = $_[1];
    for my $idx ( 1 .. $cycles ) { $platform = tilt_cycle($platform); }
    return calc_load_north($platform);
}

# Part 1
my $new = $platform;
$new = tilt_platform_north($new);
say calc_load_north($new);

# Part 2
my $idx = 0;
my %cycles;
$new = $platform;
$cycles{$new} = 1;
my ( $pstart, $pend, $p );
while (1) {
    $new = tilt_cycle($new);
    $cycles{$new} += 1;
    $idx++;

    if ( $p  && $p eq $new )        { $pend   = $idx; last; }
    if ( !$p && $cycles{$new} > 1 ) { $pstart = $idx; $p = $new; }
}
say load_after_cycles( $platform, $pstart + ( 1000000000 - $pstart ) % ( $pend - $pstart ) );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
