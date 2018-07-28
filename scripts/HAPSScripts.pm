package HAPSScripts;

use strict;
use warnings;
use parent 'Exporter';
use USBScripts qw(&cmd);

sub haps_check_requirement {
    if (system("sudo modprobe -q umrusb")) {
        print "umrusb driver not found\n";
        return 1;
    }

    if (system("which confpro > /dev/null")) {
        print "confpro not found\n";
        return 1;
    }

    return 0;
}

sub haps_scan {
    my $output;

    cmd("confpro cfg_scan", \$output);
    if (!defined $output) {
        return;
    }

    my @devices = ($output =~ m/emu:\d+?/g);
    my @serials = ($output =~ m/SERIAL \{.+?\}/g);

    if (!@devices) {
        print "No devices found\n";
        return;
    }

    my $i;
    for ($i = 0; $i < @devices; $i++) {
        print "$devices[$i] $serials[$i]\n";
    }
}

sub haps_get_device {
    my $output;
    cmd("confpro cfg_scan", \$output);
    if (!defined $output) {
        return;
    }

    my @devices = ($output =~ m/emu:\d+?/g);
    my @serials = ($output =~ m/SERIAL \{.+?\}/g);
    my $emu;

    if (@devices == 1) {
        $emu = $devices[0];
    } elsif (@devices > 1) {
        my $num;

        SELECT:
        print "Select device number below:\n";
        my $count = 1;
        for (@devices) {
            print "$count) $serials[$count++ - 1]\n";
        }

        print "Device: ";
        $num = <STDIN>;
        chomp $num;
        if (($num !~ m/\d+/) || ($num >= $count) || ($num <= 0)) {
            print "Please provide a valid number\n\n";
            goto SELECT;
        }

        $emu = $devices[$num - 1];
    } else {
        print "Couldn't find device number\n";
        return;
    }

    return $emu;
}

our @EXPORT = qw(haps_check_requirement haps_scan haps_get_device);

1;
