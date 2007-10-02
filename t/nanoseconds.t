#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use DateTime;
my $base = 'DateTime::Format::Flexible';

use DateTime::Format::Flexible;

{
    my $dt = $base->build( '2007-10-01 13:11:32.741804' );
    is( $dt->datetime.'.'.$dt->nanosecond , '2007-10-01T13:11:32.741804' ,
        'recognize datetimes with milliseconds single digit month' );
}

{
    my $dt = $base->build( '2007-1-01 13:11:32.741804' );
    is( $dt->datetime.'.'.$dt->nanosecond , '2007-01-01T13:11:32.741804' ,
        'recognize datetimes with milliseconds single digit month' );
}

{
    my $dt = $base->build( '2007-1-1 13:11:32.741804' );
    is( $dt->datetime.'.'.$dt->nanosecond , '2007-01-01T13:11:32.741804' ,
        'recognize datetimes with milliseconds single digit month and day' );
}

{
    my $dt = $base->build( '2007-10-1 13:11:32.741804' );
    is( $dt->datetime.'.'.$dt->nanosecond , '2007-10-01T13:11:32.741804' ,
        'recognize datetimes with milliseconds single digit day' );
}

{
    my $dt = $base->build( '2007-10-01T13:11:32.741804' );
    is( $dt->datetime.'.'.$dt->nanosecond , '2007-10-01T13:11:32.741804' ,
        'recognize datetimes with T separating the date and time' );
}
