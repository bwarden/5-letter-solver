#
#===============================================================================
#
#         FILE: FiveLetter.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Brett T. Warden (btw), bwarden@wgz.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/06/2023 11:29:53 AM
#     REVISION: ---
#===============================================================================

package FiveLetter;

use Modern::Perl;

use File::Spec::Functions;
use FindBin qw($RealBin);

# Create the object, with defaults and overrides
sub new {
  my $self = {};
  bless $self;

  # The data files to load
  $self->{wordfile}   = catfile($RealBin, "wordlist.txt");
  $self->{usedfile}   = catfile($RealBin, "used.txt");
  $self->{scorefile}  = catfile($RealBin, "scores.txt");

  # Store the current progress
  # Correct and Present are arrays indexed by column of the guessed word
  $self->{correct}  = ['', '', '', '', '']; # one possible correct letter per column
  $self->{present}  = [{}, {}, {}, {}, {}]; # hash of letters that are in the wrong column
  # Lump of all the letters that don't belong
  $self->{absent}   = {}; # keys are individual letters, value is true

  # Where we keep the narrowed-down, scored word list
  # keys are words, values are hashrefs, with subkeys for numeric score, and a true/non-true value for whether it has been used before
  $self->{words}      = {};

  # Load overridden values
  foreach my $arg (@_) {
    if ($arg && ref $arg eq 'HASH') {
      foreach my $key (keys %{$arg}) {
        $self->{$key} = $arg->{$key};
      }
    }
  }

  return $self->init;
}

# Call the actual initialization functions
sub init {
  my ($self) = @_ or die "This is a method call";

  $self->load_wordlist($self->{wordfile});
  $self->load_usedlist($self->{usedfile});
  $self->load_scoring($self->{scorefile});

  return $self;
}

# Annotate the wordlist with whether a given word is used
sub _update_used_words {
  my ($self) = @_ or die "This is a method call";

  if ($self->{words} && $self->{used}) {
    # Update the used words
    foreach my $word (keys (%{$self->{words}})) {
      $self->{words}{$word}{used} = $self->{used}{$word} ? 1 : 0;
    }
  }
}

# Update the scoring of words
sub _update_scores {
  my ($self) = @_ or die "This is a method call";

  if ($self->{words} && $self->{score}) {
    foreach my $word (keys (%{$self->{words}})) {
      my $score = 0;
      foreach my $letter (split(//, $word)) {
        $score += $self->{score}{$letter};
      }
      $self->{words}{$word}{score} = $score;
    }
  }
}

# Load the wordlist and create the data structure
sub load_wordlist {
  my ($self, $filename) = @_ or die "This is a method call";

  if ($filename && -f $filename) {
    open(my $fh, "<", $filename)
      or die "$filename: $!\n";
    $self->{words} = {};
    while (my $line = <$fh>) {
      if ($line =~ m#\b([a-z]{5})\b#i) {
        $self->{words}{lc $1} = {};
      }
    }
    close($fh)
      or die "$filename: $!\n";
  }

  $self->_update_used_words();
  $self->_update_scores();

  return 1;
}

sub load_usedlist {
  my ($self, $filename) = @_ or die "This is a method call";

  if ($filename && -f $filename) {
    open(my $fh, "<", $filename)
      or die "$filename: $!\n";
    $self->{used} = {};
    while (my $line = <$fh>) {
      if ($line =~ m#^\s*([a-z]{5})\s*$#i) {
        $self->{used}{lc $1}++;
      }
    }
    close($fh)
      or die "$filename: $!\n";
  }

  $self->_update_used_words();

  return 1;
}

sub load_scoring {
  my ($self, $filename) = @_ or die "This is a method call";

  if ($filename && -f $filename) {
    open(my $fh, "<", $filename)
      or die "$filename: $!\n";
    $self->{score} = {};
    while (my $line = <$fh>) {
      if ($line =~ m#^(\d+)[:\s]+(\S+.*)#) {
        my $score = $1;
        foreach my $letter (split(/[, ]/, $2)) {
          if ($letter =~ m#^[a-z]$#i) {
            $self->{score}{lc $letter} = $score;
          }
        }
      }
    }
    close($fh)
      or die "$filename: $!\n";
  }

  $self->_update_scores();

  return 1;
}

sub add_guess {
  my ($self, $guesses) = @_ or die "Method call requires hashref of guesses";
  if (! $guesses || ref $guesses ne 'HASH') {
    die "Need a hashref of guesses";
  }

  if ($guesses->{correct} && $guesses->{correct} =~ m#([\sa-z]{5})#i) {
    my @letters = split('', lc $1);
    for (my $i = 0; $i < @letters; $i++) {
      my $letter = $letters[$i];
      my $existing = $self->{correct}[$i];
      if ($letter =~ m#^[a-z]#) {
        if ($existing && $letter ne $existing) {
          die "Conflicting letter '$letter' for position $i (was $existing";
        }

        # Only store actual lowercase letters
        $self->{correct}[$i] = $letter;
      }
    }
  }

  if ($guesses->{present} && $guesses->{present} =~ m#([\sa-z]{5})#i) {
    my @letters = split('', lc $1);
    for (my $i = 0; $i < @letters; $i++) {
      my $letter = $letters[$i];
      if ($letter =~ m#^[a-z]#) {
        $self->{present}[$i]{$letter}++;
      }
    }
  }

  if ($guesses->{absent} && $guesses->{absent} =~ m#([\sa-z]{5})#i) {
    my @letters = split('', lc $1);
    foreach my $letter (@letters) {
      if ($letter =~ m#^[a-z]#) {
        $self->{absent}{$letter}++;
      }
    }
  }
}

# Calculate, cache, and return the list of possible matches.
# THIS REDUCES THE CACHED WORDLIST
sub get_possible_matches {
  my ($self) = @_ or die "This is a method call";

  # Get words that match known letter positions
  if ($self->{correct}) {
    my $pattern = '';
    foreach my $letter (@{$self->{correct}}) {
      $pattern .= $letter ? $letter : '[a-z]';
    }
    foreach my $word (grep { !/^$pattern$/ } keys %{$self->{words}}) {
      delete $self->{words}{$word};
    }
  }

  # Eliminate words containing banned letters
  if ($self->{absent}) {
    my $pattern = join('', '[', keys(%{$self->{absent}}), ']');
    foreach my $word (grep { /$pattern/} keys %{$self->{words}}) {
      delete $self->{words}{$word};
    }
  }

  # Eliminate words with correct letters in absent places
  if ($self->{present}) {
    for (my $col = 0; $col < @{$self->{present}}; $col++) {
      my @letters = keys %{$self->{present}[$col]};
      if (@letters) {
        # Eliminate words with forbidden letters in a given column
        my $pattern = '[a-z]' x ($col);
        $pattern .= join('', '[', @letters, ']');
        $pattern .= '[a-z]' x (scalar @{$self->{present}} - $col - 1);

        foreach my $word (grep { /^$pattern$/} keys %{$self->{words}}) {
          delete $self->{words}{$word};
        }
      }
    }
  }

  my @words;
  foreach my $word (sort keys %{$self->{words}}) {
    push(@words, $word . ' (' . $self->{words}{$word}{score} . ', ' . ($self->{words}{$word}{used} ? 'used' : 'unused') . ')'); 
  }
  return @words;
}


# TODO
# Implement functions that return results ordered by score and whether they've been used before
# Most likely -- rewrite get_possible_matches as a function to solely reduce the wordlist, call it from add_guess, and possibly make add_guess only apply new patterns, then make a separate function return the cached, reduced list as desired.

1;
