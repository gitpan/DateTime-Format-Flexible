#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2510;
use File::Spec::Functions 'catfile';

use t::lib::helper;

my $test_file = catfile( 't' , 'data' , 'tests.txt' );
open my $tests , $test_file or BAIL_OUT( "unable to open $test_file: $!" );

t::lib::helper::run_tests( <$tests> );

close $tests;
