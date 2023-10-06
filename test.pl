#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test.pl
#
#        USAGE: ./test.pl  
#
#  DESCRIPTION: Tests the library by attempting to guess a random word.
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
my $guesses = 0;

GUESS:
while (my @words = $g->get_possible_matches) {
  if ($words[rand @words] =~ m#^([a-z]+)#) {
    my $guess = $1;
    print "Guessing $guess out of ", scalar @words, " possible words\n";
    my $quality = $g->guess_my_word($guess);
    $guesses++;
    if ($quality->{correct} eq $guess) {
      print "The secret word was $guess\n";
      last GUESS;
    }
    $g->add_guess($quality);
  }
}

print "Total guesses: $guesses\n";
