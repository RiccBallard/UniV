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
#use Galaxy;
use MooseX::Storage;
our $VERSION = '0.01';
with Storage('format' => 'JSON', 'io' => 'File');

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
	traits   => [ 'DoNotSerialize' ],
);

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
);

has 'in_galaxy' => (
	is => 'rw',
	isa => 'UniverseLIB::Galaxy',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('planet');
		
	#create solar systems
	for (my $x=0; $x < $self->{config}->{size_x}; $x++) {
		for (my $y=0; $y < $self->{config}->{size_y}; $y++) {
			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
			my $planet = UniverseLIB::Planet->new( logger=>$self->{logger}, name=>"Planet $x-$y", loc=>$loc);
			$planet->{name}=$self->{name}." / " . $planet->{name};
			$planet->init();
			$self->{planets}{"$x,$y,0"}=$planet;
		}	
	} 	
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...");
	foreach my $planet( keys ($self->{planets})) {
		$self->{planets}->{$planet}->pulse();
	}
}

sub communicate {
	my $self=shift;
	my $msg=shift;
	$self->{logger}->info("<" . $self->{name} . "> $msg");
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self->{planets}]);
}
__PACKAGE__->meta->make_immutable;
1;
