use Time::HiRes qw( time );
use List::Util 'sum';
use feature 'say';
use String::Util qw(trim);

my $begin_time = time();

open( my $file, "<", $ARGV[0] ) or die "Can't open input file";

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

my @calValuesPart1 = ();
my @calValuesPart2 = ();
while ( my $line = <$file> ) {
    my $line = trim $line;

    # part 1 fill
    $line =~ /(\d)/;
    my $first = $1;
    reverse($line) =~ /(\d)/;
    my $last = $1;
    push @calValuesPart1, $first . $last;

    # part 2 fill
    my $word_number_match = join( '|', keys(%str2int) );
    $line =~ /(\d|$word_number_match)/;
    my $first                     = exists( $str2int{$1} ) ? $str2int{$1} : $1;
    my $reverse_word_number_match = reverse($word_number_match);
    reverse($line) =~ /(\d|$reverse_word_number_match)/;
    my $last = exists( $str2int{ reverse($1) } ) ? $str2int{ reverse($1) } : $1;
    push @calValuesPart2, $first . $last;

}

close $file;

# Part 1
say sum(@calValuesPart1);

# Part 2
say sum(@calValuesPart2);

my $end_time = time();
printf( "Elapsed time %.8fs\n", $end_time - $begin_time );
