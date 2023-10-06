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

  $self->{wordfile}   = catfile($RealBin, "wordlist.txt");
  $self->{usedfile}   = catfile($RealBin, "used.txt");
  $self->{scorefile}  = catfile($RealBin, "scores.txt");

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

# Load the wordlist and create the data structure
sub load_wordlist {
  my ($self, $filename) = @_ or die "This is a method call";

  if ($filename && -f $filename) {
    open(my $fh, "<", $filename)
      or die "$filename: $!\n";
    $self->{words} = {};
    while (my $line = <$fh>) {
      if ($line =~ m#\b([a-z]{5})\b#i) {
        $self->{words}{lc $1} = 1;
      }
    }
    close($fh)
      or die "$filename: $!\n";
  }

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
        $self->{used}{lc $1} = 1;
      }
    }
    close($fh)
      or die "$filename: $!\n";
  }

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

  return 1;
}


1;
