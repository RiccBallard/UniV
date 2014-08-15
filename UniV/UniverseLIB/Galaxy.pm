#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Galaxy;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Location; 
use SolarSystem; 

has 'loc' => (
	is => 'rw',
	isa => 'UniverseLIB::Location',
);

has 'name' => (
	is => 'rw',
	isa => 'Str',
	);

has 'solarsystems' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::SolarSystem]', 
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
	
	my $yaml = YAML::Tiny->read($self->{config}->{solarsystem}) || die "could not find config file " . $self->{config}->{solarsystem};
	my $ss_config = $yaml->[0]->{config};
	
	#create solar systems
	for (my $x=0; $x < $ss_config->{size_x}; $x++) {
		for (my $y=0; $y < $ss_config->{size_y}; $y++) {
			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
			my $ss = UniverseLIB::SolarSystem->new( logger=>$self->{logger}, config=>$self->{config}, name=>"x=$x y=$y", loc=>$loc);
			$ss->init();
			$self->{solarsystems}{"$x,$y,0"}=$ss;
		}	
	} 	
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self->{solarsystems}]);
}
__PACKAGE__->meta->make_immutable;
1;
