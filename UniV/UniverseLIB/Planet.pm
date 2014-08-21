#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Planet;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use MoonFactory; 
use Objects::Location;
use Objects::Space; 
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');

extends 'UniverseLIB::Objects::Space';

has 'class_type' => (
	is => 'rw',
	isa => 'Str',
);

has 'color' => (
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

has 'max_space' => (
	is => 'ro',
	isa => 'Int',
	default => 7,
);

sub init {
	my $self=shift;
	my $args=shift;
	my $max_space=8;
	
	my $moon_config = UniverseLIB::Configuration->instance->get_config('moon');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);

	my $factory = UniverseLIB::MoonFactory->instance; 	
	
	#create planet moon(s)
	for (my $x=1; $x < $self->{max_space}+1; $x++) {
			# Skip suns location
			next if ( $x == int(($self->{max_space}/2) + .5) );  # Planet is in the center
			next if (rand(100) < 80);
			my $loc = UniverseLIB::Objects::Location->new(x=>$x, y=>$x, z=>0);
			my $moon = $factory->make_moon({loc=>$loc, planet=>$self});
			$moon->{distince_x} = abs($self->{loc}->{x} - $moon->{loc}->{x});
			$moon->{distince_y} = abs($self->{loc}->{y} - $moon->{loc}->{y});
			$self->{moons}{"$x,$x,0"}=$moon;	
	} 	
	
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...")  if ($self->{debug});
	
	if ($self->{moons}) {
		foreach my $moon( keys ($self->{moons})) {
			$self->rotate_object($self->{moons}->{$moon}, {size_x=>$self->{max_space}, size_y=>$self->{max_space}});
			$self->{moons}->{$moon}->pulse();
		}
	}
	$self->display_planet();
}

sub display_planet {
	my $self=shift;
	my $object_count=0;
	my $max_x=$self->{max_space};
	my $max_y=$self->{max_space};
	my $center = int(($self->{max_space}/2) + .5);
	my @grid;
	
	for (my $x=1; $x < $max_x+1; $x++) {
		for (my $y=1; $y < $max_y+1; $y++) {
			$grid[$x][$y]=" . ";
			$grid[$x][$y]=" @ " if ($x == $center && $y == $center);
		}	
	}
	if ($self->{moons}) {
		foreach my $m( keys ($self->{moons})) {
			$object_count++;
			my $moon = $self->{moons}->{$m};
			$grid[$moon->{loc}->{x}][$moon->{loc}->{y}]=" $object_count ";
#			say "Adding $object_count " . $moon->{loc}->{x} . " - " . $moon->{loc}->{y};
		}
	}
	
	for (my $y=1; $y < $max_y+1; $y++) {
		for (my $x=1; $x < $max_x+1; $x++) {
			print $grid[$x][$y];
		}
		say "";	
	}
	
}
#sub validate_cords {
#	return 1 if ($_ % 2 == 1);
#	return 0;
#}

sub communicate {
	my $self=shift;
	my $msg=shift;
	my $display = "<" . $self->{name} . "-" . $self->{color} . "-" . $self->{class_type} . ">";
	$self->{logger}->info("$display $msg");
}

__PACKAGE__->meta->make_immutable;
1;
