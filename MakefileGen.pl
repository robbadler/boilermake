#!/usr/bin/perl
#


use lib '/net/swallow/usr/local/share/perl5/';

use strict;
use warnings;
use Path::Iterator::Rule;
use File::Basename;

die "Usage: $0 DIRs" if not @ARGV;

my $rule = Path::Iterator::Rule->new;
$rule->and(
      $rule->new->skip_dirs("aoi"),
      $rule->new->skip_dirs("glue"),
      $rule->new->name("Makefile")
      );

# takes form of [Makefile [ .mk exists , Makefile uses .mk]]
my %makefiles = ();
my $it = $rule->iter(@ARGV);
while ( my $file = $it->() ) {
   my $dirName = dirname($file);
   my $leafDirName = basename($dirName);
   my $mkFileName = $leafDirName . '.mk';


   $makefiles{ $file }[0] = 'false';
   $makefiles{ $file }[1] = 'false';
   $makefiles{ $file }[2] = 'false';

   my $fullMkFilePath = $dirName . '/' . $mkFileName;
   if ( -e $fullMkFilePath ) {
      $makefiles{ $file }[0] = 'true';
   }
   my $hasDefaultTarget = 'false';
   my $hasTarget = 'false';

   open(my $fh, $file) or die;
   while (my $line = <$fh>) {
      if ($line =~ /^include $mkFileName/) {
         $makefiles{ $file }[1] = 'true';
         #print(" $makefiles{ $file }[0] - $makefiles{ $file }[1]  \n");
      }
      if ($line =~ /DEFAULT_TARGETS = default_targets.mk/) {
         $hasDefaultTarget = 'true';
      }
      if ($line =~ /^TARGET\d+/) {
         $hasTarget = 'true';
      }
      if ($hasTarget eq 'true' and $hasDefaultTarget eq 'true') {
         $makefiles{ $file }[2] = 'true';
      }
   }
   close $fh;
}

print("{| border=\"1\" cellpadding=\"5\" cellspacing=\"0\" align=\"left\" class=\"wikitable sortable\"\n|-\n! style=\"background-color: \#efefef;\" class=\"text\"| File Path\n! style=\"background-color: \#ffdead;\" data-sort-type=\"text\"| Has Boilkermake .mk\n! style=\"background-color: \#ffdead;\" data-sort-type=\"text\"| DET uses .mk\n! style=\"background-color: \#ffdead;\" data-sort-type=\"text\"| Is DET<br />(is Nexus Makefile)\n");
for my $key ( keys %makefiles ) {
   my $mkExists = $makefiles{ $key }[0];
   my $isUsed = $makefiles{ $key }[1];
   my $isDET = $makefiles{ $key }[2];
   print "|-";
   if ($isUsed eq 'true') {
      print("style=\"background-color: lightblue\"");
   }
   if ($isDET eq 'false' and $mkExists eq 'false') {
      print(" style=\"background-color: #BE0032\"");
   }
   if ($mkExists eq 'true' and $isDET eq 'false') {
      print("style=\"background-color: lightblue\"");
   }
   print("\n");
   print "| $key\n| $mkExists\n| $isUsed\n| $isDET\n";
}
print "|}";
