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

my @perl5lib_entries = grep { -d $_ } @local_libs;
push @perl5lib_entries, $ENV{PERL5LIB} if defined $ENV{PERL5LIB} && length $ENV{PERL5LIB};
my $path_separator = $Config{path_sep} || ":";
if (@perl5lib_entries) {
	$ENV{PERL5LIB} = join $path_separator, @perl5lib_entries;
}

my $command = "$Bin/get_iplayer";
exec { $command } $command, @ARGV;
die "Unable to exec $command: $!\n";
