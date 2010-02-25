

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'DateTime::Format::Flexible',
    VERSION_FROM => 'lib/DateTime/Format/Flexible.pm',
    AUTHOR       => 'Tom Heady (cpan@punch.net)',
    LICENSE      => 'perl',
    ABSTRACT     => 'DateTime::Format::Flexible - Flexibly parse strings and turn them into DateTime objects.',
    PREREQ_PM    => {
        'Test::Simple'              => 0.44, # <-- auto added for tests
        'Readonly'                  => 0.06, # Add Readonly function
        'DateTime::Format::Builder' => 0.74, # length parameter can now be an arrayref
        'DateTime'                  => 0,
        'DateTime::TimeZone'        => 0,
        'Module::Pluggable'         => 0,
        'List::MoreUtils'           => 0,
    },
);
