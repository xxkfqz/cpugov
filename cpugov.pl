#!/usr/bin/perl
# </> with <3, xxkfqz 2d24

use warnings;
use strict;

my $baseDir = '/sys/devices/system/cpu';

sub getCurrentGovernor {
    open(FH, '<', "$baseDir/cpu0/cpufreq/scaling_governor") || die "Could not read governor: $!";
    (my $currentGovernor = <FH>) =~ s/\R//g;
    close FH;

    $currentGovernor;
}

sub getAvailabeGovernors {
    my $govListFile = "$baseDir/cpu0/cpufreq/scaling_available_governors";
    open(FH, '<', $govListFile)
        || die "Could not open '$govListFile': $!";
    my @availableGovernors = split(' ', <FH>);
    close FH;

    @availableGovernors;
}

my $currentGovernor = getCurrentGovernor;
my @availableGovernors = getAvailabeGovernors;

if ($#ARGV < 0) {
    # Just print available governors
    print "Available governors:\n";

    for (@availableGovernors) {
        my $ch = '  ';
        if ($_ eq $currentGovernor) {
            $ch = '->';
        }
        print " $ch $_\n";
    }
} else {
    # Set governor
    my $newGovernor = shift;
    grep(/^$newGovernor$/, @availableGovernors)
        || die "Governor '$newGovernor' not available\n";

    opendir(my $dirHandler, $baseDir)
        || die "Could not open directory '$baseDir': $!\n";
    my @cpusList = sort(grep(/^cpu\d+$/, readdir($dirHandler)));
    closedir $dirHandler;

    print "Switching from '$currentGovernor' to '$newGovernor'\n";

    for (@cpusList) {
        open(FH, '>', "$baseDir/$_/cpufreq/scaling_governor")
            || die "Could not set governor '$newGovernor' on $_: $!\n";
        print FH $newGovernor;
        close FH;
    }
}
