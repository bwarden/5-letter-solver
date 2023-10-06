#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: extract_eligible_wordlist.pl
#
#        USAGE: ./extract_eligible_wordlist.pl  
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
#      CREATED: 10/06/2023 09:42:56 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

warn "Usage: $0 < /usr/share/dict/words > wordlist.txt\n";

while (my $line = <>) {
  # Exactly 5 letters, no punctuation (apostrophes)
  # No proper names, so no capitals
  if ($line =~ m#^[a-z]{5}$#) {
    print $line;
  }
}
