use Time::HiRes qw( time );
use List::Util 'sum', 'min', 'max', 'reduce';
use feature 'say';
use String::Util qw(trim);

my $begin_time = time();

open( my $file, "<", "input.txt" ) or die "Can't open input file";

%str2int = (
    'one'   => 1,
    'two'   => 2,
    'three' => 3,
    'four'  => 4,
    'five'  => 5,
    'six'   => 6,
    'seven' => 7,
    'eight' => 8,
    'nine'  => 9
);
my $spelled_re     = join( '|', keys %str2int );
my $rev_spelled_re = reverse $spelled_re;

my @calValuesPart1 = ();
my @calValuesPart2 = ();
while ( my $line = <$file> ) {
    my $line = trim $line;

    # part 1 fill
    my @matches = $line =~ /(\d)/g;
    push @calValuesPart1, $matches[0] . $matches[-1];

    # part 2 fill
    my @matches     = $line          =~ /(\d|$spelled_re)/g;
    my @rev_matches = reverse($line) =~ /(\d|$rev_spelled_re)/g;
    push @calValuesPart2,
      ( $str2int{ $matches[0] } // $matches[0] ) . ( $str2int{ reverse $rev_matches[0] } // $rev_matches[0] );
}

close $file;

# Part 1
say sum(@calValuesPart1);

# # Part 2
say sum(@calValuesPart2);

my $end_time = time();
printf( "Elapsed time %.5fs\n", $end_time - $begin_time );
