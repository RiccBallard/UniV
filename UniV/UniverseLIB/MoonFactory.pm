#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::MoonFactory;

use Modern::Perl '2013';
use MooseX::Singleton;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Log::Log4perl;
use Moon;


has 'logger' => (
	is => 'ro',
	isa => 'Log::Log4perl::Logger',
	traits   => [ 'DoNotSerialize' ],
);

has 'moon_config' => (
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

has 'moon_size' => (
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

sub make_moon {
	my $self=shift;
	my $args=shift;

	my $moon;
	$self->{moon_config} = UniverseLIB::Configuration->instance->get_config('moon');
	$self->{factory_config} = UniverseLIB::Configuration->instance->get_config('moon_factory');
	
	if (@{$self->{color}} == 0) {
		@{ $self->{color} } = split (",", $self->{factory_config}->{color});
		@{ $self->{moon_size} } = split (",", $self->{factory_config}->{size});	
		@{ $self->{clazz_type} } = split (",", $self->{factory_config}->{class_type});
		@{ $self->{clazz_names} } = split (",", $self->{factory_config}->{class_names});
	}
	
	$self->{debug}=1 if ($self->{config}->{debug});
	
	# Check for required parameters 
	return undef if (! $args->{loc} || ! $args->{planet});
	
	# Create moon object
	$moon = UniverseLIB::Moon->new( logger=>$self->{logger},  
										my_planet=>$args->{planet}, 
										loc=>$args->{loc});

	# Fill in moon object
	$moon->{name}=$args->{planet}->{name}." / " . "Moon " . $args->{loc}->{x};
	
	$moon->{color} = $self->pick_color();	
	$moon->{size} = $self->pick_size();
	$moon->{class_type} = $self->pick_type();
	$moon->init();
	return $moon;
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
	
	my $total = @{$self->{moon_size}}-1;
	my $selection = int(rand($total));
	
	
	return $self->{moon_size}->[$selection];
}

sub pick_type {
	my $self=shift;
	my $args=shift;
	my $pick = rand(100);
	my $moon_type = "D";
	
	my $selection = int(rand(100));
	
	given ( $selection ) {
		when ( [0..29] ) {
			$moon_type = "D";
		}
		when ( [20..39] ) {
			$moon_type = "H";
		}
		when ( [40..45] ) {
			$moon_type = "J";
		}
		when ( [46..55] ) {
			$moon_type = "K";
		}
		when ( [56..60] ) {
			$moon_type = "L";
		}
		when ( [61..66] ) {
			$moon_type = "M";
		}
		when ( [67..79] ) {
			$moon_type = "N";
		}
		when ( [80..95] ) {
			$moon_type = "T";
		}
		default {
			$moon_type = "Y";
		}
	}	
#Class D	moonoid or moon; uninhabitable	Regula, Weytahn
#Class H	Generally uninhabitable	Tau Cygna V
#Class J	Gas giant	Jupiter, Saturn
#Class K	Adaptable with pressure domes	Mudd, Theta 116 VIII (class K transjovian)
#Class L	Marginally habitable	Indri VIII
#Class M	Terrestrial	Earth, Risa, Bajor
#Class N	Sulfuric	Venus
#Class T	Gas giant	
#Class Y	"Demon"	Silver Blood moon
}


__PACKAGE__->meta->make_immutable;
1;
