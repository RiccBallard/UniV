#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Sun;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Storage;
our $VERSION = '0.01';
with Storage('format' => 'JSON', 'io' => 'File');

use namespace::autoclean;
use Objects::Location; 
use Objects::Space;
use Planet; 

extends 'UniverseLIB::Objects::Space';

has 'planets' => (
	is => 'ro',
	isa =>'HashRef[UniverseLIB::Planet]',
);

has 'my_solar_system' => (
	is => 'rw',
	isa => 'UniverseLIB::SolarSystem',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('planet');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);
	die "invalid x in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_x} ));
	die "invalid y in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_y} ));
	
	# TODO: add size and type of sun
	my $planet_factory = UniverseLIB::PlanetFactory->instance;
	
	#create solar systems
	for (my $x=1; $x < ($self->{config}->{size_x}+1); $x++) {
		for (my $y=1; $y < ($self->{config}->{size_y}+1); $y++) {
			# Skip suns location
			next if ( ($x == $self->{loc}->{x}) && ($y == $self->{loc}->{y}));
			next if (rand(100) < 75);
			my $loc = UniverseLIB::Objects::Location->new(x=>$x, y=>$y, z=>0);
#			my $planet = UniverseLIB::Planet->new( logger=>$self->{logger}, name=>"Planet $x-$y", my_sun=>$self, loc=>$loc);
			my $planet = $planet_factory->make_planet({loc=>$loc, sun=>$self});
			$self->{planets}{"$x,$y,0"}=$planet;
		}	
	} 	
	
}

sub pulse {
	my $self=shift;
	$self->communicate("Moving planets...")  if ($self->{debug});
	
	# Logic to move planets around its sun
	# TODO: add moving logic pf planets
	if ($self->{planets}) {
		foreach my $planet( keys ($self->{planets})) {
			$self->{planets}->{$planet}->pulse();
		}
	}
}

sub validate_cords {
	my $parm=shift;
	return 1 if ($parm % 2 == 1);
	return 0;
}

__PACKAGE__->meta->make_immutable;
1;
