#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::SolarSystem;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Location; 
use Planet;

has 'loc' => (
	is => 'rw',
	isa => 'UniverseLIB::Location',
);

has 'name' => (
	is => 'rw',
	isa => 'Str',
	);

has 'planets' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::Planet]', 
);

has 'logger' => (
	is => 'rw',
	isa => 'Log::Log4perl::Logger',
);

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	my $yaml = YAML::Tiny->read($self->{config}->{planet}) || die "could not find config file " . $self->{config}->{planet};
	my $planet_config = $yaml->[0]->{config};
	
	#create solar systems
	for (my $x=0; $x < $planet_config->{size_x}; $x++) {
		for (my $y=0; $y < $planet_config->{size_y}; $y++) {
			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
			my $planet = UniverseLIB::Planet->new( logger=>$self->{logger}, config=>$self->{config}, name=>"x=$x y=$y", loc=>$loc);
			$planet->init();
			$self->{planets}{"$x,$y,0"}=$planet;
		}	
	} 	
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self->{planets}]);
}
__PACKAGE__->meta->make_immutable;
1;
