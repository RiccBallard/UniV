#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Objects::Space;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Configuration;
use Objects::Common;
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');

extends 'UniverseLIB::Objects::Common';

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
	required => 0,
);

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...");
}

sub communicate {
	my $self=shift;
	my $msg=shift;
	$self->{logger}->info("<" . $self->{name} . "> $msg");
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self]);
}

1;