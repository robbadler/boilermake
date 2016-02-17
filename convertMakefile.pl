#!/bin/perl -w
#

use File::Basename;


sub AddSubMk
{
   my ($target, $sources, $mocs) = @_;


   print "inside AddSubMk\n";
   print "target = $$target\n";
   print "sources = " . join(' ', @$sources) . "\n";
   print "mocs = " . join(' ', @$mocs) . "\n";

   my $fileName .= basename($$target);

#$fileName =~ s/\..*//;
   $fileName .= ".mk";

   print "Create file $fileName \n";
   open (my $subMkHandle, '>', $fileName) or die "Cannot create $fileName : $!";

   print $subMkHandle "TARGET    := $$target\n";
   print $subMkHandle "\n";
   print $subMkHandle "SRC_MOC_H := " . join(" \\\n             ", @$mocs) . "\n";
   print $subMkHandle "\n";
   print $subMkHandle "SOURCES   := " . join(" \\\n             ", @$sources) . "\n";

   close $subMkHandle;
}
sub ReadOldMakefile
{
   my ($makefile) = @_;

   my $nonDET = 0;
   my $ifDefToSkip = 0;
   my $printSources = 0;
   my $srcStrMatch;
   my $srcMocMatch;


   my $target;
   my @sources;
   my @mocs;
   open (my $makefileHandle, '<', $makefile) or die "cannot open file $makefile for read :$!";
   while (my $row = <$makefileHandle>)
   {
      chomp $row;
      $row =~ s/^\s+|\s+$//g;
#next if ( $row =~ m/^#/ );
      if ( $row =~ m/ifndef MK_USE_DET/ )
      {
         $nonDET = 1;
         ++$ifDefToSkip;
      }
      if ( $nonDET )
      {
         next unless ( $row =~ m/else/ );
         --$ifDefToSkip;
         if (! $ifDefToSkip)
         {
            $nonDET = 0;
         }
         next;
      }
      #print "$row\n";

      my $targetNum = 0;
      if ($row =~ m/^TARGET(\d+)\s+=(.*)/)
      {
         print "target = $row\n";
         $targetNum = $1;
         $target = $2;
         $target =~ s/^\s+|\s+$//g;
         $srcStrMatch = "TARGET" . $targetNum . "_SRC";
         $srcMocMatch = "TARGET" . $targetNum . "_MOC_H";
         next;
      }
      if ( defined($srcStrMatch) and $row =~ m/^${srcStrMatch}.*=(.*)/)
      {
         $printMocs = 0;
         my $src = $1;
         $src =~ s/^\s+|\s+$//g;
         print "sources def = $row\n";
         if ($src =~ m/\\$/)
         {
            $printSources = 1;
         }
         else
         {
            $printSources = 0;
         }
         $src=~ s/\\//;
         push(@sources, split(" ", $src));
         next;
      }
      if ($printSources and $row ne '')
      {
         $printMocs = 0;
         $row =~ s/^\s+|\s+$//g;
         if ($row =~ m/\\$/)
         {
            $printSources = 1;
         }
         else
         {
            $printSources = 0;
         }
         print "sources continue = $row\n";
         $row =~ s/\\//;
         push(@sources, split(" ", $row));
         next;
      }

      if ( defined($srcMocMatch) and $row =~ m/^${srcMocMatch}.*=(.*)/)
      {
         $printSources = 0;
         my $moc = $1;
         $moc =~ s/^\s+|\s+$//g;
         print "mocs def = $row\n";
         if ($moc =~ m/\\$/)
         {
            $printMocs = 1;
         }
         else
         {
            $printMocs = 0;
         }
         $moc=~ s/\\//;
         push(@mocs, split(" ", $moc));
         next;
      }
      if ($printMocs and $row ne '')
      {
         $printSources = 0;
         $row =~ s/^\s+|\s+$//g;
         if ($row =~ m/\\$/)
         {
            $printMocs = 1;
         }
         else
         {
            $printMocs = 0;
         }
         print "mocs continue = $row\n";
         $row =~ s/\\//;
         push(@mocs, split(" ", $row));
         next;
      }


      $printSources = 0;
      $printMocs = 0;
      if (@sources and defined($target))
      {

         print "calling AddSubMk\n";
         print "target = $target\n";
         print "sources = " . join(' ', @sources) . "\n";
         print "mocs = " . join(' ', @mocs) . "\n";



         AddSubMk(\$target, \@sources, \@mocs);
         undef $target;
         undef @sources;
         undef @mocs;
      }
      #print "other: $row\n";
   }
   close $makefileHandle;
}

ReadOldMakefile $ARGV[0];
