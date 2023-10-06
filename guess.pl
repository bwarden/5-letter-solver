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

use lib "$RealBin";
use FiveLetter;

my $g = FiveLetter->new;

print "Guessing STORY\n";
$g->add_guess({
    absent  => 'STORY',
  });

print join(', ', $g->get_possible_matches), "\n";

print "Guessing ADIEU\n";
$g->add_guess({
    present => 'A  E ',
    absent  => ' DI U',
  });

print join(', ', $g->get_possible_matches), "\n";

print "Guessing GLAZE\n";
$g->add_guess({
    correct => ' la e',
    absent  => 'g  z ',
  });

print join(', ', $g->get_possible_matches), "\n";

print "Guessing FLAKE\n";
$g->add_guess({
    correct => 'fla e',
    absent  => '   k ',
  });

print join(', ', $g->get_possible_matches), "\n";
