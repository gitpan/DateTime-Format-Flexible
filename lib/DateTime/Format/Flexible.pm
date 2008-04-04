package DateTime::Format::Flexible;
use strict;
use warnings;

our $VERSION = '0.05';

use base 'DateTime::Format::Builder';

use Readonly;

Readonly my $DELIM  => qr{(?:\\|\/|-|\.|\s)};
Readonly my $HMSDELIM => qr{(?:\.|:)};
Readonly my $YEAR => qr{(\d{1,4})};
Readonly my $MON => qr{(\d\d?)};
Readonly my $DAY => qr{(\d\d?)};
Readonly my $HM => qr{(\d\d?)$HMSDELIM(\d\d?)};
Readonly my $HMS => qr{(\d\d?)$HMSDELIM(\d\d?)$HMSDELIM(\d\d?)};
Readonly my $AMPM => qr{(a\.?m|p\.?m)\.?}i;

Readonly my $MMDDYYYY => qr{(\d{1,2})$DELIM(\d{1,2})$DELIM(\d{1,4})};
Readonly my $YYYYMMDD => qr{(\d{4})$DELIM(\d{1,2})$DELIM(\d{1,2})};
Readonly my $MMDD => qr{(\d{1,2})$DELIM(\d{1,2})};
Readonly my $DDXXMM => qr{(\d{1,2})${DELIM}XX(\d{1,2})};
Readonly my $DDXXMMYYYY => qr{(\d{1,2})${DELIM}XX(\d{1,2})$DELIM(\d{1,4})};
Readonly my $MMYYYY => qr{(\d{1,2})$DELIM(\d{4})};

Readonly my $DM => [ qw( day month ) ];
Readonly my $DMY => [ qw( day month year ) ];
Readonly my $DMHM => [ qw( day month hour minute ) ];
Readonly my $DMHMS => [ qw( day month hour minute second ) ];
Readonly my $DMHMSAP => [ qw( day month hour minute second ampm ) ];
Readonly my $DMYHM => [ qw( day month year hour minute ) ];
Readonly my $DMYHMS => [ qw( day month year hour minute second ) ];
Readonly my $DMYHMSAP => [ qw( day month year hour minute second ampm ) ];

Readonly my $MD => [ qw( month day ) ];
Readonly my $MY => [ qw( month year ) ];
Readonly my $MDY => [ qw( month day year ) ];
Readonly my $MDHMS => [ qw( month day hour minute second ) ];
Readonly my $MDHMSAP => [ qw( month day hour minute second ampm ) ];
Readonly my $MYHMS => [ qw( month year hour minute second ) ];
Readonly my $MYHMSAP => [ qw( month year hour minute second ampm ) ];
Readonly my $MDYHMS => [ qw( month day year hour minute second ) ];
Readonly my $MDYHMAP => [ qw( month day year hour minute ampm ) ];
Readonly my $MDYHMSAP => [ qw( month day year hour minute second ampm ) ];

Readonly my $YM => [ qw( year month ) ];
Readonly my $YMD => [ qw( year month day ) ];
Readonly my $YMDH => [ qw( year month day hour ) ];
Readonly my $YHMS => [ qw( year hour minute second ) ];
Readonly my $YMDHM => [ qw( year month day hour minute ) ];
Readonly my $YMHMS => [ qw( year month hour minute second ) ];
Readonly my $YMDHMS => [ qw( year month day hour minute second ) ];
Readonly my $YMHMSAP => [ qw( year month hour minute second ampm ) ];
Readonly my $YMDHMSAP => [ qw( year month day hour minute second ampm ) ];

use DateTime;
use DateTime::Format::Builder;

my $formats =
[
 [ preprocess => \&_fix_alpha ] ,

 { length => [18..22] , params => $YMDHMSAP , regex => qr{\A(\d{4})$DELIM(\d{2})$DELIM(\d{2})\s$HMS\s?$AMPM\z} , postprocess => \&_fix_ampm } ,

 ########################################################
 ##### Month/Day/Year
 # M/DD/Y, MM/D/Y, M/D/Y, MM/DD/Y, M/D/YY, M/DD/YY, MM/D/Y, MM/SS/YY,
 # M/D/YYYY, M/DD/YYYY, MM/D/YYYY, MM/DD/YYYY

 { length => [5..10],  params => $MDY,      regex => qr{\A${MON}${DELIM}${DAY}${DELIM}${YEAR}\z},               postprocess => \&_fix_year },
 { length => [11..19], params => $MDYHMS,   regex => qr{\A${MON}${DELIM}${DAY}${DELIM}${YEAR}\s$HMS\z},         postprocess => \&_fix_year },
 { length => [11..20], params => $MDYHMAP,  regex => qr{\A${MON}${DELIM}${DAY}${DELIM}${YEAR}\s$HM\s?$AMPM\z},  postprocess => [ \&_fix_ampm , \&_fix_year ] } ,
 { length => [14..22], params => $MDYHMSAP, regex => qr{\A${MON}${DELIM}${DAY}${DELIM}${YEAR}\s$HMS\s?$AMPM\z}, postprocess => [ \&_fix_ampm , \&_fix_year ] } ,

 ########################################################
 ##### Year/Month/Day
 ##### Can't have 1,2 digit years in this format, would get confused
 ##### with MM-DD-YY
 # YYYY/M/D, YYYY/M/DD, YYYY/MM/D, YYYY/MM/DD
 # YYYY/MM/DD HH:MM:SS
 # YYYY-MM HH:MM:SS
 { length => [6,7],     params => $YM,
   regex => qr{\A(\d{4})$DELIM$MON\z} },
 { length => [12..16],     params => $YMHMS,
   regex => qr{\A(\d{4})$DELIM$MON\s$HMS\z} },
 { length => [14..19],     params => $YMHMSAP,
   regex => qr{\A(\d{4})$DELIM$MON\s$HMS\s?$AMPM\z} , postprocess => \&_fix_ampm },
 { length => [8..10],  params => $YMD,      regex => qr{\A$YYYYMMDD\z} },
 { length => [11..16], params => $YMDHM,    regex => qr{\A$YYYYMMDD\s$HM\z} },
 { length => [14..19], params => $YMDHMS,   regex => qr{\A$YYYYMMDD\s$HMS\z} },
 { length => [17..21], params => $YMDHMSAP, regex => qr{\A$YYYYMMDD\s$HMS\s?$AMPM\z}, postprocess => \&_fix_ampm },

 ########################################################
 ##### YYYY-MM-DDTHH:MM:SS
 # this is what comes out of the database
 { length => 19, params => $YMDHMS, regex  => qr{\A(\d{4})$DELIM(\d{2})$DELIM(\d{2})T(\d{2}):(\d{2}):(\d{2})\z} },

 ########################################################
 ##### Month/Day
 # M/D, M/DD, MM/D, MM/DD
 { length => [3..5],   params => $MD,      regex  => qr{\A$MMDD\z},               extra  => { year => DateTime->now->year } },
 { length => [9..14],  params => $MDHMS,   regex  => qr{\A$MMDD\s$HMS\z},         extra  => { year => DateTime->now->year } },
 { length => [12..17], params => $MDHMSAP, regex  => qr{\A$MMDD\s$HMS\s?$AMPM\z}, extra  => { year => DateTime->now->year } , postprocess => \&_fix_ampm },

 ########################################################
 ##### Month/Day
 # YYYY HH:MM:SS
 { length => [13], params => $YHMS , regex => qr{\A$YEAR\s$HMS\z} } ,

 ########################################################
 ##### Alpha months
 # _fix_alpha changes month name to "XXM"
 # 18-XXM, XX1-18,08-XXM-99, XXM-08-1999, 1999-XX1-08

 # DD-mon, D-mon, D-mon-YY, DD-mon-YY, D-mon-YYYY, DD-mon-YYYY, D-mon-Y, DD-mon-Y
 { length => [5..7],   params => $DM,       regex  => qr{\A${DDXXMM}\z},                     extra => { year => DateTime->now->year } },
 { length => [9..15],  params => $DMHM,     regex  => qr{\A${DDXXMM}\s${HM}\z},              extra => { year => DateTime->now->year } },
 { length => [9..18],  params => $DMHMS,    regex  => qr{\A${DDXXMM}\s${HMS}\z},             extra => { year => DateTime->now->year } },
 { length => [11..21], params => $DMHMSAP,  regex  => qr{\A${DDXXMM}\s${HMS}\s?$AMPM\z},     postprocess => \&_fix_ampm , extra => { year => DateTime->now->year } },
 { length => [7..11],  params => $DMY,      regex  => qr{\A${DDXXMMYYYY}\z},                 postprocess => \&_fix_year },
 { length => [12..18], params => $DMYHM,    regex  => qr{\A${DDXXMMYYYY}\s${HM}\z},          postprocess => \&_fix_year },
 { length => [12..21], params => $DMYHMS,   regex  => qr{\A${DDXXMMYYYY}\s${HMS}\z},         postprocess => \&_fix_year },
 { length => [14..24], params => $DMYHMSAP, regex  => qr{\A${DDXXMMYYYY}\s${HMS}\s?$AMPM\z}, postprocess => [ \&_fix_year , \&_fix_ampm ] },

 # mon-D , mon-DD,  mon-YYYY, mon-D-Y, mon-DD-Y, mon-D-YY, mon-DD-YY
 # mon-D-YYYY, mon-DD-YYYY
 { length => [8,9],    params => $MY,       regex => qr{\AXX$MMYYYY\z} },
 { length => [14..18], params => $MYHMS,    regex => qr{\AXX${MMYYYY}\s${HMS}\z} },
 { length => [16..21], params => $MYHMSAP,  regex => qr{\AXX${MMYYYY}\s${HMS}\s?$AMPM\z}, postprocess => \&_fix_ampm },
 { length => [5..7],   params => $MD,       regex => qr{\AXX$MMDD\z},                     extra => { year => DateTime->now->year } },
 { length => [10..18], params => $MDHMS,    regex => qr{\AXX$MMDD\s$HMS\z},               extra => { year => DateTime->now->year } },
 { length => [12..21], params => $MDHMSAP,  regex => qr{\AXX$MMDD\s$HMS\s?$AMPM\z} ,      postprocess => \&_fix_ampm , extra => { year => DateTime->now->year } },
 { length => [7..12],  params => $MDY,      regex => qr{\AXX$MMDDYYYY\z},                 postprocess => \&_fix_year },
 { length => [12..21], params => $MDYHMS,   regex => qr{\AXX$MMDDYYYY\s$HMS\z},           postprocess => \&_fix_year },
 { length => [14..24], params => $MDYHMSAP, regex => qr{\AXX$MMDDYYYY\s$HMS\s?$AMPM\z},   postprocess => [ \&_fix_year , \&_fix_ampm ] },

 # YYYY-mon-D, YYYY-mon-DD, YYYY-mon
 { length => [8,9],    params => $YM,       regex => qr{\A(\d{4})${DELIM}XX(\d{1,2})\z} },
 { length => [13..18], params => $YMHMS,    regex => qr{\A(\d{4})${DELIM}XX(\d{1,2})\s$HMS\z} },
 { length => [15..21], params => $YMHMSAP,  regex => qr{\A(\d{4})${DELIM}XX(\d{1,2})\s$HMS\s?$AMPM\z}                , postprocess => \&_fix_ampm },
 { length => [9..12],  params => $YMD,      regex => qr{\A(\d{4})${DELIM}XX(\d{1,2})$DELIM(\d{1,2})\z} },
 { length => [15..21], params => $YMDHMS,   regex => qr{\A(\d{4})${DELIM}XX(\d{1,2})$DELIM(\d{1,2})\s$HMS\z} },
 { length => [18..24], params => $YMDHMSAP, regex => qr{\A(\d{4})${DELIM}XX(\d{1,2})$DELIM(\d{1,2})\s$HMS\s?$AMPM\z} , postprocess => \&_fix_ampm },

 # month D, Y | month D, YY | month D, YYYY | month DD, Y | month DD, YY
 # month DD, YYYY
 { length => [9..13], params => $MDY,      regex => qr{\AXX(\d{1,2})\s(\d{1,2}),\s(\d{1,4})\z} },
 { length => [5..22], params => $MDYHMS,   regex => qr{\AXX(\d{1,2})\s(\d{1,2}),\s(\d{1,4})\s$HMS\z} },
 { length => [7..25], params => $MDYHMSAP, regex => qr{\AXX(\d{1,2})\s(\d{1,2}),\s(\d{1,4})\s$HMS\s?$AMPM\z} , postprocess => \&_fix_ampm },

 # D month, Y | D month, YY | D month, YYYY | DD month, Y | DD month, YY
 # DD month, YYYY
 { length => [8..13],  params => $DMY,      regex => qr{\A(\d{1,2})\sXX(\d{1,2}),?\s(\d{1,4})\z} },
 { length => [13..21], params => $DMYHMS,   regex => qr{\A(\d{1,2})\sXX(\d{1,2}),?\s(\d{1,4})\s$HMS\z} },
 { length => [16..27], params => $DMYHMSAP, regex => qr{\A(\d{1,2})\sXX(\d{1,2}),?\s(\d{1,4})\s$HMS\s?$AMPM\z} , postprocess => \&_fix_ampm },

 ########################################################
 ##### Bare Numbers
 # 20060518T051326, 20060518T0513, 20060518T05, 20060518, 200608
 # 20060518 12:34:56
 { length => [16..20], params => $YMDHMSAP, regex => qr{\A(\d{4})(\d{2})(\d{2})\s$HMS\s?$AMPM\z} , postprocess => \&_fix_ampm },
 { length => [14..17], params => $YMDHMS,   regex => qr{\A(\d{4})(\d{2})(\d{2})\s$HMS\z} },
 { length => 15,       params => $YMDHMS,   regex => qr{\A(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\z} },
 { length => 13,       params => $YMDHM,    regex => qr{\A(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})\z} },
 { length => 11,       params => $YMDH,     regex => qr{\A(\d{4})(\d{2})(\d{2})T(\d{2})\z} },
 { length => 8,        params => $YMD,      regex => qr{\A(\d{4})(\d{2})(\d{2})\z} } ,
 { length => 6,        params => $YM,       regex => qr{\A(\d{4})(\d{2})\z} },

 ########################################################
 ##### bare times
 # HH:MM:SS
 { length => [5..8],
   params => [ qw( hour minute second ) ] ,
   regex => qr{\A$HMS\z} ,
   extra => { year => DateTime->now->year ,
              month => DateTime->now->month ,
              day => DateTime->now->day } } ,
 # HH:MM
 { length => [3..5],
   params => [ qw( hour minute ) ] ,
   regex => qr{\A$HM\z} ,
   extra => { year => DateTime->now->year ,
              month => DateTime->now->month ,
              day => DateTime->now->day } } ,
 # HH:MM am
 { length => [7..10],
   params => [ qw( hour minute ampm ) ] ,
   regex => qr{\A$HM\s?$AMPM\z} ,
   extra => { year => DateTime->now->year ,
              month => DateTime->now->month ,
              day => DateTime->now->day } ,
   postprocess => \&_fix_ampm } ,

 # Day of year
 # 1999345 => 1999, 345th day of year
 { length => [5,7],    params => [ qw( year doy ) ] ,                         regex => qr{\A$YEAR(?:$DELIM)?(\d{3})\z} ,               postprocess => [ \&_fix_year , \&_fix_day_of_year ] } ,
 { length => [10..18], params => [ qw( year doy hour minute second ) ] ,      regex => qr{\A$YEAR(?:$DELIM)?(\d{3})\s$HMS\z} ,         postprocess => [ \&_fix_year , \&_fix_day_of_year ] } ,
 { length => [12..21], params => [ qw( year doy hour minute second ampm ) ] , regex => qr{\A$YEAR(?:$DELIM)?(\d{3})\s$HMS\s?$AMPM\z} , postprocess => [ \&_fix_year , \&_fix_day_of_year , \&_fix_ampm ]} ,

 # nanoseconds. no length here, we do not know how many digits they will use for nanoseconds
 {  params => [ qw( year month day hour minute second nanosecond ) ] , regex => qr{\A$YYYYMMDD(?:\s|T)${HMS}${HMSDELIM}(\d+)\z} } ,
];

DateTime::Format::Builder->create_class( parsers => { build => $formats } );

sub parse_datetime
{
    my $self = shift;
    return $self->build( @_ );
}

sub _fix_day_of_year
{
    my %args = @_;

    my $doy = $args{parsed}{doy};
    delete $args{parsed}{doy};

    my $dt = DateTime->from_day_of_year( year => $args{parsed}{year} ,
                                         day_of_year => $doy );
    $args{parsed}{month} = $dt->month;
    $args{parsed}{day} = $dt->day;

    return 1;
}

sub _fix_alpha
{
    my %args = @_;
    my ($date, $p) = @args{qw( input parsed )};
    my %months =
    (
     'Jan(?:uary)?'        => 1,
     'Feb(?:ruary)?'       => 2,
     'Mar(?:ch)?'          => 3,
     'Apr(?:il)?'          => 4,
     'May'                 => 5,
     'Jun(?:e)?'           => 6,
     'Jul(?:y)?'           => 7,
     'Aug(?:ust)?'         => 8,
     'Sep(?:t)?(?:ember)?' => 9,
     'Oct(?:ober)?'        => 10,
     'Nov(?:ember)?'       => 11,
     'Dec(?:ember)?'       => 12,
    );
    my %days =
    (
     'Mon(?:day)?'    => 1,
     'Tue(?:day)?'    => 2,
     'Wed(?:nesday)?' => 3,
     'Thu(?:rsday)?'  => 4,
     'Fri(?:day)?'    => 5,
     'Sat(?:urday)?'  => 6,
     'Sun(?:day)?'    => 7,
    );
    my %hours =
    (
     noon     => '12:00:00' ,
     midnight => '00:00:00' ,
    );

    # remove ' of' as in '16th of November 2003'
    if ( $date =~ m{\sof\s}mx )
    {
        ( $p->{ day } ) = $date =~ s{\sof\s}{ }gmix;
    }

    # fix noon and midnight
    foreach my $hour ( keys %hours )
    {
        if ( $date =~ m{$hour}mxi )
        {
            my $realtime = $hours{ $hour };
            $date =~ s{$hour}{$realtime}gmix;
        }
    }

    # remove any day names, we do not need them
    foreach my $day_name ( keys %days )
    {
        if ( $date =~ m{$day_name}mxi )
        {
            $date =~ s{$day_name,?}{}gmix;
        }
    }

    $date =~ s{\A\s+}{}mx;    # trim front
    $date =~ s{\s+\z}{}mx;    # trim back

    $date =~ s{\s+}{ }gmx;    # remove extra spaces from the middle

    $date =~ s{($DELIM)+}{$1}mxg;   # make multiple delimeters into one
    $date =~ s{\A$DELIM+}{}mx;      # remove any leading delimeters
    $date =~ s{$DELIM+\z}{}mx;      # remove any trailing delimeters

    # turn month names into month numbers with leading XX
    # Sep => XX9
    while( my( $month_name , $month_number ) = each ( %months ) )
    {
        if( $date =~ m{$month_name}mxi )
        {
            $p->{ month } = $month_number;
            $date =~ s{$month_name}{XX$month_number}mxi;
        }
    }

    # remove number extensions
    my $day_match = qr{(\d{1,2})(?:st|nd|rd|th)} ;
    if( $date =~ m{$day_match}mxi )
    {
        ( $p->{ day } ) = $date =~ s{$day_match}{$1}mxi;
    }
#    printf( "--->%s (%s)\n" , $date , length( $date ) );
    return $date;
}

sub _fix_ampm
{
    my %args = @_;

    next if not defined $args{parsed}{ampm};

    my $ampm = $args{parsed}{ampm};
    delete $args{parsed}{ampm};

    if ( $ampm =~ m{a\.?m\.?}mix )
    {
        if( $args{parsed}{hour} == 12 )
        {
            $args{parsed}{hour} = 0;
        }
        return 1;
    }
    elsif ( $ampm =~ m{p\.?m\.?}mix )
    {
        $args{parsed}{hour} += 12;
        if ( $args{parsed}{hour} == 24 )
        {
            $args{parsed}{hour} = 12;
        }
        return 1;
    }
    return 1;
}

sub _fix_year
{
    my %args = @_;
    return 1 if( length( $args{parsed}{year} ) == 4 );
    my $now = DateTime->now;
    $args{parsed}{year} = __PACKAGE__->_pick_year( $args{parsed}{year} , $now );
    return 1;
}

sub _pick_year
{
    my ( $self , $year , $dt ) = @_;

    if( $year > 69 )
    {
        if( $dt->strftime( '%y' ) > 69 )
        {
            $year = $dt->strftime( '%C' ) . sprintf( '%02s' , $year );
        }
        else
        {
            $year = $dt->subtract( years => 100 )->strftime( '%C' ) .
                    sprintf( '%02s' , $year );
        }
    }
    else
    {
        if( $dt->strftime( '%y' ) > 69 )
        {
            $year = $dt->add( years => 100 )->strftime( '%C' ) .
                    sprintf( '%02s' , $year );
        }
        else
        {
            $year = $dt->strftime( '%C' ) . sprintf( '%02s' , $year );
        }
    }
    return $year;
}

1;

__END__

=head1 NAME

DateTime::Format::Flexible - DateTime::Format::Flexible - Flexibly parse strings and turn them into DateTime objects.

=head1 SYNOPSIS

  use DateTime::Format::Flexible;
  my $dt = DateTime::Format::Flexible->parse_datetime( 'January 8, 1999' );
  # $dt = a DateTime object set at 1999-01-08T00:00:00

=head1 DESCRIPTION

If you have ever had to use a program that made you type in the date a certain
way and thought "Why can't the computer just figure out what date I wanted?",
this module is for you.

F<DateTime::Format::Flexible> attempts to take any string you give it and parse
it into a DateTime object.

The test file tests 2500+ variations of date/time strings.  If you can think of
any that I do not cover, please let me know.

=head1 USAGE

This module uses F<DateTime::Format::Builder> under the covers.

=head2 build, parse_datetime

build and parse_datetime do the same thing.  Give it a string and it
attempts to parse it and return a DateTime object.

If it can't it will throw an exception.

 my $dt = DateTime::Format::Flexible->build( $date );

 my $dt = DateTime::Format::Flexible->parse_datetime( $date );

A small list of supported formats:

=over 4

=item YYYYMMDDTHHMMSS

=item  YYYYMMDDTHHMM

=item  YYYYMMDDTHH

=item  YYYYMMDD

=item  YYYYMM

=item  MM-DD-YYYY

=item  MM-D-YYYY

=item  MM-DD-YY

=item  M-DD-YY

=item  YYYY/DD/MM

=item  YYYY/M/DD

=item  YYYY/MM/D

=item  M-D

=item  MM-D

=item  M-D-Y

=item  Month D, YYYY

=item  Mon D, YYYY

=item  Mon D, YYYY HH:MM:SS

=item  ...

=back

there are 2500+ variations that are detected correctly in the test files
(see t/data/tests.txt for most of them).

=head1 NOTES

The DateTime website http://datetime.perl.org/?Modules as of march 2008
lists this module under 'Confusing' and recommends the use of
F<DateTime::Format::Natural>.

Unfortunately I do not agree.  F<DateTime::Format::Natural> currently fails
more than 2000 of my parsing tests.  F<DateTime::Format::Flexible> supports
different types of date/time strings than F<DateTime::Format::Natural>.
I think there is utility in that can be found in both of them.

The whole goal of F<DateTime::Format::Flexible> is to accept just about
any crazy date/time string that a user might care to enter.
F<DateTime::Format::Natural> seems to be a little stricter in what it can
parse.

=head1 BUGS

You cannot use a 1 or 2 digit year as the first field:

 YY-MM-DD # not supported
 Y-MM-DD  # not supported

It would get confused with MM-DD-YY

It also prefers the US format of MM-DD over the European DD-MM.

It also does not support timezones.

=head1 AUTHOR

    Tom Heady
    CPAN ID: thinc
    Punch, Inc.
    cpan@punch.net
    http://www.punch.net/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

F<DateTime::Format::Builder>, F<DateTime::Format::Natural>

=cut

