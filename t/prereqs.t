#!perl
use strict;
use warnings;

use lib 't';
use helper;
use Expect;
use Cwd qw(abs_path);

# EXPECT DEBUGGING
my $log_expect_stdout=0;

my $dir = workdir;
chdir $dir;

bosh2_cli_ok;

reprovision kit => 'prereqs';

$ENV{SHOULD_FAIL} = '';
runs_ok "genesis new successful-env --no-secrets";
ok -f "successful-env.yml", "Environment file should be created, when prereqs passes";

$ENV{SHOULD_FAIL} = 'yes';
run_fails "genesis new failed-env --no-secrets", 1;
ok ! -f "failed-env.yml", "Environment file should not be created, when prereqs fails";

my $bin = compiled_genesis "9.0.1";
reprovision kit =>'version-prereq';

$ENV{SHOULD_FAIL} = '';
my ($pass, $rc, $msg);
($pass, $rc, $msg) = run_fails "$bin new something-new", 255;
matches $msg, qr'.*ERROR:.* Kit dev/latest requires Genesis version 9.5.2, but installed Genesis is only version 9.0.1.',"Genesis not new enough";
doesnt_match $msg, qr'New environment something-new provisioned.', "Did not create new environment 'something-new'";
ok ! -f "something.yml", "Org environment file should not be created, when prereqs fails";
ok ! -f "something-new.yml", "Deployment environment file should not be created, when prereqs fails";

$bin = compiled_genesis "9.5.2";
($pass, $rc, $msg) = runs_ok "$bin new something-new --no-secrets";
doesnt_match $msg, qr'you wat, mate\?',"Genesis should be new enough";
matches $msg, qr'New environment something-new provisioned.', "Created new environment 'something-new'";
ok -f "something.yml", "Org environment file should be created, when version meets minimum ";
ok -f "something-new.yml", "Deployment environment file should be created, when version meets minimum";

done_testing;
