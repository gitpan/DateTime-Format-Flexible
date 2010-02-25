package DateTime::Format::Flexible::lang;

use strict;
use warnings;

use Module::Pluggable require => 1 , search_path => [__PACKAGE__];
use List::MoreUtils 'any';

sub new
{
    my ( $class , %params ) = @_;
    my $self = bless \%params , $class;
    return $self;
}

sub _cleanup_alpha
{
    my ( $self , $date , $p ) = @_;
    foreach my $plug ( $self->plugins )
    {
        if ( $self->{lang} )
        {
            my ( $lang ) = $plug =~ m{(\w{2}\z)}mx;
            if ( not any { $_ eq $lang } @{ $self->{lang} } )
            {
                printf( "# skipping %s\n", $plug ) if $ENV{DFF_DEBUG};
                next;
            }
        }
        printf( "# not skipping %s\n", $plug ) if $ENV{DFF_DEBUG};

        $date = $self->_do_math( $plug , $date );
        $date = $self->_string_dates( $plug , $date );
        ( $date , $p ) = $self->_fix_alpha_month( $plug , $date , $p );
        $date = $self->_remove_day_names( $plug , $date );
        $date = $self->_fix_hours( $plug , $date );
        $date = $self->_remove_strings( $plug , $date );
        $date = $self->_locate_time( $plug , $date );
        ( $date , $p ) = $self->_fix_internal_tz( $plug , $date , $p );
    }
    return ( $date , $p );
}

sub _fix_internal_tz
{
    my ( $self , $plug , $date , $p ) = @_;
    my %tzs = $plug->timezone_map;
    while( my( $orig_tz , $new_tz ) = each ( %tzs ) )
    {
        if( $date =~ m{$orig_tz}mxi )
        {
            $p->{ time_zone } = $new_tz;
            $date =~ s{$orig_tz}{}mxi;
            return ( $date , $p );
        }
    }
    return ( $date , $p );
}

sub _do_math
{
    my ( $self , $plug , $date ) = @_;
    my %strings = $plug->math_strings;
    if ( $date =~ m{ago}mx )
    {
        my $base_dt = DateTime::Format::Flexible->base->clone;
        if ( my ( $amount , $unit ) = $date =~ m{(\d+)\s+([^\s]+)}mx )
        {
            if ( exists( $strings{$unit} ) )
            {
                my $ret = $base_dt->subtract( $strings{$unit} => $amount );
                $date =~ s{$amount\s+$unit\s+ago}{}mx;
                if ( $date ) # we still have more to parse...
                {
                    $date = $ret->ymd . ' ' . $date;
                }
                else
                {
                    $date = $ret->datetime;
                }
                return $date;
            }
        }
    }
    return $date;
}

sub _string_dates
{
    my ( $self , $plug , $date ) = @_;
    my %strings = $plug->string_dates;
    foreach my $key ( keys %strings )
    {
        if ( $date =~ m{$key}mxi )
        {
            my $new_value = $strings{$key}->();
            $date =~ s{$key}{$new_value}mix;
        }
    }

    my %day_numbers = $plug->day_numbers;
    foreach my $key ( keys %day_numbers )
    {
        if ( $date =~ m{$key}mxi )
        {
            my $new_value = $day_numbers{$key};
            $date =~ s{$key}{n${new_value}n}mix;
        }
    }
    return $date;
}

# turn month names into month numbers with surrounding X
# Sep => X9X
sub _fix_alpha_month
{
    my ( $self , $plug , $date , $p ) = @_;
    my %months = $plug->months;
    while( my( $month_name , $month_number ) = each ( %months ) )
    {
        if( $date =~ m{\b$month_name\b}mxi )
        {
            $p->{ month } = $month_number;
            $date =~ s{\b$month_name\b}{X${month_number}X}mxi;

            return ( $date , $p );
        }
    }
    return ( $date , $p );
}

# remove any day names, we do not need them
sub _remove_day_names
{
    my ( $self , $plug , $date ) = @_;
    my %days = $plug->days;
    foreach my $day_name ( keys %days )
    {
        # if the day name is by itself, make it the upcoming day
        # eg: monday = next monday
        if ( $date =~ m{\A$day_name\z}mx or
             $date =~ m{$day_name\sat}mx )
        {
            my $dt = $self->{base}->clone->truncate( to => 'day' );
            if ( $days{$day_name} == $dt->dow )
            {
                my $str = $dt->ymd;
                $date =~ s{$day_name}{$str};
                return $date;
            }
            elsif ( $days{$day_name} > $dt->dow )
            {
                $dt->add( days => $days{$day_name} - $dt->dow );
                my $str = $dt->ymd;
                $date =~ s{$day_name}{$str};
                return $date;
            }
            else
            {
                $dt->add( days => $days{$day_name} - $dt->dow + 7 );
                my $str = $dt->ymd;
                $date =~ s{$day_name}{$str};
                return $date;
            }
        }
        # otherwise, just strip it out
        if ( $date =~ m{$day_name}mxi )
        {
            $date =~ s{$day_name,?}{}gmix;
            return $date;
        }
    }
    return $date;
}

# fix noon and midnight
sub _fix_hours
{
    my ( $self , $plug , $date ) = @_;
    my %hours = $plug->hours;
    foreach my $hour ( keys %hours )
    {
        if ( $date =~ m{$hour}mxi )
        {
            my $realtime = $hours{ $hour };
            $date =~ s{$hour}{$realtime}gmix;
            return $date;
        }
    }
    return $date;
}

sub _remove_strings
{
    my ( $self , $plug , $date ) = @_;
    my @rs = $plug->remove_strings;
    foreach my $rs ( @rs )
    {
        if ( $date =~ m{$rs}mxi )
        {
            $date =~ s{$rs}{ }gmix;
        }
    }
    return $date;
}

sub _locate_time
{
    my ( $self , $plug , $date ) = @_;
    $date = $plug->parse_time( $date );
    return $date;
}

1;

__END__

=head1 NAME

DateTime::Format::Flexible::lang - base language module to handle plugins for DateTime::Format::Flexible.

=head1 DESCRIPTION

You should not need to use this module directly

=head2 new

Instantiate a new instance of this module.

=head1 AUTHOR

    Tom Heady
    CPAN ID: thinc
    Punch, Inc.
    cpan@punch.net
    http://www.punch.net/

=head1 COPYRIGHT & LICENSE

    Copyright 2010 Tom Heady.

    This program is free software; you can redistribute it and/or
    modify it under the terms of either:

=over 4

=item * the GNU General Public License as published by the Free
    Software Foundation; either version 1, or (at your option) any
    later version, or

=item * the Artistic License version 2.0.

=back

=head1 SEE ALSO

F<DateTime::Format::Flexible>

=cut
