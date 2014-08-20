#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Objects::Common;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Objects::Location; 

has 'loc' => (
	is => 'rw',
	isa => 'UniverseLIB::Objects::Location',
);

has 'name' => (
	is => 'rw',
	isa => 'Str',
);

has 'logger' => (
	is => 'rw',
	isa => 'Log::Log4perl::Logger',
);

has 'debug' => (
	is => 'rw',
	isa => 'Bool',
);


__PACKAGE__->meta->make_immutable;
1;
