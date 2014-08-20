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

sub validate_cords {
	my $self=shift;
	my $parm=shift;
	return 1 if ($parm % 2 == 1);
	return 0;
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self]);
}

1;