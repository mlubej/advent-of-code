use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'any', 'all', 'product';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my %modules;

sub Module::new {
    my $class   = shift @_;
    my $type    = shift @_;
    my $name    = shift @_;
    my @outputs = @{ shift @_ };

    my %inputs = ();

    return bless {
        type    => $type,
        name    => $name,
        state   => 0,
        inputs  => \%inputs,
        outputs => \@outputs,
    }, $class;
}

sub init_modules {
    my %modules = map {
        my ( $type, $name, $outputs ) = $_ =~ /([\%\&]*)(.*) -> (.*)/;
        my @outputs = split ', ', $outputs;
        $name, Module->new( $type, $name, \@outputs );
    } split( "\n", $content );
    $modules{'button'} = Module->new( '', 'button', ['broadcaster'] );

    foreach my $name ( keys %modules ) {
        my $module = $modules{$name};
        foreach my $out ( @{ $module->{outputs} } ) {
            my %inputs = defined $modules{$out}->{inputs} ? %{ $modules{$out}->{inputs} } : ();
            $inputs{$name} = 0;
            $modules{$out}->{inputs} = \%inputs;
        }
    }
    return %modules;
}

sub io {
    my $src      = $modules{ shift @_ };
    my $dst      = $modules{ shift @_ };
    my $pulse_in = shift @_;

    my $type        = $dst->{type};
    my %inputs      = defined $dst->{inputs}  ? %{ $dst->{inputs} }  : ();
    my @modules_out = defined $dst->{outputs} ? @{ $dst->{outputs} } : ();
    my $pulse_out;

    if ( !$type ) {
        $pulse_out = $pulse_in;
        $dst->{state} = 1 - $pulse_in;
    }
    elsif ( $type eq '%' ) {
        if ( $pulse_in eq 1 ) { return (); }
        $pulse_out = 1 - $dst->{state};
        $dst->{state} = 1 - $dst->{state};
    }
    elsif ( $type eq '&' ) {
        $inputs{ $src->{name} } = $pulse_in;
        $dst->{inputs} = \%inputs;
        my $condition = ( all { $_ eq 1 } values %inputs );
        $pulse_out = $condition ? 0 : 1;
        $dst->{state} = $condition ? 1 : 0;
    }
    else { say 'oh no!'; }

    return map { [ $dst->{name}, $_, $pulse_out ] } @modules_out;

}

sub push_button {
    my ( $lo, $hi ) = ( 0, 0 );
    my @queue = ( [ 'button', 'broadcaster', 0 ] );
    while (@queue) {
        my @elem = @{ shift @queue };
        if   ( $elem[-1] eq 0 ) { $lo++; }
        else                    { $hi++; }
        push @queue, io(@elem);
    }
    return $lo, $hi;
}

# Part 1
my $counter = 1000;
%modules = init_modules();

my ( $lo, $hi ) = ( 0, 0 );
while ( $counter-- ) {
    my ( $l, $h ) = push_button();
    $lo += $l;
    $hi += $h;
}
say $lo * $hi;

# Part 2
sub push_button_v2 {
    my %conjunctions = %{ shift @_ };
    my $counter      = shift @_;
    my @queue        = ( [ 'button', 'broadcaster', 0 ] );
    while (@queue) {
        my @elem = @{ shift @queue };
        push @queue, io(@elem);
        for my $name ( keys %conjunctions ) {
            if ( $conjunctions{$name} eq 0 && all { $_ eq 1 } values( %{ $modules{$name}->{inputs} } ) ) {
                $conjunctions{$name} = $counter;
            }
        }
    }
    return \%conjunctions;
}

my %conjunctions = (
    'xr' => 0,
    'gk' => 0,
    'gx' => 0,
    'tf' => 0
);

$counter = 0;
%modules = init_modules();
while ( any { $_ eq 0 } values %conjunctions ) {
    $counter++;
    %conjunctions = %{ push_button_v2( \%conjunctions, $counter ) };
}

say product ( values %conjunctions );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
