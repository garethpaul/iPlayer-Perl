#!/usr/bin/env perl

use strict;
use warnings;
use Config qw(%Config);
use FindBin qw($Bin);

my @local_libs = (
	"$Bin/deps/mouse/lib",
	"$Bin/deps/mousex-getopt/lib",
	"$Bin/deps/mousex-nativetraits/lib",
);

push @local_libs, $ENV{PERL5LIB} if defined $ENV{PERL5LIB} && length $ENV{PERL5LIB};
my $path_separator = $Config{path_sep} || ":";
$ENV{PERL5LIB} = join $path_separator, @local_libs;

my $command = "$Bin/get_iplayer";
exec { $command } $command, @ARGV;
die "Unable to exec $command: $!\n";
