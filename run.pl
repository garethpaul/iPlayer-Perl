#!/usr/bin/env perl

use strict;
use warnings;
use Config qw(%Config);
use Cwd qw(abs_path);
use FindBin qw($Bin);

my @local_libs = (
	"$Bin/deps/mouse/lib",
	"$Bin/deps/mousex-getopt/lib",
	"$Bin/deps/mousex-nativetraits/lib",
);

sub normalized_path_entry {
	my ($path) = @_;
	$path =~ s{[\\/]+\z}{};
	return $path;
}

sub comparable_path_entry {
	my ($path) = @_;
	my $normalized_path = normalized_path_entry($path);
	return $normalized_path if !length $normalized_path;

	my $absolute_path = abs_path($normalized_path);
	return defined $absolute_path ? normalized_path_entry($absolute_path) : $normalized_path;
}

my $path_separator = $Config{path_sep} || ":";
my %existing_perl5lib_entries = ();
if (defined $ENV{PERL5LIB} && length $ENV{PERL5LIB}) {
	%existing_perl5lib_entries = map { comparable_path_entry($_) => 1 } split /\Q$path_separator\E/, $ENV{PERL5LIB};
}

my @perl5lib_entries = grep { -d $_ && !$existing_perl5lib_entries{comparable_path_entry($_)} } @local_libs;
push @perl5lib_entries, $ENV{PERL5LIB} if defined $ENV{PERL5LIB} && length $ENV{PERL5LIB};
if (@perl5lib_entries) {
	$ENV{PERL5LIB} = join $path_separator, @perl5lib_entries;
}

my $command = "$Bin/get_iplayer";
exec { $command } $command, @ARGV;
die "Unable to exec $command: $!\n";
