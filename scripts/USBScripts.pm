package USBScripts;

use strict;
use warnings;
use parent 'Exporter';
use Cwd qw(fast_abs_path);

our $BIN_DIR;
our $LIB_DIR;
our $SCRIPT_DIR;
our $SCRIPT;
our $TYPE;
my $DWC_SCRIPT = 0;

sub initialize {
    if ($0 =~ m/^(.*)\/(.*?)$/) {
        $SCRIPT_DIR = fast_abs_path($1);
        if ($2 eq "xhci") {
            $SCRIPT = "dwc3-xhci";
        } else {
            $SCRIPT = $2;
        }
    }

    my $file = __FILE__;
    if ($file =~ m/^(.*)\/(.*?)$/) {
        $BIN_DIR = fast_abs_path($1);
        $LIB_DIR = "$BIN_DIR/lib";
    }

    if (@ARGV) {
        if ($ARGV[-1] =~ m/type=(haps$|typec$|dwc2$|dwc3$|(?:dwc3\-)?xhci$)/) {
            $TYPE = $1;
            $DWC_SCRIPT = 1;
            pop @ARGV;
        }
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
        if ($!) {
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
    if ($plat =~ m/\barc\b/) {
        return 1;
    }
    return 0;
}

sub plat_is_juno {
    my $plat = plat();
    if ($plat =~ m/aarch64/) {
        return 1;
    }
    return 0;
}

my $_KERNEL_VERSION;

sub kver {
    if (!defined $_KERNEL_VERSION) {
        _cmd("uname -r", \$_KERNEL_VERSION)
            or die("Couldn't determine kernel version\n");

        chomp $_KERNEL_VERSION;
    }

    return $_KERNEL_VERSION;
}

my $_BASE;
my $_BASE_2;
my $_PCI_BUS;

my $PCI_PIDS = {
    "abc0" => "dwc2",
    "abc1" => "typec",
    "abc3" => "typec",
    "abce" => "dwc3",
    "abcf" => "dwc3",
    "abcd" => "dwc3",
    "1234" => "dwc3-xhci",
    "9001" => "DP",
};

my $PCI_VID = "16c3";

#
# Returns the base address or bus domain of the controller
#
# arg1: Set to return PCI bus domain. Otherwise return base address
#
sub base {
    my $get_bus = shift;

    if (defined $get_bus and defined $_PCI_BUS) {
        return $_PCI_BUS;
    }

    if (!defined $get_bus and defined $_BASE) {
        return $_BASE;
    }

    if (plat_is_juno()) {
        $_BASE = 0x60000000;
    } elsif (plat_is_arc()) {
        $_BASE = 0xd0000000;
    } elsif (plat_is_x86()) {
        my @pci_bus;
        my @ids;
        my $pci;

        _cmd("setpci -f -d $PCI_VID: DEVICE_ID", \@ids)
            or die("Couldn't examine PCI bus\n");

        chomp @ids;

        _cmd("lspci -D -n -d $PCI_VID: | awk '{ print \$1 }'", \@pci_bus)
            or die("Couldn't examine PCI bus, check lspci\n");

        chomp @pci_bus;

        if (!@ids) {
            die("No controllers found.\n");
        }

        $_PCI_BUS = $pci_bus[0];
        my $id = $ids[0];
        for (@ids) {
            if (defined ($TYPE) && exists $PCI_PIDS->{$_} && ($TYPE eq $PCI_PIDS->{$_})) {
                $id = $_;
            }
        }

        if (!defined($id)) {
            die("Controller for $TYPE not found. Check lspci.\n");
        }

        my $addr;
        _cmd("setpci -d $PCI_VID:$id BASE_ADDRESS_0", \$addr);
        chomp($addr);
        $_BASE = hex($addr) & 0xffff0000;

        _cmd("setpci -d $PCI_VID:$id BASE_ADDRESS_2", \$addr);
        chomp($addr);
        $_BASE_2 = hex($addr) & 0xfffff000;

        my $pci_cmd;
        _cmd("setpci -d $PCI_VID:$id COMMAND", \$pci_cmd);
        chomp $pci_cmd;
        if (!(($pci_cmd >> 1) & 0x1)) {
            $pci_cmd |= 2;
            _cmd("sudo setpci -d $PCI_VID:$id COMMAND=$pci_cmd");
        }

        if (defined $get_bus) {
            return $_PCI_BUS;
        }
    } else {
        my $plat = plat();
        die("Unknown platform $plat\n");
    }

    return $_BASE;
}

sub rreg {
    my $address = shift;
    my $no_base = shift;

    if (!(defined $no_base)) {
	$address += base();
    }

    my $cmd = sprintf("$LIB_DIR/rdmem %x", $address);

    my $value;
    _cmd($cmd, \$value) or die "rreg failed\n";
    chomp($value);
    return hex($value);
}

sub wreg {
    my $address = shift;
    my $value = shift;
    my $no_base = shift;

    if (!(defined $no_base)) {
	$address += base();
    }

    my $cmd = sprintf("$LIB_DIR/wrmem %x %x", $address, $value);

    _cmd($cmd) or die "wreg failed\n";
    return 1;
}

sub initram {
    my $size;

    cmd("cat /sys/class/block/ram0/size", \$size)
        or die "Could not determine size of /dev/ram0";

    cmd("dd if=/dev/zero of=/dev/ram0 count=256 bs=64k 2> /dev/null") or die;

    $size *= 512;

    if ($size == 1024*1024*64) {
        cmd("$LIB_DIR/initram_64mb") or die;
    } elsif ($size == 1024*1024*1024*2) {
        cmd("$LIB_DIR/initram_2gb") or die;
    } elsif ($size == 1024*1024*1024*4) {
        cmd("$LIB_DIR/initram_4gb") or die;
    } else {
        die "/dev/ram0 size $size not supported";
    }
}

sub unload {
    if ($TYPE eq "dwc3-xhci") {
        if (plat_is_arc() or plat_is_juno()) {
            rmmod("xhci_plat_hcd");
            rmmod("dwc3");
            rmmod("phy_generic");
        } elsif (plat_is_x86()) {
            rmmod("snps_phy_tc");
            rmmod("xhci_plat_hcd");
            rmmod("dwc3", "dwc3_haps", "dwc3_pci");
            rmmod("xhci_pci");
            rmmod("xhci_hcd");
        }
    } elsif (($TYPE eq "typec") or ($TYPE eq "dwc3") or ($TYPE eq "dwc2")) {
        rmmod("g_mass_storage", "g_audio", "g_ether", "g_zero", "tcm_usb_gadget", "g_uas");
        rmmod("usb_f_mass_storage", "usb_f_uac1_legacy", "usb_f_uac1", "usb_f_uac2");
        rmmod("usb_f_uas", "usb_f_tcm", "u_audio");
        rmmod("iscsi_target_mod", "tcm_loop", "target_core_mod");
        rmmod("libcomposite");
        rmmod("dwc3", "dwc3_haps", "dwc3_pci");
        rmmod("dwc2", "dwc2_pci");
        rmmod("udc_core");
        rmmod("snps_phy_tc");
        rmmod("phy_generic");
        if (plat_is_x86()) {
            my $pci_bus = base(1);
            if (-d "/sys/bus/pci/devices/$pci_bus/driver") {
                write_file("/sys/bus/pci/devices/$pci_bus/driver/unbind", $pci_bus);
            }

            if (!is_enabled()) {
                pmu_request("d0");
            }
        }
    }
}

sub enable_trace {
    if (! -e "/sys/kernel/debug/tracing") {
        print "Tracing is not enabled\n";
        return;
    }

    my $trace_buf_size = "98304";

    if ($TYPE eq "dwc3") {
        write_file("/sys/kernel/debug/tracing/buffer_size_kb", $trace_buf_size) or die;
        write_file("/sys/kernel/debug/tracing/events/dwc3/enable", "1") or die;
    } elsif ($TYPE eq "dwc3-xhci") {
        write_file("/sys/kernel/debug/tracing/buffer_size_kb", $trace_buf_size) or die;
        write_file("/sys/kernel/debug/tracing/events/xhci-hcd/enable", "1") or die;
    } elsif ($TYPE eq "dwc2") {
        write_file("/sys/kernel/debug/tracing/buffer_size_kb", $trace_buf_size) or die;
        write_file("/sys/kernel/debug/tracing/events/dwc2/enable", "1") or die;
    }
}

sub run_as_root {
    if ($ENV{USER} ne 'root') {
        if ($DWC_SCRIPT) {
            push @ARGV, "type=$TYPE";
        }
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

sub typec_debugfs {
    return debugfs("combo_phy");
}

sub dwc3_debugfs {
    return debugfs("dwc3");
}

sub dwc3_pci_debugfs {
    my $pci_domain;
    _cmd("lspci -D -d $PCI_VID: | awk '{ print \$1 }'", \$pci_domain)
        or return undef;

    chomp $pci_domain;
    return debugfs($pci_domain);
}

sub dwc2_debugfs {
    return debugfs("dwc2");
}

sub dwc2_pci_debugfs {
    return debugfs("dwc2-pci");
}

sub validate_hex {
    my $str = shift;
    if ($str =~ m/^(0x|)([0-9a-fA-F])+$/) {
        return 1;
    }
    return 0;
}

# Check if the device is in suspended mode
sub is_enabled {
    if (defined $_BASE_2) {
        my $value;
        my $is_enabled;
        my $r4 = $_BASE_2 + 0x10;

        my $cmd = sprintf("$LIB_DIR/rdmem %x", $r4);
        _cmd($cmd, \$value) or (print "Can't read mem region 2\n" and return 1);
        chomp($value);

        $is_enabled = (((hex($value) & (0x3 << 4)) == 0) &&
            ((hex($value) & 0x3) == 0)) ? 1 : 0;

        return $is_enabled;
    }

    return 1;
}

# Enable/disable controller PMU
sub pmu_request {
    my $request = shift;

    if (defined $_BASE_2) {
        my $r1 = $_BASE_2 + 0x4;
        my $d0_request = 0 << 12;
        my $d3_request = 3 << 12;
        my $cmd;

        $cmd = sprintf("$LIB_DIR/wrmem %x %x", $r1,
            ($request eq "d3") ?  $d3_request : $d0_request);

        _cmd($cmd) or (print "Can't write mem region 2\n" and return);
    }
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

our @EXPORT = qw($BIN_DIR $LIB_DIR $SCRIPT_DIR $SCRIPT $TYPE rreg
wreg run_as_root plat_is_x86 plat_is_arc plat_is_juno typec_debugfs
dwc3_debugfs dwc2_debugfs dwc2_pci_debugfs rmmod validate_hex
parse_bitfield genmask description no_options read_file write_file
cmd autodie base initram unload enable_trace dwc3_pci_debugfs
is_enabled);

1;
