#!/home/rballard/perl5/perlbrew/perls/current/bin/perl
package UniverseLIB::Configuration;

use Modern::Perl '2013';
use MooseX::Singleton;
use Moose::Util::TypeConstraints;
use Data::Dumper;
use Log::Log4perl;
use MooseX::Storage;
our $VERSION = '0.01';  
with Storage('format' => 'JSON', 'io' => 'File');

has 'filename' => (
	is => 'rw',
	isa => 'Str',
);

has 'logger' => (
	is => 'ro',
	isa => 'Log::Log4perl::Logger',
	traits   => [ 'DoNotSerialize' ],
);

has 'configs' => (
	is => 'ro',
	isa => 'HashRef',
);

sub load {
	my $self=shift;
	my $args=shift;
	
	if (-f $self->{filename}) {
		print "Initializing Configuration...";
		my $main_config=create_config($self->{filename});
		$self->{configs}{$main_config->{name}}=$main_config;
		my $main_name=$main_config->{name};
		foreach my $configuration (keys ($main_config)) {
			print ".";
			next if ($configuration eq 'name');
			my $load_config=create_config($main_config->{$configuration});
			$self->{configs}{$configuration}=$load_config;
		}
	} else {
		die "filename not correct!";	
	}
	say "done!";
}

sub create_config {
	my $filename=shift;
	
	if (-f $filename) {
		my $yaml = YAML::Tiny->read($filename) || die "could not find config file ". $filename;
		my $config=$yaml->[0]->{config};
		return $config;
	}
	
	return undef;
}

sub get_config {
	my $self=shift;
	my $config_name=shift;
	
	$self->load() if (!$self->{configs});
	
	my $configs = $self->{configs};
	if (exists $configs->{$config_name} ) {
		return $configs->{$config_name};
	}
	
	return undef;
}
__PACKAGE__->meta->make_immutable;
1;
