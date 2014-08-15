#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Planet;

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
);

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
);

sub init {
	my $self=shift;
	my $args=shift;
#	
#	my $yaml = YAML::Tiny->read($self->{config}->{galaxy}) || die "could not find config file " . $self->{config}->{galaxy};
#	my $galaxy_config = $yaml->[0]->{config};
	
	#create solar systems
#	for (my $x=0; $x < $galaxy_config->{size}; $x++) {
#		for (my $y=0; $y < $galaxy_config->{size}; $y++) {
#			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
#			my $gal = UniverseLIB::Galaxy->new( logger=>$self->{logger}, config=>$self->{config}, name=>"x=$x y=$y", loc=>$loc);
#			$self->{galaxies}{"$x,$y,0"}=$gal;
#		}	
#	} 	
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self]);
}
__PACKAGE__->meta->make_immutable;
1;
