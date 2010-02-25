#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use t::lib::helper;

use DateTime::Format::Flexible;

{
    my $dt = DateTime::Format::Flexible->parse_datetime(
        'Wed Nov 11 13:55:48 PST 2009' ,
        tz_map => { PST => 'America/Los_Angeles' } ,
    );
    is( $dt->datetime , '2009-11-11T13:55:48' , 'internal PST timezone parsed/stripped' );
    is( $dt->time_zone->name , 'America/Los_Angeles' , 'internal PST timezone set correctly' );
}


t::lib::helper::run_tests(
   'Wed Nov 11 13:55:48 PST 2009 => 2009-11-11T13:55:48',
   'Wed Nov 11 18:55:16 PST 2009 => 2009-11-11T18:55:16',
);
