#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Objects::Space;

use Modern::Perl '2013';
use Data::Dumper;
use Log::Log4perl;
use Moose;
use Moose::Util::TypeConstraints;

use namespace::autoclean;
use Configuration;
use Objects::Common;
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');

extends 'UniverseLIB::Objects::Common';

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
	required => 0,
);

sub pulse {
	my $self=shift;
	$self->communicate("nudging life...");
}

sub communicate {
	my $self=shift;
	my $msg=shift;
	$self->{logger}->info("<" . $self->{name} . "> $msg");
}

sub validate_cords {
	my $self=shift;
	my $parm=shift;
	return 1 if ($parm % 2 == 1);
	return 0;
}

sub rotate_object {
	my $self=shift;
	my $spaceObj=shift;
	my $around=shift;
	
	my $max_x = $around->{size_x};
	my $max_y = $around->{size_y};

	my $center_x = int(($around->{size_x}/2) + .5);
	my $center_y = int(($around->{size_y}/2) + .5);
	
	my $spaceObj_x = $spaceObj->{loc}->{x};
	my $spaceObj_y = $spaceObj->{loc}->{y};
		
#	say "system size is $max_x, $max_y";
#	say "sun is at $center_x, $center_y";
#	say "planet is at $spaceObj_x, $spaceObj_y";
#	say "distince x = $distince_x";
#	say "distince y = $distince_y";
	
	# if planet is above the sun move right or down
	if ($spaceObj_y < $center_y) {
		my $now_dy = abs($center_y-$spaceObj_y);
		if ($now_dy < $spaceObj->{distince_y} && $spaceObj_x < $center_x) {
			$spaceObj_y--;
		} else {
			$spaceObj_x++;				
		}
		my $now_dx = abs($center_x-$spaceObj_x);
		if ($now_dx > $spaceObj->{distince_x}) {
			$spaceObj_x--;
			$spaceObj_y++;
		}
	# if planet is below the sun move down or left		
	} elsif ($spaceObj_y > $center_y) {
		my $now_dy = abs($center_y-$spaceObj_y);
		if ($now_dy < $spaceObj->{distince_y} && $spaceObj_x > $center_x) {
			$spaceObj_y++;
		} else {
			$spaceObj_x--;
		}	
		my $now_dx = abs($center_x-$spaceObj_x);
		if ($now_dx > $spaceObj->{distince_x}) {
			$spaceObj_x++;
			$spaceObj_y--;
		}
	# if planet is on level with the sun move down if past or up if in front of		
	} elsif ($spaceObj_y == $center_y) {
		if ($spaceObj_x > $center_x) {
			$spaceObj_y++;	
		}
		if ($spaceObj_x < $center_x) {
			$spaceObj_y--;	
		}
	}
	 
#	say "planet moved to $spaceObj_x, $spaceObj_y";
	$spaceObj->{loc}->{x}=$spaceObj_x;
	$spaceObj->{loc}->{y}=$spaceObj_y;
}

sub dumpme {
	my $self=shift;
	
	say Data::Dumper->Dump([$self]);
}

1;