#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::SolarSystem;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use POSIX;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Location;
use Sun;
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

has 'sun' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::Sun]', 
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
	die "invalid x in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_x} ));
	die "invalid y in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_y} ));
	
	my $sun_x = ceil($self->{config}->{size_x}/2);
	my $sun_y = ceil($self->{config}->{size_y}/2);
	my $loc = UniverseLIB::Location->new(x=>$sun_x, y=>$sun_y, z=>0);
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

sub validate_cords {
	my $parm=shift;
	return 1 if ($parm % 2 == 1);
	return 0;
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
