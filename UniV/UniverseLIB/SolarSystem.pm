#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::SolarSystem;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use POSIX;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Objects::Location;
use Objects::Space;
use Sun;
use MooseX::Storage;
our $VERSION = '0.01';
with Storage('format' => 'JSON', 'io' => 'File');

extends 'UniverseLIB::Objects::Space';

has 'sun' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::Sun]', 
);

has 'in_galaxy' => (
	is => 'rw',
	isa => 'UniverseLIB::Galaxy',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('solarsystem');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);
	my $planet_config = UniverseLIB::Configuration->instance->get_config('planet');
	
	die "invalid x in " . $planet_config->{name} if ( ! $self->validate_cords( $planet_config->{size_x} ));
	die "invalid y in " . $planet_config->{name} if ( ! $self->validate_cords( $planet_config->{size_y} ));
	
	my $sun_x = ceil($planet_config->{size_x}/2);
	my $sun_y = ceil($planet_config->{size_y}/2);
	my $loc = UniverseLIB::Objects::Location->new(x=>$sun_x, y=>$sun_y, z=>0);
	my $sun = UniverseLIB::Sun->new( logger=>$self->{logger}, name=>"Sun $sun_x-$sun_y", my_solar_system=>$self, loc=>$loc);
	$sun->{name}=$self->{name}." / " . $sun->{name};
	$sun->init();
	$self->{sun}{"$sun_x,$sun_y,0"}=$sun;
	
	 	
}

sub pulse {
	my $self=shift;
	$self->communicate("Scanning Solar System...")  if ($self->{debug});
	foreach my $sun( keys ($self->{sun})) {
		$self->{sun}->{$sun}->pulse();
	}
}


__PACKAGE__->meta->make_immutable;
1;
