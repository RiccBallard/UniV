#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Sun;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Storage;
our $VERSION = '0.01';
with Storage('format' => 'JSON', 'io' => 'File');

use namespace::autoclean;
use Objects::Location; 
use Objects::Space;
use Planet; 

extends 'UniverseLIB::Objects::Space';

has 'planets' => (
	is => 'ro',
	isa =>'HashRef[UniverseLIB::Planet]',
);

has 'my_solar_system' => (
	is => 'rw',
	isa => 'UniverseLIB::SolarSystem',
);

has 'distince_x' => (
	is => 'ro',
	isa => 'Int',
);

has 'distince_y' => (
	is => 'ro',
	isa => 'Int',
);

sub init {
	my $self=shift;
	my $args=shift;
	
	$self->{config} = UniverseLIB::Configuration->instance->get_config('planet');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);
	die "invalid x in " . $self->{name} if ( ! $self->validate_cords( $self->{config}->{size_x} ));
	die "invalid y in " . $self->{name} if ( ! $self->validate_cords( $self->{config}->{size_y} ));
	
	# TODO: add size and type of sun
	my $planet_factory = UniverseLIB::PlanetFactory->instance;
	
	#create solar systems
	for (my $x=1; $x < ($self->{config}->{size_x}+1); $x++) {
			# Skip suns location
			next if ( ($x == $self->{loc}->{x}) && ($x == $self->{loc}->{y}));
#			next if (rand(100) < 75);
			my $loc = UniverseLIB::Objects::Location->new(x=>$x, y=>$x, z=>0);
			my $planet = $planet_factory->make_planet({loc=>$loc, sun=>$self});
			$planet->{distince_x} = abs($self->{loc}->{x} - $planet->{loc}->{x});
			$planet->{distince_y} = abs($self->{loc}->{y} - $planet->{loc}->{y});
			$self->{planets}{"$x,$x,0"}=$planet;	
	} 	
	
}

sub pulse {
	my $self=shift;
	$self->communicate("Moving planets...")  if ($self->{debug});
	
	# Logic to move planets around its sun
	# TODO: add moving logic pf planets
	if ($self->{planets}) {
		foreach my $planet( keys ($self->{planets})) {
#			say "pulsing for planet at " . $self->{planets}->{$planet}->{loc}->{x} . " - " .$self->{planets}->{$planet}->{loc}->{y}; 
			$self->adjust_locations($self->{planets}->{$planet});
			$self->{planets}->{$planet}->pulse();
		}
	}
	$self->display_solar_system();
}

sub adjust_locations {
	my $self=shift;
	my $planet=shift;
	
	my $max_x = $self->{config}->{size_x};
	my $max_y = $self->{config}->{size_y};

	my $center_x = $self->{loc}->{x};
	my $center_y = $self->{loc}->{y};
	
	my $planet_x = $planet->{loc}->{x};
	my $planet_y = $planet->{loc}->{y};
		
#	say "system size is $max_x, $max_y";
#	say "sun is at $center_x, $center_y";
#	say "planet is at $planet_x, $planet_y";
#	say "distince x = $distince_x";
#	say "distince y = $distince_y";
	
	# if planet is above the sun move right or down
	if ($planet_y < $center_y) {
		my $now_dy = abs($center_y-$planet_y);
		if ($now_dy < $planet->{distince_y} && $planet_x < $center_x) {
			$planet_y--;
		} else {
			$planet_x++;				
		}
		my $now_dx = abs($center_x-$planet_x);
		if ($now_dx > $planet->{distince_x}) {
			$planet_x--;
			$planet_y++;
		}
	# if planet is below the sun move down or left		
	} elsif ($planet_y > $center_y) {
		my $now_dy = abs($center_y-$planet_y);
		if ($now_dy < $planet->{distince_y} && $planet_x > $center_x) {
			$planet_y++;
		} else {
			$planet_x--;
		}	
		my $now_dx = abs($center_x-$planet_x);
		if ($now_dx > $planet->{distince_x}) {
			$planet_x++;
			$planet_y--;
		}
	# if planet is on level with the sun move down if past or up if in front of		
	} elsif ($planet_y == $center_y) {
		if ($planet_x > $center_x) {
			$planet_y++;	
		}
		if ($planet_x < $center_x) {
			$planet_y--;	
		}
	}
	 
#	say "planet moved to $planet_x, $planet_y";
	$planet->{loc}->{x}=$planet_x;
	$planet->{loc}->{y}=$planet_y;
}

sub display_solar_system {
	my $self=shift;
	my $planet_count=0;
	my $max_x=$self->{config}->{size_x}+1;
	my $max_y=$self->{config}->{size_y}+1;
	my @grid;
	
	for (my $x=1; $x < $max_x; $x++) {
		for (my $y=1; $y < $max_y; $y++) {
			$grid[$x][$y]=" . ";
			$grid[$x][$y]=" * " if ($x == $self->{loc}->{x} && $y == $self->{loc}->{y});
		}	
	}
	if ($self->{planets}) {
		foreach my $p( keys ($self->{planets})) {
			$planet_count++;
			my $planet = $self->{planets}->{$p};
			$grid[$planet->{loc}->{x}][$planet->{loc}->{y}]=" $planet_count ";
#			say "Adding $planet_count " . $planet->{loc}->{x} . " - " . $planet->{loc}->{y};
		}
	}
	
	for (my $y=1; $y < $max_y; $y++) {
		for (my $x=1; $x < $max_x; $x++) {
			print $grid[$x][$y];
		}
		say "";	
	}
	
}

#sub validate_cords {
#	my $parm=shift;
#	return 1 if ($parm % 2 == 1);
#	return 0;
#}

__PACKAGE__->meta->make_immutable;
1;
