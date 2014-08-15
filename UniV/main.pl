#!/home/rballard/perl5/perlbrew/perls/current/bin/perl

#push @INC, "./lib/";

use strict;
use Modern::Perl '2013';
use Getopt::Long;
use IO::File;
use IO::Prompt;
use Data::Dumper;
use YAML::Tiny;
use File::Basename;
use Log::Log4perl;
use UniverseLIB::Universe;
  
# Initialize Logger
my $log_conf = "./configs/log4perl.conf";
 
Log::Log4perl::init($log_conf);
 
my $logger = Log::Log4perl->get_logger();
 
# sample logging statement
$logger->info("Starting Univ Engine");


my ( $debug, $verbose, $force, $configFname, $HOSTNAME );
GetOptions(
			"debug"    => \$debug,
			"verbose"  => \$verbose,
			"c=s"      => \$configFname,
			"config=s" => \$configFname,
			"hostname=s" => \$HOSTNAME,
);

display_env();

my $config = init( "./configs/project.yml" );
my $universe_config = $config->{universe};
my $galaxy_config = $config->{galaxy};
my $solar_system_config = $config->{solarsystem};

my $universe_obj = UniverseLIB::Universe->new( config=>$config, logger=>$logger );
$universe_obj->init();
say "Universe:" . Data::Dumper->Dump([$universe_obj]);
#$universe_obj->dumpme();

$logger->info("Hello Universe how are you!");

exit(0);


####################################

sub init {
	my $configFname = shift;
	my $yaml = YAML::Tiny->read($configFname) || die "could not find config file $configFname";
	return $yaml->[0]->{config};
}

sub display_env {
	say "library path:";
	foreach my $env_var (@INC) {
		say "\t$env_var";
	}
}