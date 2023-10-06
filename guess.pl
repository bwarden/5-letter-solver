#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: guess.pl
#
#        USAGE: ./guess.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Brett T. Warden (btw), bwarden@wgz.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/06/2023 11:22:16 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use FindBin qw($RealBin);
use YAML qw(Dump);

use lib "$RealBin";
use FiveLetter;

my $g = FiveLetter->new;

print Dump($g);
