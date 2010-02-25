package t::lib::helper;

use strict;
use warnings;

use Test::More;

use DateTime::Format::Flexible;

my $base = 'DateTime::Format::Flexible';

sub run_tests
{
    foreach ( @_ )
    {
        my ( $line ) = $_ =~ m{([^\n]+)};
        next if not $line;
        next if $line =~ m{\A\#}mx; # skip comments
        next if $line =~ m{\A\z}mx; # skip blank lines
        my ( $given , $wanted , $tz ) = split m{\s+=>\s+}mx , $line;
        compare( $given , $wanted , $tz );
    }
}

sub compare
{
    my ( $given , $wanted , $tz ) = @_;
    my $dt = $base->parse_datetime( $given );
    is( $dt->datetime , $wanted , "$given => $wanted" );
    if ( $tz )
    {
        is( $dt->time_zone->name , $tz , "timezone => $tz" );
    }
}

1;
