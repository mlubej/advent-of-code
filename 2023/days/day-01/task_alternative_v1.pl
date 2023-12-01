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

my @calValuesPart1 = ();
my @calValuesPart2 = ();
while ( my $line = <$file> ) {
    my $line = trim $line;

    # part 1 fill
    my @present_digits = grep { index( $line, $_ ) > -1 } values %str2int;
    my $first          = reduce { index( $line, $a ) < index( $line, $b ) ? $a : $b } @present_digits;
    my $last           = reduce { rindex( $line, $a ) > rindex( $line, $b ) ? $a : $b } @present_digits;
    push @calValuesPart1, $first . $last;

    # part 2 fill
    my @present_matches = grep { index( $line, $_ ) > -1 } keys %str2int, values %str2int;
    my $first           = reduce { index( $line, $a ) < index( $line, $b ) ? $a : $b } @present_matches;
    my $last            = reduce { rindex( $line, $a ) > rindex( $line, $b ) ? $a : $b } @present_matches;
    push @calValuesPart2, ( $str2int{$first} // $first ) . ( $str2int{$last} // $last );

}

close $file;

# Part 1
say sum(@calValuesPart1);

# # Part 2
say sum(@calValuesPart2);

my $end_time = time();
printf( "Elapsed time %.5fs\n", $end_time - $begin_time );
