#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Galaxy;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Objects::Location;
use Objects::Space;  
use SolarSystem; 
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');
  
extends 'UniverseLIB::Objects::Space';
  

has 'solarsystems' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::SolarSystem]', 
);


has 'in_universe' => (
	is => 'rw',
	isa => 'UniverseLIB::Universe',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('galaxy');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);
	my $solar_system = UniverseLIB::Configuration->instance->get_config('solarsystem');
	
	die "invalid x in Galaxy" if ( ! $self->validate_cords( $solar_system->{size_x} ));
	die "invalid y in Galaxy" if ( ! $self->validate_cords( $solar_system->{size_y} ));
	
	#create solar systems
	for (my $x=1; $x < ($solar_system->{size_x}+1); $x++) {
		for (my $y=1; $y < ($solar_system->{size_y}+1); $y++) {
			my $loc = UniverseLIB::Objects::Location->new(x=>$x, y=>$y, z=>0);
			my $ss = UniverseLIB::SolarSystem->new( logger=>$self->{logger}, name=>$solar_system->{name}. " $x-$y", in_galaxy=>$self, loc=>$loc);
			$ss->{name}=$self->{name}." / " . $ss->{name};
			$ss->init();
			$self->{solarsystems}{"$x,$y,0"}=$ss;
		}	
	} 	
} 

#sub validate_cords {
#	my $parm=shift;
#	return 1 if ($parm % 2 == 1);
#	return 0;
#}

sub pulse {
	my $self=shift;
	$self->communicate("Scanning Galaxy life...")  if ($self->{debug});
	foreach my $solarsystem( keys ($self->{solarsystems})) {
		$self->{solarsystems}->{$solarsystem}->pulse();
	}
}

#sub communicate {
#	my $self=shift;
#	my $msg=shift;
#	$self->{logger}->info("<" . $self->{name} . "> $msg");
#}

sub save_solarsystem {
	
}

__PACKAGE__->meta->make_immutable;
1;
