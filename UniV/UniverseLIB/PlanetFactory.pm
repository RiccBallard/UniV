#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::PlanetFactory;

use Modern::Perl '2013';
use MooseX::Singleton;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Log::Log4perl;
use Planet;


has 'logger' => (
	is => 'ro',
	isa => 'Log::Log4perl::Logger',
	traits   => [ 'DoNotSerialize' ],
);

has 'planet_config' => (
	is => 'ro',
	isa => 'HashRef',
);

has 'factory_config' => (
	is => 'ro',
	isa => 'HashRef',
);

has 'debug' => (
	is => 'rw',
	isa => 'Bool',
);

has 'color' => (
	is => 'rw',
	isa => 'ArrayRef',
	default => sub { [] },
);

has 'planet_size' => (
	is => 'rw',
	isa => 'ArrayRef',
	default => sub { [] },
);

has 'clazz_type' => (
	is => 'rw',
	isa => 'ArrayRef',
	default => sub { [] },
);

has 'clazz_names' => (
	is => 'rw',
	isa => 'ArrayRef',
	default => sub { [] },
);

sub make_planet {
	my $self=shift;
	my $args=shift;

	my $planet;
	$self->{planet_config} = UniverseLIB::Configuration->instance->get_config('planet');
	$self->{factory_config} = UniverseLIB::Configuration->instance->get_config('planet_factory');
	
	if (@{$self->{color}} == 0) {
		@{ $self->{color} } = split (",", $self->{factory_config}->{color});
		@{ $self->{planet_size} } = split (",", $self->{factory_config}->{size});	
		@{ $self->{clazz_type} } = split (",", $self->{factory_config}->{class_type});
		@{ $self->{clazz_names} } = split (",", $self->{factory_config}->{class_type});
	}
	
	$self->{debug}=1 if ($self->{config}->{debug});
	
	# Check for required parameters 
	return undef if (! $args->{loc} || ! $args->{sun});
	
	# Create Planet object
	$planet = UniverseLIB::Planet->new( logger=>$self->{logger},  
										my_sun=>$args->{sun}, 
										loc=>$args->{loc});

	# Fill in Planet object
	$planet->{name}=$args->{sun}->{name}." / " . "Planet " . $args->{loc}->{x} . "-" . $args->{loc}->{y};
			
	say "     Color is: " . $self->pick_color();
	say "      Size is: " . $self->pick_size();
	say "Class Type is: " . $self->pick_type();
	
	$planet->init();
	$planet->{debug}=$self->{debug};
	# return Planet
	return $planet;
}

sub pick_color {
	my $self=shift;
	my $args=shift;
	
	my $total = @{$self->{color}}-1;
	my $selection = int(rand($total));
	
	return $self->{color}->[$selection];
}

sub pick_size {
	my $self=shift;
	my $args=shift;
	
	my $total = @{$self->{planet_size}}-1;
	my $selection = int(rand($total));
	
	
	return $self->{planet_size}->[$selection];
}

sub pick_type {
	my $self=shift;
	my $args=shift;
	my $pick = rand(100);
	my $planet_type = "D";
	
	my $selection = int(rand(100));
	
	given ( $selection ) {
		when ( [0..29] ) {
			$planet_type = "D";
		}
		when ( [20..39] ) {
			$planet_type = "H";
		}
		when ( [40..45] ) {
			$planet_type = "J";
		}
		when ( [46..55] ) {
			$planet_type = "K";
		}
		when ( [56..60] ) {
			$planet_type = "L";
		}
		when ( [61..66] ) {
			$planet_type = "M";
		}
		when ( [67..79] ) {
			$planet_type = "N";
		}
		when ( [80..95] ) {
			$planet_type = "T";
		}
		default {
			$planet_type = "Y";
		}
	}	
#Class D	Planetoid or moon; uninhabitable	Regula, Weytahn
#Class H	Generally uninhabitable	Tau Cygna V
#Class J	Gas giant	Jupiter, Saturn
#Class K	Adaptable with pressure domes	Mudd, Theta 116 VIII (class K transjovian)
#Class L	Marginally habitable	Indri VIII
#Class M	Terrestrial	Earth, Risa, Bajor
#Class N	Sulfuric	Venus
#Class T	Gas giant	
#Class Y	"Demon"	Silver Blood planet
}


__PACKAGE__->meta->make_immutable;
1;
