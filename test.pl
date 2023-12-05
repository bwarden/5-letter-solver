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
while (my $words = $g->get_possible_matches) {
  my $guess = get_best_word($words)
    or die "Out of words! Didn't guess $g->{secret_word}\n";
  print "Guessing $guess out of ", scalar keys %{$words}, " possible words\n";
  my $quality = $g->guess_my_word($guess);
  $guesses++;
  if ($quality->{correct} eq $guess) {
    print "The secret word was $guess\n";
    last GUESS;
  }
  $g->add_guess($quality);
}

print "Total guesses: $guesses\n";

exit;

sub get_best_word {
  my ($wordsref) = @_;

  my @words;
  if ($wordsref && ref $wordsref eq 'HASH') {
    @words = sort { ($wordsref->{$a}{score} - $wordsref->{$a}{used} ? 1000 : 0) <=> ($wordsref->{$b}{score} - $wordsref->{$b}{used} ? 1000 : 0) } keys %{$wordsref};
  }

  # Highest sort at the end
  return pop @words;
}
