package t::lib::helper;

use strict;
use warnings;

use Test::More;

use DateTime::Format::Flexible;

my $base = 'DateTime::Format::Flexible';

sub run_tests
{
    foreach my $line ( @_ )
    {
        $line =~ s{\n\z}{}mx;
        next if $line =~ m{\A\#}mx;
        next if $line =~ m{\A\z}mx;
        my ( $given , $wanted ) = split m{\s+=>\s+}mx , $line;

        compare( $given , $wanted );
    }
}

sub compare
{
    my ( $given , $wanted ) = @_;
    my $dt = $base->parse_datetime( $given );
    is( $dt->datetime , $wanted , "$given => $wanted" );
}

1;
