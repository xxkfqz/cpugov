#!/usr/bin/perl
# </> with <3, xxkfqz 2d24

use warnings;
use strict;

my $baseDir = '/sys/devices/system/cpu';

sub getCurrentGovernor {
    open(FH, '<', "$baseDir/cpu0/cpufreq/scaling_governor")
        || die "Could not read governor: $!\n";
    (my $curGovernor = <FH>) =~ s/\R//g;
    close FH;

    $curGovernor;
}

sub getAvailabeGovernors {
    my $govListFile = "$baseDir/cpu0/cpufreq/scaling_available_governors";
    open(FH, '<', $govListFile)
        || die "Could not open '$govListFile': $!\n";
    my @availableGovernors = split(' ', <FH>);
    close FH;

    @availableGovernors;
}

my $currentGovernor = getCurrentGovernor;
my @availableGovernors = getAvailabeGovernors;

if ($#ARGV < 0) {
    # Just print available governors
    print "Available governors:\n";

    for my $index (0 .. $#availableGovernors) {
        my $ch = '  ';
        if ($availableGovernors[$index] eq $currentGovernor) {
            $ch = '->';
        }
        print " [$index] $ch $availableGovernors[$index]\n";
    }
} else {
    # Set governor
    my $newGovernor = shift;

    # Is governor index?
    if ($newGovernor =~ /^\d+$/) {
        my $index = $newGovernor;
        $newGovernor = $availableGovernors[$index];

        unless ($newGovernor) {
            die "Not found governor with index $index\n";
        }
    }

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
