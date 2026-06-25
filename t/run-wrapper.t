use strict;
use warnings;

use Config qw(%Config);
use Cwd qw(abs_path getcwd);
use File::Copy qw(copy);
use File::Path qw(make_path remove_tree);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin qw($Bin);
use Test::More;

my $root = abs_path(File::Spec->catdir($Bin, ".."));
my $temp = tempdir(CLEANUP => 1);
my $app = File::Spec->catdir($temp, "app");
my $launch = File::Spec->catdir($temp, "launch");
make_path($app, $launch);
chmod 0755, $app, $launch or die "chmod fixture directories: $!";

my $wrapper = File::Spec->catfile($app, "run.pl");
copy(File::Spec->catfile($root, "run.pl"), $wrapper) or die "copy run.pl: $!";
chmod 0755, $wrapper or die "chmod run.pl: $!";

for my $path (qw(deps/mouse/lib deps/mousex-getopt/lib deps/mousex-nativetraits/lib existing/lib unsafe/lib)) {
	my $directory = File::Spec->catdir($app, split m{/}, $path);
	make_path($directory);
	chmod 0755, $directory or die "chmod fixture directory $path: $!";
}

sub write_executable {
	my ($path, $content) = @_;
	open my $handle, ">", $path or die "open $path: $!";
	print {$handle} $content;
	close $handle or die "close $path: $!";
	chmod 0755, $path or die "chmod $path: $!";
}

sub run_command {
	my ($cwd, $environment, @command) = @_;
	my $pid = open my $output, "-|";
	die "fork command: $!" if !defined $pid;
	if (!$pid) {
		chdir $cwd or die "chdir $cwd: $!";
		%ENV = (%ENV, %{$environment});
		open STDERR, ">&STDOUT" or die "redirect stderr: $!";
		exec { $command[0] } @command;
		die "exec $command[0]: $!";
	}
	my @lines = <$output>;
	close $output;
	return ($? >> 8, @lines);
}

my $fake = File::Spec->catfile($app, "get_iplayer");
write_executable($fake, <<'FAKE');
#!/usr/bin/env perl
use strict;
use warnings;
print "PERL5LIB=", defined $ENV{PERL5LIB} ? $ENV{PERL5LIB} : "<unset>", "\n";
print join("\n", map { "ARG=" . length($_) . ":" . unpack("H*", $_) } @ARGV), "\n";
FAKE

my $existing = File::Spec->catdir($app, "existing", "lib");
my $duplicate = File::Spec->catdir($app, "deps", "mouse", "lib") . "/";
my $missing = File::Spec->catdir($app, "missing", "lib");
my $unsafe = File::Spec->catdir($app, "unsafe", "lib");
chmod 0777, $unsafe or die "chmod unsafe lib: $!";
my $symlink = File::Spec->catdir($app, "symlink-lib");
symlink $existing, $symlink or die "symlink lib: $!";
my $separator = $Config{path_sep} || ":";
my $inherited_perl5lib = join($separator, "", $duplicate, "relative/lib", $missing, $symlink, $unsafe, $existing, "");

my @arguments = ("--search", "two words", "--pid=abc-123", "", "line\nbreak", q{'; echo not-a-shell});
my ($exit, @lines) = run_command($launch, { PERL5LIB => $inherited_perl5lib }, $wrapper, @arguments);
is($exit, 0, "wrapper exec exits successfully");

chomp @lines;
my ($perl5lib_line, @argument_lines) = @lines;
is_deeply(
	\@argument_lines,
	[map { "ARG=" . length($_) . ":" . unpack("H*", $_) } @arguments],
	"wrapper preserves every argument exactly without a shell",
);

my (undef, $perl5lib) = split /=/, $perl5lib_line, 2;
my @entries = split /\Q$separator\E/, $perl5lib, -1;
is(scalar(grep { !length $_ } @entries), 0, "empty PERL5LIB entries are removed");
is(scalar(grep { !File::Spec->file_name_is_absolute($_) } @entries), 0, "relative PERL5LIB entries are removed");
is(scalar(grep { $_ eq $missing || $_ eq $symlink || $_ eq $unsafe } @entries), 0,
	"missing, symlinked, and writable PERL5LIB entries are removed");
is(scalar(grep { defined(abs_path($_)) && abs_path($_) eq abs_path(File::Spec->catdir($app, "deps", "mouse", "lib")) } @entries), 1,
	"canonical duplicate local library path appears once");
ok(scalar(grep { defined(abs_path($_)) && abs_path($_) eq abs_path($existing) } @entries), "safe existing PERL5LIB entry is preserved");

chmod 0777, $app or die "chmod writable app: $!";
my ($writable_app_exit, @writable_app_output) = run_command($launch, { PERL5LIB => "" }, $wrapper, "--safe");
isnt($writable_app_exit, 0, "wrapper rejects a group- or world-writable wrapper directory");
like(join("", @writable_app_output), qr/wrapper directory.*writable/i,
	"writable wrapper directory rejection is explicit");
chmod 0755, $app or die "restore app permissions: $!";

remove_tree(File::Spec->catdir($app, "deps"));
my ($empty_exit, @empty_lines) = run_command($launch, { PERL5LIB => join($separator, "", "relative/lib", "") }, $wrapper);
is($empty_exit, 0, "wrapper with no validated PERL5LIB entries exits successfully");
chomp @empty_lines;
is($empty_lines[0], "PERL5LIB=<unset>", "PERL5LIB is unset when no validated entries remain");

my $marker = File::Spec->catfile($temp, "module-shadowed");
write_executable(File::Spec->catfile($launch, "Cwd.pm"), <<SHADOW);
BEGIN { open my \$fh, '>', '$marker'; print {\$fh} 'loaded'; close \$fh; die "shadowed Cwd loaded\\n"; }
1;
SHADOW
my ($shadow_exit, @shadow_output) = run_command($launch, { PERL5LIB => "." }, $wrapper, "--safe");
is($shadow_exit, 0, "taint-safe wrapper ignores startup module shadowing");
ok(!-e $marker, "launch-directory module is not loaded before PERL5LIB validation");

my ($bypass_exit, @bypass_output) = run_command($launch, { PERL5LIB => "" }, $^X, $wrapper);
isnt($bypass_exit, 0, "invoking run.pl through an untainted interpreter fails closed");
like(join("", @bypass_output), qr/(?:must be executed directly|must also be used on the command line)/i,
	"untainted invocation explains the safe launch requirement");

unlink $fake or die "unlink fake get_iplayer: $!";
my $real_fake = File::Spec->catfile($app, "real-get-iplayer");
write_executable($real_fake, "#!/usr/bin/env perl\nprint qq{unsafe symlink executed\\n};\n");
symlink $real_fake, $fake or die "symlink get_iplayer: $!";
my ($symlink_exit, @symlink_output) = run_command($launch, { PERL5LIB => "" }, $wrapper);
isnt($symlink_exit, 0, "symlinked get_iplayer entrypoint is rejected");
like(join("", @symlink_output), qr/regular file|symlink/i, "symlink rejection is explicit");

unlink $fake or die "unlink symlinked get_iplayer: $!";
write_executable($fake, "#!/usr/bin/env perl\n" . ("# padding\n" x 140_000) . "print qq{oversized executed\\n};\n");
my ($large_exit, @large_output) = run_command($launch, { PERL5LIB => "" }, $wrapper);
isnt($large_exit, 0, "oversized get_iplayer entrypoint is rejected");
like(join("", @large_output), qr/size limit/i, "oversized entrypoint rejection is explicit");

done_testing;
