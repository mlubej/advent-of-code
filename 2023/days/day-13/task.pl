use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum', 'min';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @patterns = split "\n\n", $content;

sub get_rows { return split "\n", $_[0]; }

sub get_cols {
    my $pattern = $_[0];
    my @cols;
    my @grid;
    my @rows = get_rows($pattern);
    for my $cdx ( 0 .. ( length( $rows[0] ) - 1 ) ) {
        my $col = '';
        for my $row (@rows) {
            $col .= substr( $row, $cdx, 1 );
        }
        push @cols, $col;
    }
    return @cols;
}

sub find_candidates {
    my $dir   = $_[1];
    my @lines = $dir eq 0 ? get_rows( $_[0] ) : get_cols( $_[0] );
    my @cands;
    for my $idx ( 1 .. $#lines ) {
        if ( $lines[$idx] eq $lines[ $idx - 1 ] ) { push @cands, $idx - 1; }
    }
    return @cands;
}

sub check_candidates {
    my $dir    = $_[1];
    my $ignore = $_[2];
    my @lines  = $dir eq 0 ? get_rows( $_[0] ) : get_cols( $_[0] );
    my @cands  = find_candidates( $_[0], $dir );
    if ( defined $ignore ) {
        @cands = grep { $_ ne $ignore } @cands;
    }
    for my $cand (@cands) {
        my @p1    = reverse @lines[ 0 .. $cand ];
        my @p2    = @lines[ ( $cand + 1 ) .. $#lines ];
        my $m     = min( scalar @p1, scalar @p2 ) - 1;
        my $is_ok = 1;
        for my $idx ( 0 .. $m ) {
            if ( $p1[$idx] ne $p2[$idx] ) { $is_ok = 0; last; }
        }
        if ($is_ok) { return $cand; }
    }
    return -1;
}

sub check_candidates_pt1 {
    my $pattern = $_[0];
    my $rc      = check_candidates( $pattern, 0 );
    my $cc      = check_candidates( $pattern, 1 );
    if ( $rc ne -1 ) { return ( $rc + 1 ) * 100; }
    return $cc + 1;
}

sub check_candidates_pt2 {
    my $pattern = $_[0];
    my $old_rc  = check_candidates( $pattern, 0 );
    my $old_cc  = check_candidates( $pattern, 1 );
    my @rows    = get_rows($pattern);
    for my $rdx ( 0 .. $#rows ) {
        for my $cdx ( 0 .. ( length( $rows[0] ) - 1 ) ) {
            my @new_rows = @rows;
            my $char     = substr( $rows[$rdx], $cdx, 1 );
            substr( $new_rows[$rdx], $cdx, 1, $char eq '.' ? '#' : '.' );
            my $new_pattern = join "\n", @new_rows;
            my $rc          = check_candidates( $new_pattern, 0, $old_rc );
            my $cc          = check_candidates( $new_pattern, 1, $old_cc );
            if ( $rc ne -1 && $rc ne $old_rc ) { return ( $rc + 1 ) * 100; }
            if ( $cc ne -1 && $cc ne $old_cc ) { return ( $cc + 1 ); }
        }
    }
}

# Part 1
say sum ( map { check_candidates_pt1($_) } @patterns );

# Part 2
say sum ( map { check_candidates_pt2($_) } @patterns );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
