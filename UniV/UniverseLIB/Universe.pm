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
	my $hash_ref=\%{$self};
	
	#create Galaxies
	for (my $x=0; $x < $self->{config}->{size_x}; $x++) {
		for (my $y=0; $y < $self->{config}->{size_y}; $y++) {
			my $loc = UniverseLIB::Location->new(x=>$x, y=>$y, z=>0);
			my $gal = UniverseLIB::Galaxy->new( logger=>$self->{logger}, name=>"Galaxy $x-$y", in_universe=>$self, loc=>$loc);
			$gal->init();
			$self->{galaxies}{"$x,$y,0"}=$gal;
		}	
	} 	
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...");
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
