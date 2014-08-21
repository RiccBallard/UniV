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

sub init {
	my $self=shift;
	my $args=shift;
	
	my $moon_config = UniverseLIB::Configuration->instance->get_config('moon');
	$self->{debug} = $self->{config}->{debug} if (! $self->debug);

	my $factory = UniverseLIB::MoonFactory->instance; 	
	
	#create planet moon(s)
	for (my $x=1; $x < 8; $x++) {
			# Skip suns location
			next if ( ($x == $self->{loc}->{x}) && ($x == $self->{loc}->{y}));
			next if (rand(100) < 80);
			my $loc = UniverseLIB::Objects::Location->new(x=>$x, y=>$x, z=>0);
			my $moon = $factory->make_moon({loc=>$loc, planet=>$self});
			$moon->{distince_x} = abs($self->{loc}->{x} - $moon->{loc}->{x});
			$moon->{distince_y} = abs($self->{loc}->{y} - $moon->{loc}->{y});
			$self->{planets}{"$x,$x,0"}=$moon;	
	} 	
	
}

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...")  if ($self->{debug});
#	foreach my $moon( keys ($self->{moons})) {
#		$self->{moons}->{$moon}->pulse();
#	}
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
