#!/home/rballard/perl5/perlbrew/perls/current/bin/perl

package  UniverseLIB::Univ_daemon;

# use Modern::Perl '2013';

use Data::Dumper;
use Moose;

with qw(MooseX::Daemonize);
 

has 'process_obj' => (
	is => 'ro',
	isa => 'UniverseLIB::Universe',
);

after 'start' => sub {
    my $self=shift;
    return unless $self->is_daemon();
    while(1) { 
    	$self->{process_obj}->pulse(); 
    	sleep(10); 
    }
}

