use v5.30;
use warnings;
use strict;

use String::Util qw(trim);
use Time::HiRes  qw( time );

use List::Util 'all';

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";
my $content = do { local $/; <$file> };
close $file;

my @lines = split "\n", $content;

sub get_key {
    return join '-', sort {
        my @a = split( //, $a );
        my @b = split( //, $b );
        ord( $a[0] ) <=> ord( $b[0] ) || ord( $a[1] ) <=> ord( $b[1] ) || ord( $a[2] ) <=> ord( $b[2] )
    } @_;
}

sub extract_edges {
    my @lines = @_;
    my %edges;
    for my $line (@lines) {
        my ( $k, @rest ) = $line =~ /\w+/g;
        for my $r (@rest) {
            $edges{ get_key( $k, $r ) } = 1;
        }
    }
    return %edges;
}

sub tree_from_edges {
    my @edges = @_;
    my %tree;
    for my $edge (@edges) {
        my ( $n1, $n2 ) = split '-', $edge;
        my @old = exists $tree{$n1} ? @{ $tree{$n1} } : ();
        $tree{$n1} = [ @old, $n2 ];
        @old       = exists $tree{$n2} ? @{ $tree{$n2} } : ();
        $tree{$n2} = [ @old, $n1 ];
    }
    return %tree;
}

sub count_connected {
    my %tree    = %{ shift @_ };
    my $node    = ( keys %tree )[0];
    my %visited = ( $node, 1 );
    my @q       = ($node);
    while (@q) {
        my $current = shift @q;
        for my $adj ( @{ $tree{$current} } ) {
            if ( !exists $visited{$adj} ) {
                $visited{$adj} = 1;
                push @q, $adj;
            }
        }
    }
    return keys %visited;
}

sub hot_edges {
    my %tree = %{ shift @_ };
    my %edges;

    for my $node ( keys %tree ) {
        my %visited = ( $node, 1 );
        my @q       = ($node);
        while (@q) {
            my $current = shift @q;
            for my $adj ( @{ $tree{$current} } ) {
                if ( !exists $visited{$adj} ) {
                    $visited{$adj} = 1;
                    $edges{ get_key( $current, $adj ) } += 1;
                    push @q, $adj;
                }
            }
        }
    }
    return %edges;
}

my %edges     = extract_edges(@lines);
my %tree      = tree_from_edges( keys %edges );
my $all_nodes = count_connected( \%tree );

my %hot       = hot_edges( \%tree );
my @to_remove = ( sort { $hot{$a} <=> $hot{$b} } keys %hot )[ -3 .. -1 ];
my %nedges    = %edges;
delete $nedges{ $to_remove[0] };
delete $nedges{ $to_remove[1] };
delete $nedges{ $to_remove[2] };
my %ntree = tree_from_edges( keys %nedges );
my $nodes = count_connected( \%ntree );

# Part 1
say $nodes * ( $all_nodes - $nodes );

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
