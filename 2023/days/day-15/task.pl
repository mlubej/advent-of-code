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

sub eval_char {
    my $ch  = $_[0];
    my $val = $_[1];
    $val += ord($ch);
    $val *= 17;
    $val = $val % 256;
    return $val;
}

sub eval_step {
    my @chars = split '', $_[0];
    my $val   = 0;
    while (@chars) {
        my $ch = shift @chars;
        $val = eval_char( $ch, $val );
    }
    return $val;
}

my @steps = split ',', $content;

# Part 1
say sum map { eval_step($_) } @steps;

# Part 2
my %boxes;
for my $step (@steps) {
    my ( $lbl, $op, $fl ) = $step =~ /(\w+)(\-|=)(\d*)/;
    my $lenses = $boxes{ eval_step($lbl) };
    if ( $op eq '=' ) {
        if ( !defined $lenses ) {
            push @{ $boxes{ eval_step($lbl) } }, $lbl . '|' . $fl;
            next;
        }
        my $merged = join ',', @{$lenses};
        if ( !( $merged =~ /$lbl\|/ ) ) {
            push @{ $boxes{ eval_step($lbl) } }, $lbl . '|' . $fl;
        }
        else {
            $merged = $merged =~ s/$lbl\|\d+/$lbl\|$fl/gr;
            my @replaced = split ',', $merged;
            $boxes{ eval_step($lbl) } = \@replaced;
        }
    }
    else {
        my @filtered = grep { !( $_ =~ /$lbl\|/ ) } @{$lenses};
        $boxes{ eval_step($lbl) } = \@filtered;
    }
}

my $f_power = 0;
for my $box ( keys %boxes ) {
    my @lenses = @{ $boxes{$box} };
    for my $idx ( 0 .. $#lenses ) {
        my ( $lbl, $fl ) = split( /\|/, $lenses[$idx] );
        $f_power += ( $box + 1 ) * ( $idx + 1 ) * $fl;
    }
}
say $f_power;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
