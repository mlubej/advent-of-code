use feature 'say';
use String::Util qw(trim);
use Time::HiRes  qw( time );

use List::Util 'sum', 'all', 'max';

my $begin_time = time();
open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

# configuration
my ( $redmax, $greenmax, $bluemax ) = ( 12, 13, 14 );

my @valid_ids = ();
my @powers    = ();
while ( my $line = <$file> ) {
    my $line = trim $line;

    # extract info
    my ( $id, $sets ) = split( ':', $line );
    my $id     = ( $id =~ /(\d+)/ )[0];
    my @reds   = $sets =~ /(\d+) red/g;
    my @greens = $sets =~ /(\d+) green/g;
    my @blues  = $sets =~ /(\d+) blue/g;

    # part 1
    if ( ( all { $_ <= $redmax } @reds ) && ( all { $_ <= $greenmax } @greens ) && ( all { $_ <= $bluemax } @blues ) ) {
        push @valid_ids, $id;
    }

    # part 2
    push @powers, max(@reds) * max(@greens) * max(@blues);

}

close $file;

# Part 1
say sum @valid_ids;

# Part 2
say sum @powers;

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
