#@_ = localtime;
#@_ = (0,0,0,0,0,0,0,0);
@_ = gmtime(0);
    my $month = ( $_[4] + 10 ) % 12;
    my $year  = $_[5] + 1900 - int( $month / 10 );
    print ($basegm = $_[3] + (
            ( ( 365 * $year )
                + int( $year / 4 )
                    - int( $year / 100 )
                    + int( $year / 400 )
                    + int( ( ( $month * 306 ) + 5 ) / 10 ) )
    ));
print"\n\n";

@_ = localtime;
    my $month = ( $_[4] + 10 ) % 12;
    my $year  = $_[5] + 1900 - int( $month / 10 );
print "$month $year ";
print int( ( ( $month * 306 ) + 5 ) / 10 ) , " \n";
print int( $year / 4 ), " ", int( $year / 100 ), " ", int( $year / 400 ), "\n";
print $year * 365, "\n\n";

    print ($daygm = $_[3] + (
            ( ( 365 * $year )
                + int( $year / 4 )
                    - int( $year / 100 )
                    + int( $year / 400 )
                    + int( ( ( $month * 306 ) + 5 ) / 10 ) - $basegm )
    ));

printf(" \$%04x\n\n", $daygm);

print (($daygm * 86400) + $_[0] + ($_[1] * 60) + ($_[2] * 3600), "\n");
print time;
print "\n";

print ($k = int((($daygm * 86400) + $_[0] + ($_[1] * 60) + ($_[2] * 3600))/30));
printf(" \$%016x\n", $k);
print (((($daygm * 86400) + $_[0] + ($_[1] * 60) + ($_[2] * 3600))%30), "\n");
$w = int(time/30);
printf("%d \$%016x\n", $w, $w);
print "\n";

