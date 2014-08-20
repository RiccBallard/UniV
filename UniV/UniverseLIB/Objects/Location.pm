#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Objects::Location;

use strict;
use Modern::Perl '2013';
use IO::File;
use Data::Dumper;
use Log::Log4perl;
use Moose;


has 'x' => (
	is => 'rw',
	isa => 'Int',
	);

has 'y' => (
	is => 'rw',
	isa => 'Int',
	);

has 'z' => (
	is => 'rw',
	isa => 'Int',
	);
	
1;
