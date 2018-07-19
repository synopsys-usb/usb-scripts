#!/usr/bin/perl

use strict;

my $COMMAND_DIR;

sub print_usage {
    my $exit_code = shift;
    my @commands = commands();
    my $commands = "";

    for (@commands) {
        my $out = "";
        my $contents = read_file("$COMMAND_DIR/$_");

        if (!($contents =~ m/^\#\!.*perl.*\n/)) {
            next;
        }

        if ($contents =~ m/description\(\"(.*)\"\)/) {
            $out = eval qq{"$1"};
        }

        $commands .= sprintf("  %-15s $out\n", $_);
    }

    print <<USAGE_EOF;
usage: $SCRIPT <command>

Commands:
$commands
USAGE_EOF

    exit $exit_code;
}

sub is_command {
    my $file = shift;
    $file = "$COMMAND_DIR/$file";

    return 0 unless (-f $file && -x $file);

    return 1;
}

sub commands {
    opendir my $dir, $COMMAND_DIR or die "Cannot open directory: $!";
    my @files = readdir $dir;
    closedir $dir;

    return sort(grep { is_command($_) } @files);
}

sub do_completion {
    my $comp_line = <STDIN>;
    my @args = split /\s+/, $comp_line, -1;

    my $partial_cmd = $args[1];
    exit(0) if (!defined $partial_cmd);
    exit(0) if (@args > 2);

    my @cmds = grep { m/^$partial_cmd/ } commands();

    print join(' ', @cmds);
    exit 0;
}

sub main {
    $COMMAND_DIR = "$SCRIPT_DIR/${SCRIPT}_commands";
    if (!-d $COMMAND_DIR) {
        die "Please use dwc3, dwc2, typec, dwc3-xhci, or haps\n";
    }

    print_usage(0) if !@ARGV;

    if ($ARGV[0] eq "completion") {
        do_completion();
        exit(0);
    }

    my $command = $ARGV[0];
    if (!grep { /^$command$/ } commands()) {
        die "Invalid $SCRIPT command $ARGV[0]\n";
    }

    exec("/usr/bin/perl $COMMAND_DIR/@ARGV type=$SCRIPT");
}

main();
