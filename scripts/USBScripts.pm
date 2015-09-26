package USBScripts;

use strict;
use warnings;
use parent 'Exporter';
use Cwd qw(fast_abs_path);

our $BIN_DIR;
our $SCRIPT_DIR;
our $SCRIPT;
our $TYPE;

sub initialize {
    if ($0 =~ m/^(.*)\/(.*?)$/) {
        $SCRIPT_DIR = fast_abs_path($1);
        $SCRIPT = $2;
    }

    my $file = __FILE__;
    if ($file =~ m/^(.*)\/(.*?)$/) {
        $BIN_DIR = fast_abs_path($1);
    }

    if ($SCRIPT_DIR =~ m/(dwc2|dwc3|dwc3\-xhci)_commands/) {
        $TYPE = $1;
    }
}

initialize();

my $autodie = 0;

#
# Enable or disable the autodie option for cmd()
#
sub autodie {
    my $bool = shift;
    if (!defined($bool)) {
        $bool = 1;
    } else {
        $bool = !!$bool;
    }

    $autodie = $bool;
}

#
# Executes a shell command
#
# $cmd is the command line to execute
#
# $out is a reference to a scalar or array to capture the stdout. If
# scalar, all output is captured as a single string. If an array,
# output is captured as an array of lines.
#
sub _cmd {
    my $cmd = shift;
    my $out = shift;
    #my $in = shift;
    # TODO use stdin and stderr

    #if (defined($in)) {
    # $cmd = "| $cmd";
    #}

    if (defined($out)) {
        $cmd = "$cmd |";
    }

    if (!defined($out)) {
        if (system($cmd)) {
            warn("$!\n");
            return 0;
        }
        return 1;
    }

    my $f;
    if (!open($f, $cmd)) {
        warn("$!\n");
        return 0;
    }

    if ($out) {
        if (ref($out) eq "SCALAR") {
            local $/ = undef;
            ${$out} = <$f>;
        } elsif (ref($out) eq "ARRAY") {
            @{$out} = ();
            for (<$f>) {
                push @{$out}, $_;
            }
        }
    }

    if (!close($f)) {
        if (!$!) {
            # Command returned non-zero status
            warn("Command failed $?\n");
        } else {
            # Other issue with running the command
            warn("$!\n");
        }
        return 0;
    }

    return 1;
}

#
# This cmd() respects the autodie option
#
sub cmd {
    my $ret = _cmd(@_);
    if ($autodie) {
        die if !$ret;
    }
    return $ret;
}

my $_PLAT;

sub plat {
    if (!defined $_PLAT) {
        _cmd("uname -m", \$_PLAT)
            or die("Couldn't determine platform\n");

        chomp $_PLAT;
    }

    return $_PLAT;
}

sub plat_is_x86 {
    my $plat = plat();
    if ($plat =~ m/x86/) {
        return 1;
    }
    return 0;
}

sub plat_is_arc {
    my $plat = plat();
    if ($plat =~ m/arc/) {
        return 1;
    }
    return 0;
}

my $_BASE;

my $PCI_PIDS = {
    "abc0" => "dwc2",
    "abce" => "dwc3",
    "abcf" => "dwc3",
    "abcd" => "dwc3",
    "1234" => "dwc3-xhci",
};

#
# Returns the base address of the controller
#
sub base {
    if (defined $_BASE) {
        return $_BASE;
    }

    if (plat_is_arc()) {
        $_BASE = 0xd0000000;
    } elsif (plat_is_x86()) {
        my $pci;

        _cmd("lspci -v -d 16c3:", \$pci)
            or die("Couldn't examine PCI bus, check lspci\n");

        my @ids;

        while ($pci =~ m/USB .* 16c3\:([\da-fA-f]+)/g) {
            push @ids, $1;
        }

	if (!@ids) {
	    die("No controllers found.\n");
	}

        my $id = $ids[0];
        for (@ids) {
            if (defined ($TYPE) && ($TYPE eq $PCI_PIDS->{$_})) {
                $id = $_;
            }
        }

        if (!defined($id)) {
            die("Controller for $TYPE not found. Check lspci.\n");
        }

        _cmd("lspci -v -d 16c3:$id", \$pci)
            or die("Couldn't examine PCI bus.\n");

        if ($pci =~ /Memory at ([\da-fA-F]+) .*/) {
            $_BASE = hex($1);
        } else {
            die("Controller for $TYPE not found. Check lspci.\n");
        }
    } else {
        my $plat = plat();
        die("Unknown platform $plat\n");
    }

    return $_BASE;
}

sub rreg {
    my $offset = shift;
    my $no_base = shift;
    my $address = $offset;

    if (!(defined $no_base)) {
	$address += base();
    }

    my $cmd = sprintf("$BIN_DIR/rdmem %x", $address);

    my $value;
    _cmd($cmd, \$value) or die "rreg failed\n";
    chomp($value);
    return hex($value);
}

sub wreg {
    my $offset = shift;
    my $value = shift;
    my $no_base = shift;
    my $address = $offset;

    if (!(defined $no_base)) {
	$address += base();
    }

    my $cmd = sprintf("$BIN_DIR/wrmem %x %x", $address, $value);

    _cmd($cmd) or die "wreg failed\n";
    return 1;
}

sub run_as_root {
    if ($ENV{USER} ne 'root') {
        exec("/usr/bin/sudo $0 @ARGV");
    }
}

sub debugfs {
    my $pattern = shift;
    my @files;

    _cmd("ls -1 /sys/kernel/debug", \@files)
        or die("Couldn't examine debugfs\n");

    for (@files) {
        chomp;
        if (m/$pattern/) {
            return "/sys/kernel/debug/$_";
        }
    }

    return undef;
}

sub dwc3_debugfs {
    return debugfs("dwc3");
}

sub dwc2_debugfs {
    return debugfs("dwc2");
}

sub validate_hex {
    my $str = shift;
    if ($str =~ m/^(0x|)([0-9a-fA-F])+$/) {
        return 1;
    }
    return 0;
}

sub parse_bitfield {
    my $bitfield = shift;
    my $high;
    my $low;

    if ($bitfield =~ /^(\d+)(\:(\d+)|)/) {
        $high = $1;
        $low = $3;
    } else {
        die "Invalid bitfield $bitfield\n";
    }

    $low = $high if (!defined $low);
    if ($high < $low) {
        ($high, $low) = ($low, $high);
    }

    return ($low, $high);
}

sub genmask {
    my $low = shift;
    my $high = shift;

    die "Low bit not defined" if (!defined $low);

    if ((!defined $high) || ($low == $high)) {
        return (1 << $low);
    }

    if ($high < $low) {
        ($high, $low) = ($low, $high);
    }

    my $mask = 0xffffffff >> (31 - ($high - $low));
    $mask = $mask << $low;

    return $mask;
}

sub rmmod {
    my @mods;

    _cmd("lsmod", \@mods)
        or die("Couldn't determine loaded modules\n");

    for my $mod (@_) {
        if (grep(m/^$mod\s/, @mods)) {
            _cmd("rmmod $mod")
                or die("Couldn't remove module $mod\n");
        }
    }
}

# Print out a short description and exit
sub description {
    my $description = shift;

    for (@ARGV) {
        if ($ARGV[0] eq "description") {
            print "$description\n";
            exit(0);
        }
    }
}

sub read_file {
    my $file = shift;

    open(my $fh, '<', $file) or die "can't read $file";
    local $/ = undef;
    my $contents = <$fh>;
    close $fh;

    return $contents;
}

sub write_file {
    my $file = shift;
    my $content = shift;

    open(my $fh, '>', $file) or die "can't write $file";
    print $fh $content;
    close $fh;
}

# The script should not take any options or parameters and it should
# die if any are specified.
sub no_options {
    die "$SCRIPT: invalid parameters\n" if (@ARGV);
}

our @EXPORT = qw($BIN_DIR $SCRIPT_DIR $SCRIPT $TYPE rreg
wreg run_as_root plat_is_x86 plat_is_arc dwc3_debugfs dwc2_debugfs
rmmod validate_hex parse_bitfield genmask description no_options
read_file write_file cmd autodie base);

1;
