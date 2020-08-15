package Sport_Collector::OS_Funcs;
use strict; use warnings;
#=========================================================================
# DECLARATION OF THE PACKAGE
#=========================================================================
# following text starts a package:
use Shob_Tools::Settings;
use Shob_Tools::General;
use Shob_Tools::Error_Handling;
use Shob_Tools::Html_Stuff;
use Sport_Functions::Get_Land_Club;
use Sport_Functions::Readers;
use Sport_Collector::Teams;
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
 '&format_os',
 '&read_schaatsers',
 #========================================================================
);

our $schaatsers;
sub read_schaatsers()
{
 foreach my $s ('D', 'H')
 {
 my $fullname = File::Spec->catdir($csv_dir, "schaatsers${s}.csv");
 my $content = read_csv_file($fullname);
 while(my $line = shift(@$content))
 {
  my @parts = @$line;
  $schaatsers->{$parts[0]} = $parts[1];
 }
}
}

our $maxwarn = 5; our $totalwarn = 0;

sub min_sec($$)
{# (c) Edwin Spee
 # versie 1.1 19-mrt-2005 met argument is 500m om zonder minuten te printen
 # versie 1.0 12-mrt-2005 initiele versie/bijna terug in oude vorm

 my ($time, $is500m) = @_;

 my $min = int($time / 60);
 my $sec = $time - 60 * $min;
 if ($min > 0 and not $is500m)
 {
  my $with_ms = sprintf('%.0f min %05.3f s', $min, $sec);
  my $without_ms = sprintf('%.0f min %05.2f s', $min, $sec);
  return ($with_ms =~ m/0 s/ ? $without_ms : $with_ms);
 }
 else
 {
  return sprintf('%.2f s', $time);
 }
}

sub min_sec_record($$)
{# (c) Edwin Spee
 # versie 1.3 19-mrt-2005 met argument is500m om zonder minuten te printen
 # versie 1.2 12-mrt-2005 hernoemd + optie record
 # versie 1.1 10-mrt-2005 als $t een string, return $t
 # versie 1.0 07-mrt-2005 initiele versie

 my ($t, $is500m) = @_;

 if (ref ($t) eq 'ARRAY')
 {
  my $time = $t->[0];
  my $record = $t->[1];
  my $string = min_sec($time, $is500m);
  return ($time, $string, " ($record)");
 }
 elsif ($t =~ m/[a-z]/iso)
 {
  return (-1, $t, '');
 }
 else
 {
  my $string = min_sec($t, $is500m);
  return ($t, $string, '');
 }
}

sub schaats_dtb2html($$$)
{# (c) Edwin Spee

 my ($all, $data, $isMs) = @_;
 my $total;
 my $maxi = $all ? (scalar @$data) : 2;
 my $outtxt = '';
 for (my $i = 1; $i < $maxi; $i++)
 {
  if (scalar @$data == 0) {next;}
  my $row_uitsl = $data->[$i];
  my $row_txt = '';

  my $is500m = (scalar @$row_uitsl == 4);

# maak tekst velden:
  my $nr = $row_uitsl->[0];
  if ($nr < 1) {$nr = $nbsp;}
  my $schaatser_id = $row_uitsl->[1];
  my $landcode = substr($schaatser_id, 0, 2);
  my $naam_plus_land;
  if (ref $schaatser_id eq 'ARRAY')
  {
   my $tmp = $schaatser_id;
   $schaatser_id = $tmp->[0];
   $naam_plus_land = expand($schaatser_id, 0) . ' (' . $tmp->[1] . ')';
  }
  elsif (defined $schaatsers->{$schaatser_id})
  {
   $naam_plus_land = $schaatsers->{$schaatser_id} . ' (' . land_acronym($landcode) . ')';
  }
  else
  {
   if ($totalwarn++ < $maxwarn) { warn "onbekend id $schaatser_id\n"; }
   $naam_plus_land = $schaatser_id;
  }
  my ($tijd1, $min_sec1, $record1) = min_sec_record($row_uitsl->[2], $is500m);
  my ($tijd2, $min_sec2, $record2) =
   ($is500m ? min_sec_record($row_uitsl->[3], $is500m) : (0, '', ''));
  my $total = (($tijd1 > 0 and $tijd2 > 0) ? sprintf('%.2f s', $tijd1 + $tijd2) : $nbsp);

# maak tekst voor 1 regel:
  if ($all) {$row_txt .= ftdl($nr);}
  $row_txt .= ftdl($naam_plus_land) . "\n";
  if ($is500m)
  {
   if ($all)
   {
    $row_txt .= ftdl($min_sec1 . $record1) . ftdl($min_sec2 . $record2) . ftdl($total);
   }
   else
   {
    $row_txt .= ftdl($min_sec1 . $record1 . ' + ' . $min_sec2 . $record2 . ' = ' . $total);
   }
  }
  elsif ($isMs)
  {
   $row_txt .= ftd({cols => 3}, $row_uitsl->[2] . ' p ');
  }
  else
  {
   $row_txt .= ftd({cols => 3}, $min_sec1 . $record1);
  }
# concatenate regel aan tabel:
  $outtxt .= ($all ? ftr($row_txt) : $row_txt);
 }
 return $outtxt;
}

sub format_os($)
{# (c) Edwin Spee
 # versie 1.0 12-mrt-2005 31-aug-2003 initiele versie

 my ($results) = @_;

 my @links = (
'<a href="#H500">500 m</a>',
'<a href="#H1000">1000 m</a>',
'<a href="#H1500">1500 m</a>',
'<a href="#H5000">5000 m</a>',
'<a href="#H10km">10000 m</a>',
'<a href="#D500">500 m</a>',
'<a href="#D1000">1000 m</a>',
'<a href="#D1500">1500 m</a>',
'<a href="#D3000">3000 m</a>',
'<a href="#D5000">5000 m</a>');

 my @names = (
'<a name="H500">500 meter Heren</a>',
'<a name="H1000">1000 meter Heren</a>',
'<a name="H1500">1500 meter Heren</a>',
'<a name="H5000">5 km Heren</a>',
'<a name="H10km">10 km Heren</a>',
'<a name="D500">500 meter Dames</a>',
'<a name="D1000">1000 meter Dames</a>',
'<a name="D1500">1500 meter Dames</a>',
'<a name="D3000">3 km Dames</a>',
'<a name="D5000">5 km Dames</a>');

 my $with_teampursuit = scalar @{$results} > 10;
 if ($with_teampursuit)
 {push (@links, (
  '<a href="#Hachterv">Team pursuit Heren</a>',
  '<a href="#Dachterv">Team pursuit Dames</a>'));
  push (@names, (
  '<a name="Hachterv">Team pursuit Heren</a>',
  '<a name="Dachterv">Team pursuit Dames</a>'));
 }

 my $with_massStart = scalar @{$results} > 12;
 if ($with_massStart)
 {push (@links, (
  '<a href="#HmassaStart">Massa Start Heren</a>',
  '<a href="#DmassaStart">Massa Start Dames</a>'));
  push (@names, (
  '<a name="HmassaStart">Massa Start Heren</a>',
  '<a name="DmassaStart">Massa Start Dames</a>'));
 }

 my $samenv = '';
 for (my $i = 0; $i < scalar @links; $i++)
 {
  $samenv .= ftr(ftdl($links[$i]) . schaats_dtb2html(0, $results->[$i], $i >= 12));
 }

 my $compleet = '';
 for (my $i = 0; $i < scalar @names; $i++)
 {
  $compleet .= ftr(fth({cols => 5, class => 'h'}, $names[$i])) .
               schaats_dtb2html(1, $results->[$i], $i >= 12);
 }

 my $outtxt = ftable('border', $samenv) . "<hr>\n" . ftable('border', $compleet);
 return $outtxt;
}

return 1;
