#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Universe;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Objects::Location;
use Objects::Space;  
use Galaxy; 
use Configuration;
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');

extends 'UniverseLIB::Objects::Space';

has 'galaxies' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::Galaxy]',
	required => 0, 
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('universe');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);
	my $galaxy_config = UniverseLIB::Configuration->instance->get_config('galaxy');
	$self->{name} = "Universe";
	die "invalid x in " . $galaxy_config->{name} if ( ! $self->validate_cords( $galaxy_config->{size_x} ));
	die "invalid y in " . $galaxy_config->{name} if ( ! $self->validate_cords( $galaxy_config->{size_y} ));
	
	#create Galaxies
	for (my $x=1; $x < ($galaxy_config->{size_x}+1); $x++) {
		for (my $y=1; $y < ($galaxy_config->{size_y}+1); $y++) {
			my $loc = UniverseLIB::Objects::Location->new(x=>$x, y=>$y, z=>0);
			my $gal = UniverseLIB::Galaxy->new( logger=>$self->{logger}, name=>$galaxy_config->{name} . " $x-$y", in_universe=>$self, loc=>$loc);
			$gal->init();
			$gal->{debug}=$galaxy_config->{debug};
			$self->{galaxies}{"$x,$y,0"}=$gal;
		}	
	} 	
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...") if ($self->{debug});
	foreach my $galaxy( keys ($self->{galaxies})) {
		$self->{galaxies}->{$galaxy}->pulse();
	}
}

sub store_me {
	my $self=shift;
	
	$self->freeze();
	$self->store('./data/universe.json');
}

sub load_me {
	my $self=shift;
	
	$self = Universe->load('./data/universe.json');
}

#sub communicate {
#	my $self=shift;
#	my $msg=shift;
#	$self->{logger}->info("<" . $self->{name} . "> $msg");
#}

__PACKAGE__->meta->make_immutable;
1;
