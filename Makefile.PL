
use strict;
use warnings;

BEGIN { require 5.006; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A simple way to send structured log messages via UDP',
  'AUTHOR' => 'Robin Smidsrød <robin@smidsrod.no>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'JSON' => '0',
    'Test::More' => '0',
    'Time::HiRes' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Log-UDP-Client',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Log::UDP::Client',
  'PREREQ_PM' => {
    'Carp' => '0',
    'Data::Serializable' => '0.40.0',
    'IO::Socket::INET' => '0',
    'Moose' => '0'
  },
  'VERSION' => '0.20.0',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



