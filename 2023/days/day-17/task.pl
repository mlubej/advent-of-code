use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'min';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @grid = map { [ split( //, $_ ) ] } split "\n", $content;
my ( $h, $w ) = ( scalar @grid, scalar @{ $grid[0] } );

sub is_on_grid {
    my ( $r, $c ) = @_;
    return $c >= 0 && $r >= 0 && $c < $w && $r < $h ? 1 : 0;
}

sub get_grid_element { my ( $r, $c ) = @_; return $grid[$r][$c]; }

my %state_queues_by_cost;
my %seen_cost_by_state;

sub move_and_add_state {
    my ( $cost, $x, $y, $dx, $dy, $distance ) = @_;
    $x += $dx;
    $y += $dy;

    if ( !is_on_grid( $y, $x ) ) { return 0; }

    my $new_cost = $cost + get_grid_element( $y, $x );
    if ( $x eq $w - 1 && $y eq $h - 1 ) {
        say $new_cost;
        return 1;
    }

    my $state = join ',', ( $x, $y, $dx, $dy, $distance );
    if ( !exists $seen_cost_by_state{$state} ) {
        my @old_states = exists $state_queues_by_cost{$new_cost} ? @{ $state_queues_by_cost{$new_cost} } : ();
        $state_queues_by_cost{$new_cost} = [ @old_states, $state ];
        $seen_cost_by_state{$state}      = $new_cost;
    }
    return 0;
}

# Part 1
%state_queues_by_cost = ();
%seen_cost_by_state   = ();
move_and_add_state( 0, 0, 0, 1, 0, 1 );
move_and_add_state( 0, 0, 0, 0, 1, 1 );

while (1) {
    my $current_cost = min keys %state_queues_by_cost;
    my @next_states  = @{ $state_queues_by_cost{$current_cost} };
    delete $state_queues_by_cost{$current_cost};

    my $flag = 0;
    for my $state (@next_states) {
        my ( $x, $y, $dx, $dy, $distance ) = split ',', $state;
        $flag += move_and_add_state( $current_cost, $x, $y, $dy,  -$dx, 1 );
        $flag += move_and_add_state( $current_cost, $x, $y, -$dy, $dx,  1 );

        if ( $distance < 3 ) {
            $flag += move_and_add_state( $current_cost, $x, $y, $dx, $dy, $distance + 1 );
        }
    }

    if ( $flag > 0 ) { last; }
}

# Part 2
undef %state_queues_by_cost;
undef %seen_cost_by_state;

sub move_and_add_state_p2 {
    my ( $cost, $x, $y, $dx, $dy, $distance ) = @_;
    $x += $dx;
    $y += $dy;

    if ( !is_on_grid( $y, $x ) ) { return 0; }

    my $new_cost = $cost + get_grid_element( $y, $x );
    if ( $x eq $w - 1 && $y eq $h - 1 && $distance >= 4 ) {
        say $new_cost;
        return 1;
    }

    my $state = join ',', ( $x, $y, $dx, $dy, $distance );
    if ( !exists $seen_cost_by_state{$state} ) {
        my @old_states = exists $state_queues_by_cost{$new_cost} ? @{ $state_queues_by_cost{$new_cost} } : ();
        $state_queues_by_cost{$new_cost} = [ @old_states, $state ];
        $seen_cost_by_state{$state}      = $new_cost;
    }
    return 0;
}

move_and_add_state_p2( 0, 0, 0, 1, 0, 1 );
move_and_add_state_p2( 0, 0, 0, 0, 1, 1 );

while (1) {
    my $current_cost = min keys %state_queues_by_cost;
    my @next_states  = @{ $state_queues_by_cost{$current_cost} };
    delete $state_queues_by_cost{$current_cost};

    my $flag = 0;
    for my $state (@next_states) {
        my ( $x, $y, $dx, $dy, $distance ) = split ',', $state;

        if ( $distance < 10 ) {
            $flag += move_and_add_state_p2( $current_cost, $x, $y, $dx, $dy, $distance + 1 );
        }
        if ( $distance >= 4 ) {
            $flag += move_and_add_state_p2( $current_cost, $x, $y, $dy,  -$dx, 1 );
            $flag += move_and_add_state_p2( $current_cost, $x, $y, -$dy, $dx,  1 );
        }
    }

    if ( $flag > 0 ) { last; }
}

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
