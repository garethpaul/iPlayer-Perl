#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw($Bin);

my @local_libs = (
	"$Bin/deps/mouse/lib",
	"$Bin/deps/mousex-nativetraits/lib",
);

push @local_libs, $ENV{PERL5LIB} if defined $ENV{PERL5LIB} && length $ENV{PERL5LIB};
$ENV{PERL5LIB} = join ":", @local_libs;

my $command = "$Bin/get_iplayer";
exec { $command } $command, @ARGV;
die "Unable to exec $command: $!\n";
