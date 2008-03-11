#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2865;

use DateTime;
my $base = 'DateTime::Format::Flexible';

use_ok( $base);

sub test_parse_date
{
    my ( $given , $wanted ) = @_;
    my $dt = $base->parse_datetime( $given );
    is( $dt->datetime , $wanted , "$given => $wanted" );
    return $dt;
}

{
    my $now = DateTime->now;
    my $curr_year = $now->year;
    my $today = $now->ymd;

    # bare, no seperators
    test_parse_date( '20060518T051326' => '2006-05-18T05:13:26' );
    test_parse_date( '20060518T0513'   => '2006-05-18T05:13:00' );
    test_parse_date( '20060518T05'     => '2006-05-18T05:00:00' );
    test_parse_date( '20060518'        => '2006-05-18T00:00:00' );
    test_parse_date( '200605'          => '2006-05-01T00:00:00' );
    test_variations( '05-18-2006'      => '2006-05-18T00:00:00' );
    test_variations( '05-8-2006'       => '2006-05-08T00:00:00' );
    test_variations( '5-8-2006'        => '2006-05-08T00:00:00' );
    test_variations( '5-08-2006'       => '2006-05-08T00:00:00' );
    test_variations( '05-18-06'        => '2006-05-18T00:00:00' );
    test_variations( '5-18-06'         => '2006-05-18T00:00:00' );
    test_variations( '05-8-06'         => '2006-05-08T00:00:00' );
    test_variations( '5-8-06'          => '2006-05-08T00:00:00' );
    test_variations( '2006/05/18'      => '2006-05-18T00:00:00' );
    test_variations( '2006/5/18'       => '2006-05-18T00:00:00' );
    test_variations( '2006/5/8'        => '2006-05-08T00:00:00' );
    test_variations( '2006/05/8'       => '2006-05-08T00:00:00' );
    test_variations( '5-8'             => $curr_year . '-05-08T00:00:00' );
    test_variations( '10-8'            => $curr_year . '-10-08T00:00:00' );
    test_variations( '5-08'            => $curr_year . '-05-08T00:00:00' );
    test_variations( '05-08'           => $curr_year . '-05-08T00:00:00' );
    test_variations( '5-8-6'           => '2006-05-08T00:00:00' );
    test_variations( '5-18-6'          => '2006-05-18T00:00:00' );
    test_variations( '10-8-6'          => '2006-10-08T00:00:00' );
    test_variations( '10-18-6'         => '2006-10-18T00:00:00' );

# from postgresql:

    # January 8, 1999    unambiguous in any datestyle input mode
    test_parse_date( 'January 8, 1999'      => '1999-01-08T00:00:00' );
    test_parse_date( 'September 8, 1999'    => '1999-09-08T00:00:00' );
    test_parse_date( 'Sept 8, 1999'         => '1999-09-08T00:00:00' );
    test_parse_date( 'Sep 8, 1999'          => '1999-09-08T00:00:00' );
    test_parse_date( 'Sep 8, 1999 12:33:46' => '1999-09-08T12:33:46' );
    test_parse_date( 'Sep 8, 1999 1:33:46'  => '1999-09-08T01:33:46' );
    test_parse_date( 'Sep 8, 1999 1:3:46'   => '1999-09-08T01:03:46' );
    test_parse_date( 'Sep 8, 1999 1:3:6'    => '1999-09-08T01:03:06' );
    test_parse_date( 'Sep 8, 1999 12:3:46'  => '1999-09-08T12:03:46' );
    test_parse_date( 'Sep 8, 1999 12:3:6'   => '1999-09-08T12:03:06' );
    test_parse_date( 'september 8, 1999'    => '1999-09-08T00:00:00' );
    test_parse_date( 'sept 8, 1999'         => '1999-09-08T00:00:00' );
    test_parse_date( 'sep 8, 1999'          => '1999-09-08T00:00:00' );
    test_variations( '1999-01-08'           => '1999-01-08T00:00:00' );
    test_variations( '1-8-1999'             => '1999-01-08T00:00:00' );
    test_variations( '1-18-1999'            => '1999-01-18T00:00:00' );
    test_variations( '01-02-03'             => '2003-01-02T00:00:00' );
    test_variations( '1999-Jan-08'          => '1999-01-08T00:00:00' );
    test_variations( '08-Jan-1999'          => '1999-01-08T00:00:00' );
    test_variations( 'Jan-08-1999'          => '1999-01-08T00:00:00' );
    test_variations( '08-Jan-99'            => '1999-01-08T00:00:00' );
    test_variations( 'Jan-08-99'            => '1999-01-08T00:00:00' );

    # 99-Jan-08          January 8 in YMD mode, else error
    # NOTE: no real way to detect this, it conflicts with DD-MM-YY
    #test_variations( '99-Jan-08' => '1999-01-08T00:00:00' );

    # 19990108           ISO 8601; January 8, 1999 in any mode
    test_parse_date( '19990108' => '1999-01-08T00:00:00' );
    test_times(      '19990108' => '1999-01-08T00:00:00' );

###

    # Jan-08-1999        January 8 in any mode

###

# from excel

    # March DD, YYYY tested above
    # M/DD           tested above
    # M/DD/YY        tested above
    # MM/DD/YY       tested above
    # M/DD/YYYY
    test_variations( '3-18-2006'   => '2006-03-18T00:00:00' );
    test_variations( '18-Mar'      => $curr_year . '-03-18T00:00:00' );
    test_variations( '8-Mar'       => $curr_year . '-03-08T00:00:00' );
    test_variations( '18-Mar-06'   => '2006-03-18T00:00:00' );
    test_variations( '8-Mar-06'    => '2006-03-08T00:00:00' );
    test_variations( '8-Mar-6'     => '2006-03-08T00:00:00' );
    test_variations( '18-Dec-06'   => '2006-12-18T00:00:00' );
    test_variations( '18-Dec-6'    => '2006-12-18T00:00:00' );
    test_variations( '8-Dec-06'    => '2006-12-08T00:00:00' );
    test_variations( 'Mar-18'      => $curr_year . '-03-18T00:00:00' );
    test_variations( 'Mar-8'       => $curr_year . '-03-08T00:00:00' );
    test_variations( 'Dec-18'      => $curr_year . '-12-18T00:00:00' );
    test_variations( 'Dec-8'       => $curr_year . '-12-08T00:00:00' );
    test_variations( 'March-18'    => $curr_year . '-03-18T00:00:00' );
    test_variations( 'Dec-18'      => $curr_year . '-12-18T00:00:00' );
    test_variations( 'Feb-2006'    => '2006-02-01T00:00:00' );
    test_variations( 'Dec-2006'    => '2006-12-01T00:00:00' );
    test_variations( '18-Mar-2006' => '2006-03-18T00:00:00' );
    test_variations( '8-Mar-2006'  => '2006-03-08T00:00:00' );
    test_variations( '8-Dec-2006'  => '2006-12-08T00:00:00' );
    test_variations( '8-Dec-6'     => '2006-12-08T00:00:00' );
    test_variations( '18-Dec-6'    => '2006-12-18T00:00:00' );
    test_variations( '8-Dec-06'    => '2006-12-08T00:00:00' );
    test_variations( '18-Dec-06'   => '2006-12-18T00:00:00' );
    test_variations( 'Dec-8-6'     => '2006-12-08T00:00:00' );
    test_variations( 'Dec-18-6'    => '2006-12-18T00:00:00' );
    test_variations( '2006-Dec-18' => '2006-12-18T00:00:00' );
    test_variations( '2006-Dec-8'  => '2006-12-08T00:00:00' );
    test_variations( '2006-Jan'    => '2006-01-01T00:00:00' );
    test_variations( '2006-Dec'    => '2006-12-01T00:00:00' );

    # no seperators
    test_parse_date( 'December 1st, 2006' => '2006-12-01T00:00:00' );
    test_parse_date( '1st December, 2006' => '2006-12-01T00:00:00' );
    test_parse_date( 'December 2nd, 2006' => '2006-12-02T00:00:00' );
    test_parse_date( '2nd December, 2006' => '2006-12-02T00:00:00' );
    test_parse_date( 'December 3rd, 2006' => '2006-12-03T00:00:00' );
    test_parse_date( '3rd December, 2006' => '2006-12-03T00:00:00' );
    test_parse_date( 'December 4th, 2006' => '2006-12-04T00:00:00' );
    test_parse_date( '4th December, 2006' => '2006-12-04T00:00:00' );

###

    # 2006-05-07T00:00:00
    # YYYY-MM-DDTHH:MM:SS
    test_parse_date( '2006-05-07T00:00:00' => '2006-05-07T00:00:00' );


############################################################
##### from Date::Parse: http://search.cpan.org/~gbarr/TimeDate-1.16/lib/Date/Parse.pm
    # Comma and day name are optional
    test_parse_date( 'Wed, 16 Jun 94 07:29:35'  => '1994-06-16T07:29:35' );
    test_parse_date( 'Wed 16 Jun 94 07:29:35'   => '1994-06-16T07:29:35' );
    test_parse_date( '16 Jun 94 07:29:35'       => '1994-06-16T07:29:35' );
    test_parse_date( 'Thu, 13 Oct 94 10:13:13'  => '1994-10-13T10:13:13' );
    test_parse_date( 'Thu 13 Oct 94 10:13:13'   => '1994-10-13T10:13:13' );
    test_parse_date( '13 Oct 94 10:13:13'       => '1994-10-13T10:13:13' );
    test_parse_date( 'Wed, 9 Nov 1994 09:50:32' => '1994-11-09T09:50:32' );
    test_parse_date( 'Wed 9 Nov 1994 09:50:32'  => '1994-11-09T09:50:32' );
    test_parse_date( '9 Nov 1994 09:50:32'      => '1994-11-09T09:50:32' );

    test_parse_date( '16 Nov 94 22:28:20'       => '1994-11-16T22:28:20' );
    test_parse_date( '21 dec 17:05'             => $curr_year . '-12-21T17:05:00' );
    test_parse_date( '21-dec 17:05'             => $curr_year . '-12-21T17:05:00' );
    test_parse_date( '21/dec 17:05'             => $curr_year . '-12-21T17:05:00' );
    test_parse_date( '21/dec/93 17:05'          => '1993-12-21T17:05:00' );
    test_parse_date( '1999 10:02:18'            => '1999-01-01T10:02:18' );

############################################################
##### from http://en.wikipedia.org/wiki/Calendar_date
    # DMY not supported (ambigious):
    #16/11/2003 16.11.2003, 16-11-2003 or 16-11-03
    test_times( '16th of November 2003' => '2003-11-16T00:00:00' );
    test_times( '16th November 2003'    => '2003-11-16T00:00:00' );
    test_times( '16 November 2003'      => '2003-11-16T00:00:00' );
    test_times( '16 Nov 2003'           => '2003-11-16T00:00:00' );

    test_times( '2003 November 16' => '2003-11-16T00:00:00' );
    test_times( '2003-11-16'       => '2003-11-16T00:00:00' );
    test_times( 'November 16, 2003'=> '2003-11-16T00:00:00' );
    test_times( 'Nov. 16, 2003'    => '2003-11-16T00:00:00' );

    test_times( '11/16/2003'       => '2003-11-16T00:00:00' );
    test_times( '11-16-2003'       => '2003-11-16T00:00:00' );
    test_times( '11.16.2003'       => '2003-11-16T00:00:00' );
    test_times( '11.16.03'         => '2003-11-16T00:00:00' );

    test_times( '1998-02-28'       => '1998-02-28T00:00:00' );
    test_times( '28 February 1998' => '1998-02-28T00:00:00' );
    test_times( '1999-03-01'       => '1999-03-01T00:00:00' );
    test_times( '01 March 1999'    => '1999-03-01T00:00:00' );
    test_times( '2000-01-30'       => '2000-01-30T00:00:00' );
    test_times( '30 January 2000'  => '2000-01-30T00:00:00' );
    test_times( '01-30-2000'       => '2000-01-30T00:00:00' );
    test_times( '30 January  2000' => '2000-01-30T00:00:00' );
    test_times( '02-28-1998'       => '1998-02-28T00:00:00' );
    test_times( '28 February 1998' => '1998-02-28T00:00:00' );
    test_times( '03-01-1999'       => '1999-03-01T00:00:00' );
    test_times( '01 March    1999' => '1999-03-01T00:00:00' );

    # DMY not supported (ambigious)
    # 01-03-1999 (01 March    1999)
    # 28-02-1998 (28 February 1998)
    # 30-01-2000 (30 January  2000)

    test_times( '2006-JAN-01'           => '2006-01-01T00:00:00' );

    test_times(' 30th of December 2006' => '2006-12-30T00:00:00' );
    test_times( '12/30/06'              => '2006-12-30T00:00:00' );
    test_times( '1st of April 2006'     => '2006-04-01T00:00:00' );
    test_times( '4/1/06'                => '2006-04-01T00:00:00' );
    test_times( '10 December 1999'      => '1999-12-10T00:00:00' );

    # YYYY(day of year) | YY(day of year)
    test_times( '1999345'               => '1999-12-11T00:00:00' );
    test_times( '99345'                 => '1999-12-11T00:00:00' );

    # http://www.cl.cam.ac.uk/~mgk25/iso-time.html
    # YY/M/D not supported (ambigious)
    # 95/2/4

    test_times( '1995-02-04'            => '1995-02-04T00:00:00' );
    test_times( '2/4/95'                => '1995-02-04T00:00:00' );
    test_times( '4/2/95'                => '1995-04-02T00:00:00' );
    test_times( '4.2.1995'              => '1995-04-02T00:00:00' );
    test_times( '04-FEB-1995'           => '1995-02-04T00:00:00' );
    test_times( '4-February-1995'       => '1995-02-04T00:00:00' );
    test_times( '2/4/95'                => '1995-02-04T00:00:00' );
    test_times( '1995-04-02'            => '1995-04-02T00:00:00' );
    test_times( '1995-02-04'            => '1995-02-04T00:00:00' );
    test_times( '2/4/5'                 => '2005-02-04T00:00:00' );
    test_times( '2099-12-31'            => '2099-12-31T00:00:00' );
    test_times( '2000-01-01'            => '2000-01-01T00:00:00' );
    test_times( '1/1/0'                 => '2000-01-01T00:00:00' );
    test_times( 'February 4, 1995'      => '1995-02-04T00:00:00' );
    test_times( '2/4/95'                => '1995-02-04T00:00:00' );

    test_parse_date( '9:30 pm'          => $today . 'T21:30:00' );
    test_parse_date( '9.30 pm'          => $today . 'T21:30:00' );
    test_parse_date( '9.30 p.m.'        => $today . 'T21:30:00' );

    test_times( '19950204'              => '1995-02-04T00:00:00' );
    test_times( '1995-02'               => '1995-02-01T00:00:00' );
    test_times( '1996-12-30'            => '1996-12-30T00:00:00' );
    test_times( '1997-01-05'            => '1997-01-05T00:00:00' );
    # weeks are not supported yet
    # 1997-W01 or 1997W01
    # 1997-W01-2 or 1997W012
    # 1995W05
    # 1976-W01-1
    # 1976-W53-7
    # 1999-W52-5
    test_times( '1996-12-31'            => '1996-12-31T00:00:00' );
    test_times( '1975-12-29'            => '1975-12-29T00:00:00' );
    test_times( '1977-01-02'            => '1977-01-02T00:00:00' );
    test_times( '1999-12-27'            => '1999-12-27T00:00:00' );
    test_times( '2000-01-02'            => '2000-01-02T00:00:00' );

    test_parse_date( '23:59:59' => $today . 'T23:59:59' );
    test_parse_date( '23:59'    => $today . 'T23:59:00' );

    test_parse_date( '1995-02-05 00:00' => '1995-02-05T00:00:00' );
    test_parse_date( '19951231T235959'  => '1995-12-31T23:59:59' );

    test_parse_date( '00:00'            => $today . 'T00:00:00' );
    test_parse_date( '12:00'            => $today . 'T12:00:00' );
    test_parse_date( '12:00 a.m.'       => $today . 'T00:00:00' );
    test_parse_date( '12:00 p.m.'       => $today . 'T12:00:00' );
    test_parse_date( 'noon'             => $today . 'T12:00:00' );
    test_parse_date( 'midnight'         => $today . 'T00:00:00' );
    test_parse_date( '12:01 a.m.'       => $today . 'T00:01:00' );
    test_parse_date( '12:01 p.m.'       => $today . 'T12:01:00' );
    test_parse_date( '12:59 a.m.'       => $today . 'T00:59:00' );
    test_parse_date( '1:00 a.m.'        => $today . 'T01:00:00' );
    test_parse_date( '23:59:59'         => $today . 'T23:59:59' );

    test_times( '1996-05'         => '1996-05-01T00:00:00' );
    test_times( '3. August 1994'  => '1994-08-03T00:00:00' );
    test_times( '3. Aug. 1994'    => '1994-08-03T00:00:00' );
    test_times( '1999-12-31'      => '1999-12-31T00:00:00' );
    test_times( '1999-365'        => '1999-12-31T00:00:00' );

# http://www.tondering.dk/claus/cal/node3.html#SECTION003170000000000000000
# DD MM YYY not supported (conflicts with MM DD YYYY)
# 25.12.1998, 25/12/1998, 25/12-1998, 25.XII.1998

    test_times( '12/25/1998' => '1998-12-25T00:00:00' );
    test_times( '12-25-1998' => '1998-12-25T00:00:00' );
    test_times( '1998-12-25' => '1998-12-25T00:00:00' );
    test_times( '19981225'   => '1998-12-25T00:00:00' );
# 25.12.98 DD MM YY not supported
    test_times( '12/25/98'   => '1998-12-25T00:00:00' );
# 98-12-25 2 digit year in front not supported
# 17 Nov 1858
    test_times( '17 Nov 1858'   => '1858-11-17T00:00:00' );

    test_parse_date( '07/01/2007  10:00 AM' => '2007-07-01T10:00:00' );
}

{
    my $now = DateTime->now;
    my $curr_year = $now->year;

    test_variations( '  2006-Dec-08'          => '2006-12-08T00:00:00' );
    test_variations( '2006-Dec-08  '          => '2006-12-08T00:00:00' );
    test_variations( '  2006-Dec-08  '        => '2006-12-08T00:00:00' );
    test_parse_date( 'January    8,    1999'  => '1999-01-08T00:00:00' );

    test_variations( '2006--Dec-08'           => '2006-12-08T00:00:00' );
    test_variations( '2006/-Dec-08'           => '2006-12-08T00:00:00' );
    test_variations( '2006----------/-Dec-08' => '2006-12-08T00:00:00' );
    test_variations( '2006//-Dec///08'        => '2006-12-08T00:00:00' );
    test_variations( '///Dec///08'            => $curr_year . '-12-08T00:00:00' );
    test_variations( '///Dec///08/////'       => $curr_year . '-12-08T00:00:00' );
}

sub test_variations
{
    my ( $given , $wanted ) = @_;
    my @seperators = ( qw{ \\ / - . } , q{ } );

    my $base;
    foreach my $sep ( @seperators )
    {
        my $modified_given = $given;
        $modified_given =~ s{-}{$sep}mxg;
        $base = test_parse_date( $modified_given => $wanted );
    }
    test_times( $given , $wanted );
    return;
}

sub test_times
{
    my ( $given , $wanted ) = @_;
    my %times = (
    #   given           NONE       AM         PM
        '12:33:46' => ['12:33:46','00:33:46','12:33:46'] ,
        '1:33:46'  => ['01:33:46','01:33:46','13:33:46'] ,
        '1:3:46'   => ['01:03:46','01:03:46','13:03:46'] ,
        '1:3:6'    => ['01:03:06','01:03:06','13:03:06'] ,
        '12:3:46'  => ['12:03:46','00:03:46','12:03:46'] ,
        '12:3:6'   => ['12:03:06','00:03:06','12:03:06'] ,
    );
    my ( $wanted_d , undef ) = split( m{T}mx , $wanted );

    while ( my ( $given_time , $wanted_time ) = each( %times ) )
    {
        my $to_test     = sprintf( '%s %s' , $given    , $given_time );
        my $expected    = sprintf( '%sT%s' , $wanted_d , $wanted_time->[0] );
        my $expected_am = sprintf( '%sT%s' , $wanted_d , $wanted_time->[1] );
        my $expected_pm = sprintf( '%sT%s' , $wanted_d , $wanted_time->[2] );

        test_parse_date( $to_test => $expected );
        test_parse_date( $to_test . ' am'  =>  $expected_am );
        test_parse_date( $to_test . ' pm'  =>  $expected_pm );
    }
    return;
}

{
    my $dt = DateTime->new( year => 2006 );
    is( $base->_pick_year( '06' , $dt->clone ) , '2006' , '06 becomes 2006 in 2006' );
    is( $base->_pick_year( 6 ,    $dt->clone ) , '2006' , '6 becomes 2006 in 2006' );
}
{
    my $dt = DateTime->new( year => 1999 );
    is( $base->_pick_year( '06' , $dt->clone ) , '2006' , '06 becomes 2006 in 1999' );
    is( $base->_pick_year( 98 ,   $dt->clone ) , '1998' , '98 becomes 1998 in 1999' );
}
{
    my $dt = DateTime->new( year => 1969 );
    is( $base->_pick_year( 50 , $dt->clone ) , '1950' , '50 becomes 1950 in 1969' );
    is( $base->_pick_year( 5 ,  $dt->clone ) , '1905' , '5 becomes 1905 in 1969' );
}
