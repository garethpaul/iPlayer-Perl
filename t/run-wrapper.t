use strict;
use warnings;

use Config qw(%Config);
use Cwd qw(abs_path);
use File::Copy qw(copy);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use Test::More;

my $root = abs_path(File::Spec->catdir($Bin, ".."));
my $temp = tempdir(CLEANUP => 1);
copy(File::Spec->catfile($root, "run.pl"), File::Spec->catfile($temp, "run.pl")) or die "copy run.pl: $!";

for my $path (qw(deps/mouse/lib deps/mousex-getopt/lib deps/mousex-nativetraits/lib existing/lib)) {
	make_path(File::Spec->catdir($temp, split m{/}, $path));
}

my $fake = File::Spec->catfile($temp, "get_iplayer");
open my $handle, ">", $fake or die "open fake get_iplayer: $!";
print {$handle} <<'FAKE';
#!/usr/bin/env perl
use strict;
use warnings;
print "PERL5LIB=$ENV{PERL5LIB}\n";
print join("\n", map { "ARG=" . length($_) . ":$_" } @ARGV), "\n";
FAKE
close $handle or die "close fake get_iplayer: $!";
chmod 0755, $fake or die "chmod fake get_iplayer: $!";

my $existing = File::Spec->catdir($temp, "existing", "lib");
my $duplicate = File::Spec->catdir($temp, "deps", "mouse", "lib") . "/";
local $ENV{PERL5LIB} = join($Config{path_sep} || ":", $duplicate, $existing);

my @arguments = ("--search", "two words", "--pid=abc-123", "");
open my $output, "-|", $^X, File::Spec->catfile($temp, "run.pl"), @arguments
	or die "run wrapper: $!";
my @lines = <$output>;
close $output;
is($? >> 8, 0, "wrapper exec exits successfully");

chomp @lines;
my ($perl5lib_line, @argument_lines) = @lines;
is_deeply(
	\@argument_lines,
	[map { "ARG=" . length($_) . ":$_" } @arguments],
	"wrapper preserves every argument exactly",
);

my (undef, $perl5lib) = split /=/, $perl5lib_line, 2;
my @entries = split /\Q@{[$Config{path_sep} || ":"]}\E/, $perl5lib;
is(scalar(grep { abs_path($_) eq abs_path(File::Spec->catdir($temp, "deps", "mouse", "lib")) } @entries), 1,
	"canonical duplicate local library path appears once");
ok(scalar(grep { abs_path($_) eq abs_path($existing) } @entries), "existing PERL5LIB entry is preserved");

done_testing;
