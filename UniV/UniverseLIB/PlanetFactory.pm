#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::PlanetFactory;

use Modern::Perl '2013';
use MooseX::Singleton;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Log::Log4perl;
use Planet;


has 'logger' => (
	is => 'ro',
	isa => 'Log::Log4perl::Logger',
	traits   => [ 'DoNotSerialize' ],
);

has 'configs' => (
	is => 'ro',
	isa => 'HashRef',
);

has 'debug' => (
	is => 'rw',
	isa => 'Bool',
);


sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('planet');
}

sub make_planet {
	my $self=shift;
	my $args=shift;

	my $planet;
	$self->{config} = UniverseLIB::Configuration->instance->get_config('planet');
	$self->{debug}=1 if ($self->{config}->{debug});
	
	# Check for required parameters 
	return undef if (! $args->{loc} || ! $args->{sun});
	
	# Create Planet object
	$planet = UniverseLIB::Planet->new( logger=>$self->{logger},  
										my_sun=>$args->{sun}, 
										loc=>$args->{loc});

	# Fill in Planet object
	$planet->{name}=$args->{sun}->{name}." / " . "Planet " . $args->{loc}->{x} . "-" . $args->{loc}->{y};
			
	
	$planet->init();
	$planet->{debug}=$self->{debug};
	# return Planet
	return $planet;
}

__PACKAGE__->meta->make_immutable;
1;
