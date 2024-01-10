use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );
use List::Util 'sum', 'max', 'min', 'product';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my ( $workflows, $ratings ) = split "\n\n", $content;
my %workflows = map { $_ =~ /(\w+)\{(.*)\}/ } split "\n", $workflows;
my @ratings   = map { $_ =~ /\{(.*)\}/ } split "\n",      $ratings;

sub get_rhash {
    return map { $_ =~ /(.*)\=(.*)/ } split ',', $_[0];
}

sub evaluate {
    my ( $part, $op, $val ) = $_[0] =~ /(\w+)(\>|\<)(\d+)/;
    my %rating = get_rhash( $_[1] );
    if    ( $op eq '>' ) { return $rating{$part} > $val ? 1 : 0; }
    elsif ( $op eq '<' ) { return $rating{$part} < $val ? 1 : 0; }
    say 'oh no';
}

sub filter_part {
    my $rating        = $_[0];
    my $workflow_name = exists $_[1] ? $_[1] : 'in';
    my @conditions    = split ',', $workflows{$workflow_name};
    for my $cp (@conditions) {
        if ( index( $cp, ':' ) eq -1 ) { return ( $cp =~ /^(R|A)$/ ) ? return $cp : filter_part( $rating, $cp ); }
        else {
            my ( $cond, $res ) = split ':', $cp;
            if ( evaluate( $cond, $rating ) ) {
                return ( $res =~ /^(R|A)$/ ) ? return $res : filter_part( $rating, $res );
            }
        }
    }
    say 'oh no';
}

sub calc_metric {
    my %rating = get_rhash( $_[0] );
    return sum( values(%rating) );
}

# Part 1
my @filtered = grep { filter_part($_) eq 'A' } @ratings;
say sum ( map { calc_metric($_) } @filtered );

my @metrics1 = map { filter_part($_) eq 'A' ? calc_metric($_) : 0 } @ratings;

# Part 2
sub Rating::new {
    my $class = shift @_;
    my @x     = @{ shift @_ };
    my @m     = @{ shift @_ };
    my @a     = @{ shift @_ };
    my @s     = @{ shift @_ };
    my $wf    = shift @_;

    return bless {
        x  => \@x,
        m  => \@m,
        a  => \@a,
        s  => \@s,
        wf => $wf,
    }, $class;
}

sub Rating::str {
    my $self = shift @_;
    return sprintf "Rating[x=(%d, %d), m=(%d, %d), a=(%d, %d), s=(%d, %d), wf=\"%s\"]",
      $self->{x}[0],
      $self->{x}[1],
      $self->{m}[0],
      $self->{m}[1],
      $self->{a}[0],
      $self->{a}[1],
      $self->{s}[0],
      $self->{s}[1],
      $self->{wf};
}

sub Rating::combs {
    my $self = shift @_;
    return product( map { my ( $v1, $v2 ) = @{$_}; $v2 - $v1 + 1; }
          ( $self->{x}, $self->{m}, $self->{a}, $self->{s} ) );
}

sub Rating::clone {
    my $self = shift @_;
    return Rating->new( $self->{x}, $self->{m}, $self->{a}, $self->{s}, $self->{wf} );
}

sub process_rating {
    my $rating            = $_[0];
    my @processed_ratings = @{ $_[1] };

    my $workflow_name = $rating->{wf};
    my $exp           = $workflows{$workflow_name};

    my @new_ratings;
    while ( $exp =~ /([^\:]*)\:(\w+)\,(.*)/g ) {
        my ( $cond, $yes, $no )  = ( $1, $2, $3 );
        my ( $part, $op,  $val ) = $cond =~ /(\w+)(\>|\<)(\d+)/;
        my $lwf  = $op eq '<' ? $yes     : $no;
        my $rwf  = $op eq '>' ? $yes     : $no;
        my $lval = $op eq '<' ? $val - 1 : $val;
        my $rval = $op eq '>' ? $val + 1 : $val;

        my @cands = ();
        my ( $x1, $x2 ) = @{ $rating->{$part} };

        if ( $x1 <= $lval ) {
            my $new = $rating->clone;
            $new->{$part}[0] = $x1;
            $new->{$part}[1] = min( $x2, $lval );
            $new->{wf}       = $lwf;
            push @cands, $new;
        }
        if ( $x2 >= $rval ) {
            my $new = $rating->clone;
            $new->{$part}[0] = max( $x1, $rval );
            $new->{$part}[1] = $x2;
            $new->{wf}       = $rwf;
            push @cands, $new;
        }

        my $next;
        for (@cands) {
            if    ( $_->{wf} =~ /^(R)$/ )          { next; }
            elsif ( $_->{wf} =~ /^(A)$/ )          { push @processed_ratings, $_; }
            elsif ( index( $_->{wf}, ':' ) eq -1 ) { push @new_ratings, $_; }
            else                                   { $next = $_; $exp = $_->{wf}; }
        }
        $rating = $next;
    }

    for (@new_ratings) {
        @processed_ratings = process_rating( $_, \@processed_ratings );
    }
    return @processed_ratings;
}

my $rating = Rating->new( [ 1, 4000 ], [ 1, 4000 ], [ 1, 4000 ], [ 1, 4000 ], 'in' );

@ratings = process_rating( $rating, [] );
say sum( map { $_->combs } @ratings );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
