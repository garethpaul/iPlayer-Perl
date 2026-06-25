#!/usr/bin/perl -T

our $INHERITED_PERL5LIB;
BEGIN {
	die "run.pl must be executed directly so Perl taint mode is enabled\n" if !${^TAINT};
	die "run.pl requires Perl 5.26 or newer for safe module lookup\n" if $] < 5.026;
	$INHERITED_PERL5LIB = $ENV{PERL5LIB};
	delete @ENV{qw(PERL5LIB PERLLIB PERL5OPT PERL_USE_UNSAFE_INC IFS CDPATH ENV BASH_ENV)};
	$ENV{PATH} = "/usr/bin:/bin";
}

use strict;
use warnings;
use Config qw(%Config);
use Cwd qw(abs_path);
use File::Spec;
use FindBin qw($Bin);

my $MAX_ENTRYPOINT_BYTES = 1024 * 1024;

sub normalized_path_entry {
	my ($path) = @_;
	return $path if $path =~ m{\A(?:[A-Za-z]:)?[\\/]+\z};
	$path =~ s{[\\/]+\z}{};
	return $path;
}

sub canonical_directory {
	my ($path) = @_;
	return if !defined $path || !length $path || index($path, "\0") >= 0;
	return if !File::Spec->file_name_is_absolute($path);
	my @link_stat = lstat $path;
	return if !@link_stat || -l _ || !-d _;
	my $canonical = abs_path($path);
	return if !defined $canonical;
	$canonical =~ /\A([^\0]+)\z/s or return;
	return normalized_path_entry($1);
}

sub secure_directory {
	my ($path) = @_;
	my $canonical = canonical_directory($path);
	return if !defined $canonical;
	my @stat = stat $canonical;
	return if !@stat || !-d _;
	return if $stat[4] != 0 && $stat[4] != $>;
	return if $stat[2] & 0022;
	return $canonical;
}

sub secure_entrypoint {
	my ($path) = @_;
	my @stat = lstat $path;
	die "get_iplayer must be a regular file, not a symlink\n" if !@stat || -l _ || !-f _;
	die "get_iplayer exceeds the wrapper size limit\n" if $stat[7] <= 0 || $stat[7] > $MAX_ENTRYPOINT_BYTES;
	die "get_iplayer has unsafe ownership\n" if $stat[4] != 0 && $stat[4] != $>;
	die "get_iplayer must not be group- or world-writable\n" if $stat[2] & 0022;
	die "get_iplayer must be executable\n" if !-x $path;
	my $canonical = abs_path($path);
	die "get_iplayer cannot be resolved safely\n" if !defined $canonical;
	$canonical =~ /\A([^\0]+)\z/s or die "get_iplayer path is invalid\n";
	return $1;
}

sub safe_argument {
	my ($argument) = @_;
	$argument =~ /\A([^\0]*)\z/s or die "command argument contains a NUL byte\n";
	return $1;
}

my $path_separator = $Config{path_sep} || ":";
my @existing_perl5lib_entries = ();
if (defined $INHERITED_PERL5LIB && length $INHERITED_PERL5LIB) {
	my %seen = ();
	for my $entry (split /\Q$path_separator\E/, $INHERITED_PERL5LIB, -1) {
		my $safe = secure_directory($entry);
		next if !defined $safe || $seen{$safe}++;
		push @existing_perl5lib_entries, $safe;
	}
}

my $safe_bin = secure_directory($Bin);
die "wrapper directory has unsafe ownership or is group- or world-writable\n" if !defined $safe_bin;
my @local_libs = map { File::Spec->catdir($safe_bin, split m{/}) } (
	"deps/mouse/lib",
	"deps/mousex-getopt/lib",
	"deps/mousex-nativetraits/lib",
);

my %seen = map { $_ => 1 } @existing_perl5lib_entries;
my @perl5lib_entries = grep {
	my $safe = secure_directory($_);
	defined $safe && !$seen{$safe}++;
} @local_libs;
@perl5lib_entries = map { secure_directory($_) } @perl5lib_entries;
push @perl5lib_entries, @existing_perl5lib_entries;
if (@perl5lib_entries) {
	$ENV{PERL5LIB} = join $path_separator, @perl5lib_entries;
}
else {
	delete $ENV{PERL5LIB};
}

my $command = secure_entrypoint(File::Spec->catfile($safe_bin, "get_iplayer"));
my @arguments = map { safe_argument($_) } @ARGV;
exec { $command } $command, @arguments;
die "Unable to exec $command: $!\n";
