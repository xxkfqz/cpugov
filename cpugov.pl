#!/usr/bin/perl
# Usage:
#   cpugov.pl             -> print available governors
#   cpugov.pl [some_name] -> set governor

use warnings;
use strict;

my $baseDir = '/sys/devices/system/cpu';

if ($#ARGV < 0) {
    # Just print available governors
    open(FH, '<', "$baseDir/cpu0/cpufreq/scaling_governor") || die "Could not read governor: $!";
    (my $curGov = <FH>) =~ s/\R//g;
    close FH;

    my $govListFile = "$baseDir/cpu0/cpufreq/scaling_available_governors";
    open(FH, '<', $govListFile) || die "Could not open '$govListFile': $!";
    my $availGovs = join("\n\t", split ' ', <FH>) =~ s/(?<=$curGov)/\t\(current\)/gr;
    print "Available governors:\n\t$availGovs\n";
    close FH;
} else {
    # Set governor
    opendir(my $dirHandler, $baseDir) || die "Could not open directory '$baseDir': $!\n";
    my @cpusList = sort grep /^cpu\d+$/, readdir $dirHandler;
    closedir $dirHandler;

    my $newGov = shift;
    for (@cpusList) {
        open(FH, '>', "$baseDir/$_/cpufreq/scaling_governor") || die "Could not set governor '$newGov' on $_: $!\n";
        print FH $newGov;
        close FH;
    }
}
