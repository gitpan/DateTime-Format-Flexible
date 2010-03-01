#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 53;

use DateTime::Format::Flexible;
my $base = 'DateTime::Format::Flexible';

my ( $base_dt ) = $base->parse_datetime( '2005-06-07T13:14:15' );
$base->base( $base_dt );

use t::lib::helper;

my $now = DateTime->now;

t::lib::helper::run_tests(
    'now => 2005-06-07T13:14:15',
    'Now => 2005-06-07T13:14:15',
    'Today => 2005-06-07T00:00:00',
    'yesterday => 2005-06-06T00:00:00',
    'tomorrow => 2005-06-08T00:00:00',
    'overmorrow => 2005-06-09T00:00:00',
    'today at 4:00 => 2005-06-07T04:00:00',
    'today at 16:00:00:05 => 2005-06-07T16:00:00',
    'today at 12:00 am => 2005-06-07T00:00:00',
    'today at 12:00 GMT => 2005-06-07T12:00:00 => UTC',
    'today at 4:00 -0800 => 2005-06-07T04:00:00 => -0800',
    'today at noon => 2005-06-07T12:00:00',
    'tomorrow at noon => 2005-06-08T12:00:00',
    '1 month ago => 2005-05-07T13:14:15',
    '1 month ago at 4pm => 2005-05-07T16:00:00',
    'monday => 2005-06-13T00:00:00',
    'tuesday => 2005-06-07T00:00:00',
    'wednesday => 2005-06-08T00:00:00',
    'thursday => 2005-06-09T00:00:00',
    'friday => 2005-06-10T00:00:00',
    'saturday => 2005-06-11T00:00:00',
    'sunday => 2005-06-12T00:00:00',
    'sunday at 3p => 2005-06-12T15:00:00',
    'mon => 2005-06-13T00:00:00',
    'tue => 2005-06-07T00:00:00',
    'wed => 2005-06-08T00:00:00',
    'thu => 2005-06-09T00:00:00',
    'fri => 2005-06-10T00:00:00',
    'sat => 2005-06-11T00:00:00',
    'sun => 2005-06-12T00:00:00',
    'sunday at 3p => 2005-06-12T15:00:00',
    'next sunday at 3p => 2005-06-12T15:00:00',
    'january => 2005-01-01T00:00:00',
    'february => 2005-02-01T00:00:00',
    'march => 2005-03-01T00:00:00',
    'april => 2005-04-01T00:00:00',
    'may => 2005-05-01T00:00:00',
    'june => 2005-06-01T00:00:00',
    'july => 2005-07-01T00:00:00',
    'august => 2005-08-01T00:00:00',
    'september => 2005-09-01T00:00:00',
    'october => 2005-10-01T00:00:00',
    'november => 2005-11-01T00:00:00',
    'december => 2005-12-01T00:00:00',
    'allballs => 2005-06-07T00:00:00',
    'epoch => 1970-01-01T00:00:00',
);


#######################
{
    my $str = ( 'today at 16:00:00:05' );
    my $dt = $base->parse_datetime( $str );
    is ( $dt->nanosecond , '05' , "nanoseconds are set ($str)" );
}

{
    my ( $str , $wanted ) = ( 'today at 4:00 PST' , '2005-06-07T04:00:00' );
    my $dt = $base->parse_datetime( $str , tz_map => { PST => 'America/Los_Angeles' } );
    is ( $dt , $wanted , "$str => $wanted ($dt)" );
    is ( $dt->time_zone->name , 'America/Los_Angeles' , "timezone set ($str)" );
}

{
    my $dt = DateTime::Format::Flexible->parse_datetime( '-infinity' );
    ok ( $dt->is_infinite() , "-infinity is infinite" );
}

{
    my $dt = DateTime::Format::Flexible->parse_datetime( 'infinity' );
    ok ( $dt->is_infinite() , "infinity is infinite" );
}
