#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Moon;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Objects::Space;
use Objects::Location; 

extends 'UniverseLIB::Objects::Space';

has 'my_planet' => (
	is => 'ro',
	isa =>'UniverseLIB::Planet',
);

sub init {
	my $self=shift;
	my $args=shift;
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...");
	

}

__PACKAGE__->meta->make_immutable;
1;
