#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 24;
use DateTime;

use t::lib::helper;

my $curr_year = DateTime->now->year;

t::lib::helper::run_tests(
    "5-8   => $curr_year-05-08T00:00:00" ,
    "10-8  => $curr_year-10-08T00:00:00" ,
    "5-08  => $curr_year-05-08T00:00:00" ,
    "05-08 => $curr_year-05-08T00:00:00" ,

    "18-Mar   => $curr_year-03-18T00:00:00" ,
    "8-Mar    => $curr_year-03-08T00:00:00" ,
    "Mar-18   => $curr_year-03-18T00:00:00" ,
    "Mar-8    => $curr_year-03-08T00:00:00" ,
    "Dec-18   => $curr_year-12-18T00:00:00" ,
    "Dec-8    => $curr_year-12-08T00:00:00" ,
    "March-18 => $curr_year-03-18T00:00:00" ,
    "Dec-18   => $curr_year-12-18T00:00:00" ,

    "21 dec 17:05     => $curr_year-12-21T17:05:00" ,
    "21-dec 17:05     => $curr_year-12-21T17:05:00" ,
    "21/dec 17:05     => $curr_year-12-21T17:05:00" ,
    "///Dec///08      => $curr_year-12-08T00:00:00" ,
    "///Dec///08///// => $curr_year-12-08T00:00:00" ,
    "8:00pm December tenth => $curr_year-12-10T20:00:00",
    "Dec/10 at 05:30:25 => $curr_year-12-10T05:30:25",
    "Dec/10 at 05:30:25 GMT => $curr_year-12-10T05:30:25",
    "December/10 => $curr_year-12-10T00:00:00",
    "12/10 at 05:30:25 => $curr_year-12-10T05:30:25",
    "12/10 at 05:30:25 GMT => $curr_year-12-10T05:30:25 => UTC",
);
