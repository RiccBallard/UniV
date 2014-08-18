#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Universe;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Location;  
use Galaxy; 
use Configuration;
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
	required => 0,
);

has 'name' => (
	is => 'rw',
	isa => 'Str',
	required => 0,
	);

has 'galaxies' => (
	is => 'rw',
	isa => 'HashRef[UniverseLIB::Galaxy]',
	required => 0, 
);

has 'logger' => (
	is => 'rw',
	isa => 'Log::Log4perl::Logger',
	traits   => [ 'DoNotSerialize' ],
	required => 1,
);

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
	required => 0,
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('galaxy');
	$self->{name} = "Universe";
	die "invalid x in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_x} ));
	die "invalid y in " . $self->{name} if ( ! validate_cords( $self->{config}->{size_y} ));
	
	#create Galaxies
	for (my $x=1; $x < ($self->{config}->{size_x}+1); $x++) {
		for (my $y=1; $y < ($self->{config}->{size_y}+1); $y++) {
			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
			my $gal = UniverseLIB::Galaxy->new( logger=>$self->{logger}, name=>"Galaxy $x-$y", in_universe=>$self, loc=>$loc);
			$gal->init();
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

sub validate_cords {
	my $parm=shift;
#	return 1 if ($parm % 2 == 1);
	if ($parm % 2 == 1) {
		return 1;
	}
	return 0;
}

sub communicate {
	my $self=shift;
	my $msg=shift;
	$self->{logger}->info("<" . $self->{name} . "> $msg");
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self->{galaxies}]);
}
__PACKAGE__->meta->make_immutable;
1;
