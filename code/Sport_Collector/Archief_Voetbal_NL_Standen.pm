package Sport_Collector::Archief_Voetbal_NL_Standen;
use strict; use warnings;
#=========================================================================
# DECLARATION OF THE PACKAGE
#=========================================================================
# following text starts a package:
#use Shob_Tools::Error_Handling;
use File::Spec;
use Shob_Tools::Idate;
use Shob_Tools::General;
use Sport_Functions::Readers;
use Sport_Functions::Overig;
use Sport_Functions::Filters;
use Sport_Functions::Results2Standing;
use Sport_Collector::Archief_Voetbal_NL_Uitslagen;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
@ISA = ('Exporter');
#=========================================================================

#=========================================================================
# CONTENTS OF THE PACKAGE:
#=========================================================================
$VERSION = '18.1';
# by Edwin Spee.

@EXPORT =
(#========================================================================
 '&get_klassiekers',
 '&standen_eerstedivisie',
 '&standen_eredivisie',
 '&first_year',
 '&standen',
 #========================================================================
);

sub read_stand($)
{
 my $filename = shift;
 my $fullname = File::Spec->catdir($csv_dir, $filename);

 if (not -f $fullname) {return [];}

 my @u;
 my $content = read_csv_file($fullname);
 while(my $line = shift(@$content))
 {
  my @parts = @$line;

  if ($parts[0] eq 'title')
  {
   push @u, [$parts[1]];
  }
  elsif (scalar @parts >= 8)
  {
   my $u = [$parts[0],$parts[1],[$parts[2], $parts[3], $parts[4]],$parts[5],[$parts[6],$parts[7]]];
   if (scalar @parts > 8) { push @$u, [$parts[8]]; }
   push @u, $u;
  }
 }
 return \@u;
}

sub read_u2s($)
{
 my $seizoen = shift;
 my $fullname = File::Spec->catdir($csv_dir, 'eredivisie', 'eredivisie_u2s.csv');

 my $content = read_csv_file_szn($fullname, $seizoen);
 my $a; my @b;
 while(my $line = shift(@$content))
 {
  my @parts = @$line;
  if ($parts[0] eq 'title') {$a = $parts[1];}
  else
  {
   my $clubs = $parts[0];
      $clubs =~ s/;/,/g;
   push @b, $clubs;
   push @b, $parts[1];
  }
 }
 return ($a, \@b);
}

sub standen($$)
{# (c) Edwin Spee

my ($seizoen, $divisie) = @_;

if ($divisie eq 'eredivisie')
{return standen_eredivisie($seizoen);}
elsif ($divisie eq '1st')
{return standen_eerstedivisie ($seizoen);}
else {return [];}
}

sub first_year()
{
 return 1956;
}

sub standen_eredivisie($)
{# (c) Edwin Spee

 # aantal duels = 18 * 34 / 2 = 306
 # Note: From 1962-63 to 1965-66 30 games were played, otherwise 34

 my ($seizoen) = @_;

 my $uszn = $u_nl->{$seizoen};
 my $size = 9999;
 if (defined($uszn)) {$size = scalar @{$uszn};}

 if ($seizoen le '1991-1992')
 {
  my $sz = $seizoen;
     $sz =~ s/-/_/;
  return read_stand("eredivisie/eindstand_eredivisie_$sz.csv");
 }
 else
 {
  my ($a, $b) = read_u2s($seizoen);
  my $dd = getidate(laatste_speeldatum($uszn), 0);
  my $pnt_telling = ($seizoen le '1994-1995' ? 2 : 1);
  if ($dd ne '' and ($size < 1 + 17 * 18)) {$a .= " (per $dd)";}
  return u2s($uszn, $pnt_telling, 1, $a, 0, $b);
 }
}

sub standen_eerstedivisie($)
{# (c) Edwin Spee

my ($seizoen) = @_;

my $sz = $seizoen;
   $sz =~ s/-/_/;
return read_stand("eerste_divisie/eerste_divisie_$sz.csv");
}

sub get_klassiekers($)
{# (c) Edwin Spee

 my ($seizoen) = @_;
 my $opv = $u_nl->{$seizoen};
 if (not defined $opv)
 {return [];}
 elsif (scalar @$opv < 7)
 {return [];}
 else
 {my $klass = filter_team (['ajx','psv','fyn'], 2, $opv);
  $klass->[0][0] = 'De traditionele toppers';
  return $klass;
}}

return 1;