#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Planet;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
#use Galaxy; 
use Location; 
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');

has 'debug' => (
	is => 'rw',
	isa => 'Bool',
);

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

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
);

has 'class_type' => (
	is => 'rw',
	isa => 'Str',
);

has 'size' => (
	is => 'rw',
	isa => 'Int',
);

has 'moon_cnt' => (
	is => 'rw',
	isa => 'Int',
);

has 'moons' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::Moon]',
);

has 'my_sun' => (
	is => 'ro',
	isa => 'UniverseLIB::Sun',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('planet');
	my $moon_config = UniverseLIB::Configuration->instance->get_config('moon');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);
#	die "invalid x in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_x} ));
#	die "invalid y in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_y} ));
	
	# TODO: add moon or moons to planets
	
#	$self->{name}=$self->{in_solarsystem}->{name}." / " . $self->{name};
	
	# TODO: add size, color, class of planet
	#create solar systems
#	for (my $x=0; $x < $galaxy_config->{size}; $x++) {
#		for (my $y=0; $y < $galaxy_config->{size}; $y++) {
#			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
#			my $gal = UniverseLIB::Galaxy->new( logger=>$self->{logger}, config=>$self->{config}, name=>"x=$x y=$y", loc=>$loc);
#			$self->{galaxies}{"$x,$y,0"}=$gal;
#		}	
#	} 	
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...")  if ($self->{debug});
#	foreach my $moon( keys ($self->{moons})) {
#		$self->{moons}->{$moon}->pulse();
#	}
}

sub validate_cords {
	return 1 if ($_ % 2 == 1);
	return 0;
}

sub communicate {
	my $self=shift;
	my $msg=shift;
	$self->{logger}->info("<" . $self->{name} . "> $msg");
}

#sub store_me {
#	my $self=shift;
#	
#	$self->freeze();
#	$self->store('planet.json'); 
#}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self]);
}
__PACKAGE__->meta->make_immutable;
1;
