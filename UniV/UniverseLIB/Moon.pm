#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Moon;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Location; 

has 'loc' => (
	is => 'rw',
	isa => 'UniverseLIB::Location',
);

has 'name' => (
	is => 'rw',
	isa => 'Str',
);

has 'logger' => (
	is => 'rw',
	isa => 'Log::Log4perl::Logger',
	traits   => [ 'DoNotSerialize' ],
);

has 'my_planet' => (
	is => 'ro',
	isa =>'HashRef[UniverseLIB::Planet]',
);

sub init {
	my $self=shift;
	my $args=shift;
}

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
__PACKAGE__->meta->make_immutable;
1;
