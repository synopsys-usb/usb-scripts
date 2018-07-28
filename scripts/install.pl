#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

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

sub tag_use_module {
    my $dir = shift;

    my @libscripts;
    push @libscripts, "USBScripts";
    if ($dir =~ m/haps_commands/) {
        push @libscripts, "HAPSScripts";
    }

    my $modules;
    for (@libscripts) {
        $modules .= "use $_;\n";
    }

    return $modules;
}

sub main {
    my $moddir = shift @ARGV;
    my $mode = shift @ARGV;
    my $dir = shift @ARGV;

    die "No MODULE_DIR" unless defined $moddir;
    die "No mode" unless defined $mode;
    die "No INSTALL_DIR" unless defined $dir;

    my @files = @ARGV;
    my $files = join " ", @files;

    die "No files to install" unless @files;

    if (!-d $dir) {
        system("mkdir -p $dir") == 0
            or die "Invalid directory $dir";
    }

    my $modules = tag_use_module($dir);

    my $file;
    for $file (@files) {
        if (!-f $file) {
            die "Invalid file $file";
        }

        my $dest = "$dir/" . basename($file);

        my $perl = 0;
        my $contents = read_file($file);
        if ($contents =~ m/(^\#\!\/usr\/bin\/perl.*\n)/) {
            $perl = 1;
            $contents =~ s/($1)/$1\nuse lib '$moddir';\n$modules/;
            $file = "$file.install";
            write_file($file, $contents);
        }

        my $cmd = "install -m $mode -D $file $dest";
        print "$cmd\n";

        my $ret = system($cmd);
        if ($perl) {
            unlink($file);
        }

        if ($ret) {
            die "Couldn't install $file";
        }
    }
}

main();
