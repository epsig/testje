package Sport_Collector::Stats_Eredivisie;
use strict; use warnings;
#=========================================================================
# DECLARATION OF THE PACKAGE
#=========================================================================
# following text starts a package:
use Shob_Tools::Settings;
use Shob_Tools::General;
use Shob_Tools::Html_Stuff;
use Shob_Tools::Html_Head_Bottum;
use Shob_Tools::Idate;
use Shob::Functions;
use Sport_Functions::Overig;
use Sport_Functions::Filters;
use Sport_Functions::Get_Land_Club;
use Sport_Functions::Results2Standing; # voor officieus
use Sport_Functions::Get_Result_Standing; # voor officieus
use Sport_Collector::Archief_Voetbal_NL;
use Sport_Collector::Archief_Voetbal_NL_Uitslagen;
use Sport_Collector::Archief_Voetbal_NL_Standen;
use Sport_Collector::Archief_Voetbal_NL_Topscorers;
use Sport_Collector::Teams;
use Sport_Collector::Geel_Rood;
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
 '&get_stats_eredivisie',
 '&officieuze_standen',
 #========================================================================
);

sub get_lijst_topscorers($$)
{# (c) Edwin Spee

 my ($yrA, $yrB) = @_;
 my @lijst = ();
 for (my $year = $yrA; $year <= $yrB; $year++)
 {my $seizoen = yr2szn($year);
  my $tpsc = get_topscorers_eredivisie($seizoen);
# print "$seizoen $tpsc->[1][1] $tpsc->[1][3]\n";
  push @lijst, [$seizoen,$tpsc];
 }
return \@lijst;
}

sub get_lijst_extremen_uit_standen($$)
{# (c) Edwin Spee

# record:
# t/m 1961-2 34 wedstr., 1962-3 t/m 1965-6 30 wedstr., vanaf 1966-7 34 wedstr.
# 1971-2: FC Twente'65 13 tegengoals
# 1958-9: SHS 111 tegengoals
# 1966-7: Ajax 122 goals
# 1971-2: Volendam 16 goals
# 1962-3: de Volewijckers (31 - 102)/30= -71/30 = -2,37
# 1985-6: Heracles (26 - 99)/34 = -73/34 = -2,15
 my ($yrA, $yrB) = @_;
 my @lijst = ();
 for (my $year = $yrA; $year <= $yrB; $year++)
 {my $seizoen = yr2szn($year);
  my $stand = standen_eredivisie($seizoen);
  my @max_g = (0,'');
  my @min_g = (999,'');
  my @max_t = (0,'');
  my @min_t = (999,'');
  my @max_s = (0,'');
  my @min_s = (999,'');
  my $sum = 0;
  for (my $club = 1; $club < scalar @$stand; $club++)
  {my $g = $stand->[$club][4][0] ;
   my $t = $stand->[$club][4][1];
   my $s = $g - $t;
   my $naam = $stand->[$club][0];
   $sum += $g;
   if ($g > $max_g[0]) {@max_g = ($g, $naam);}
   elsif ($g == $max_g[0]) {@max_g = (@max_g, $naam);}
   if ($g < $min_g[0]) {@min_g = ($g, $naam);}
   elsif ($g == $min_g[0]) {@min_g = (@min_g, $naam);}
   if ($t > $max_t[0]) {@max_t = ($t, $naam);}
   elsif ($t == $max_t[0]) {@max_t = (@max_t, $naam);}
   if ($t < $min_t[0]) {@min_t = ($t, $naam);}
   elsif ($t == $min_t[0]) {@min_t = (@min_t, $naam);}
   if ($s > $max_s[0]) {@max_s = ($s, $naam);}
   elsif ($s == $max_s[0]) {@max_s = (@max_s, $naam);}
   if ($s < $min_s[0]) {@min_s = ($s, $naam);}
   elsif ($s == $min_s[0]) {@min_s = (@min_s, $naam);}
  }
# print "$seizoen, @max_g, @max_t, @max_s\n";
# print "@min_g, @min_t, @min_s\n";
  my $clubs = scalar @$stand - 1;
  my $tot = $clubs * ($clubs-1);
  if ($year == 2019) {$tot = 232;}
  my $gem = $sum / $tot;
# print "totaal: $sum ; gem: $gem \n";
  push @lijst, [$seizoen, \@max_g, \@max_t, \@max_s, \@min_g, \@min_t, \@min_s, $sum, $gem];
 }
 return \@lijst;
}

sub get_namen_expand($)
{# (c) Edwin Spee

 my $p = $_[0];
 if (scalar @$p == 2)
 {return expand($p->[1],3);}
 else
 {return expand($p->[1],3) . '<br>' . expand($p->[2],3);}
}

sub get_toeschouwers_tabel($$$)
{# (c) Edwin Spee

 my ($yrA, $yrB, $ABBA) = @_;
 # $yrA = start jaar
 # $yrB = laatste jaar
 # $ABBA = 1: tabel start met $yrA
 # $ABBA = 0: tabel start met $yrB
# zie soccerstats.com

 my $max_toeschouwers = {
'1988-1989' => [24300,'PSV'],
'1989-1990' => [24294,'PSV'],
'1990-1991' => [24529,'PSV'],
'1991-1992' => [23900,'PSV'],
'1992-1993' => [25282,'PSV'],
'1993-1994' => [25806,'PSV'],
'1994-1995' => [28023,'Feyenoord'],
'1995-1996' => [26389,'Feyenoord'],
'1996-1997' => [48764,'Ajax'],
};

 my $min_toeschouwers = {
'1991-1992' => [2100,"SVV/D '90"],
'1992-1993' => [2040,'Dordrecht'],
'1993-1994' => [3012,'RKC'],
'1994-1995' => [2841,'Dordrecht'],
'1995-1996' => [3508,'RKC'],
'1996-1997' => [4029,'RKC'],
};

 my $tot_toeschouwers = {
'1988-1989' => 2189000,
'1989-1990' => 2431000,
'1990-1991' => 2670000,
'1991-1992' => 2450000,
'1992-1993' => 2630000,
'1993-1994' => 3070000,
'1994-1995' => 3139000,
'1995-1996' => 3156000,
'1996-1997' => 3770000,
};

 my $skip_last = 0;
 my $schatting_lopend = 0;
 my $lopend_szn;
 for (my $year=1997; $year <= $yrB ; $year++)
 {
  my $seizoen = yr2szn($year);
  my $u_szn = $u_nl->{$seizoen};
  if (defined $u_szn)
  {
   my @extr = extremen_gem_aantal_toeschouwers($u_szn);
   $max_toeschouwers->{$seizoen} = [$extr[1], $extr[0]],
   $min_toeschouwers->{$seizoen} = [$extr[3], $extr[2]],
   my ($sum, $tot) = gem_aantal_toeschouwers($u_szn, 1);
 # print "sum, tot = $sum, $tot.\n";
   {if ($tot == 306 or $year == 2019)
    {$tot_toeschouwers->{$seizoen} = $sum;}
    elsif ($tot < 36)
    {$skip_last = 1;}
    else
    {$schatting_lopend = 1;
     $lopend_szn = $seizoen;
     $tot_toeschouwers->{$seizoen} = 306*gem_aantal_toeschouwers($u_szn, 0)}
   }
  }
  else
  {warn "Ongeldig jaar $year in sub get_toeschouwers_tabel.\n";}
 }
 if ($skip_last) {$yrB--;}

 my $out = '<a name="toesch"></a>';
 if ($schatting_lopend)
 {
  $out .= "Schatting van het totaal aantal toeschouwers voor $lopend_szn: ";
  $out .= sprintf('%.1f', $tot_toeschouwers->{$lopend_szn}/1E6) . " miljoen.\n";
 }

 my $tmp_out = '';
 for (my $i = 0; $i <= $yrB - $yrA; $i++)
 {my $year = ( $ABBA ? $yrA + $i : $yrB - $i);
  my $seizoen = yr2szn($year);
  my $mx_ts = $max_toeschouwers->{$seizoen};
  my $mn_ts = $min_toeschouwers->{$seizoen};
  my $tot_ts = $tot_toeschouwers->{$seizoen};
  my $tot = ($year == 2019 ? 232 : 306);
  if (defined $mx_ts and defined $mn_ts and defined $tot_ts)
  {
  $tmp_out .= ftr(ftdl($seizoen)
   . ftdl(sprintf('%.2f M', $tot_ts/1E6))
   . ftdl(sprintf('%.1f k', $tot_ts/(1E3 * $tot)))
   . ftdl($mx_ts->[1]) . ftdl(sprintf('%.1f k', $mx_ts->[0]/1E3))
   . ftdl($mn_ts->[1]) . ftdl(sprintf('%.1f k', $mn_ts->[0]/1E3)) );
  }
  else
  {warn "Ongeldig jaar $year in sub get_toeschouwers_tabel.\n";} # warn again...
 }

 $out .= ftable('border',
  ftr(fth('seizoen')
  . fth({cols => 2}, 'toeschouwers')
  . fth({cols => 2}, 'hoogste gemiddelde') . fth({cols => 2}, 'laagste gemiddelde'))
  . ftr(ftd($nbsp) . fth('totaal') . fth('gem.') . ftd({cols => 4}, $nbsp))
  . $tmp_out);

 return $out;
}

sub get_tabel_extremen_doelpunten($$$$)
{# (c) Edwin Spee

 my ($lijst_extremen, $yrA, $yrB, $ABBA) = @_;
 my $szns = scalar @$lijst_extremen;
 my $out = '';
 for (my $i = 0; $i < $szns; $i++)
 {my $rij = $lijst_extremen->[ $ABBA ? $i : $szns - 1 - $i ];
  my $szn = $rij->[0];
  if ($szn ge yr2szn($yrA) and $szn le yr2szn($yrB))
  {$out .= ftr(ftdl($szn)
        . ftdl(get_namen_expand($rij->[1]))
        . ftdr($rij->[1][0])
        . ftdl(get_namen_expand($rij->[4]))
        . ftdl($rij->[4][0]) . qq(\n)
        . ftdl(get_namen_expand($rij->[2]))
        . ftdr($rij->[2][0])
        . ftdl(get_namen_expand($rij->[5]))
        . ftdl($rij->[5][0]) . qq(\n)
        . ftdl(get_namen_expand($rij->[3]))
        . ftdl('+' . $rij->[3][0])
        . ftdl(get_namen_expand($rij->[6]))
        . ftdl($rij->[6][0]));
  }
 }
 $out = '<a name="extr_goals"></a>'
 . ftable('border',
    ftr(fth('seizoen')
    . fth({cols => 2}, 'meeste goals')
    . fth({cols => 2}, 'minste goals') . qq(\n)
    . fth({cols => 2}, 'meeste<br>tegengoals')
    . fth({cols => 2}, 'minste<br>tegengoals') . qq(\n)
    . fth({cols => 2}, 'hoogste<br>doelsaldo')
    . fth({cols => 2}, 'laagste<br>doelsaldo'))
  . $out);
 $out .= "seizoen 2019-2020 is over 232 wedstrijden; overige over 306.";
 return $out;
}

sub get_namen_topscorers($)
{# (c) Edwin Spee

 my $tp = $_[0];
 if ($tp->[1][3] > $tp->[2][3])
 {return expand_voetballers($tp->[1][1], 'std') . ' (' . expand($tp->[1][2],0) . ')';}
 else
 {return expand_voetballers($tp->[1][1], 'std') . ' (' . expand($tp->[1][2],0) . ')<br>' .
         expand_voetballers($tp->[2][1], 'std') . ' (' . expand($tp->[2][2],0) . ')';}
}

sub get_penalties($)
{# (c) Edwin Spee

 my $szn = $_[0];
 #seizoen ; totaal genomen ; benut ; totaal thuis team

    if ($szn eq '1988-1989') {return [97, -1, -1];}
 elsif ($szn eq '1989-1990') {return [70, -1, -1];}
 elsif ($szn eq '1990-1991') {return [52, -1, -1];}
 elsif ($szn eq '1991-1992') {return [83, 67, 55];}
 elsif ($szn eq '1992-1993') {return [64, 47, -1];}
 elsif ($szn eq '1993-1994') {return [63, 50, -1];}
 elsif ($szn eq '1994-1995') {return [83, 62, 51];}
 elsif ($szn eq '1995-1996') {return [83, 64, -1];}
 elsif ($szn eq '1996-1997') {return [84, 64, -1];}
 elsif ($szn eq '1997-1998') {return [91, 73, -1];}
 elsif ($szn eq '1998-1999') {return [58, -1, -1];}
 elsif ($szn eq '1999-2000') {return [57, -1, -1];}
 else {return [-1, -1, -1];}
}

sub get_tabel_doelpunten($$$$$$)
{# (c) Edwin Spee

 my ($lijst_extremen, $lijst_tpsc, $yrA, $yrB, $with_penalties, $ABBA) = @_;

# record totaal aantal doelpunten: 83-84: 1079, 58-59: 1188
 my $out = '';
 my $szns = scalar @$lijst_extremen;
 for (my $i = 0; $i < $szns; $i++)
 {my $rij_e = $lijst_extremen->[ $ABBA ? $i : $szns - 1 - $i ];
  my $rij_t = $lijst_tpsc->[ $ABBA ? $i : $szns - 1 - $i ][1];
  my $szn = $rij_e->[0];
  if ($szn ge yr2szn($yrA) and $szn le yr2szn($yrB))
  {
   my $tmp_out = ftdl($szn)
         . ftdr($rij_e->[7])
         . ftdl(sprintf('%.2f', $rij_e->[8]))
         . ftdl(get_namen_topscorers($rij_t))
         . ftdl($rij_t->[1][3]);
   if ($with_penalties)
   {my $penalties = get_penalties($szn);
    $tmp_out .= ftdl(no_missing_values($penalties->[0])) .
            ftdl(no_missing_values($penalties->[1]));}
   $out .= ftr($tmp_out);
 }}
 $out = '<a name="tot_goals"></a>'
 . ftable('border', "\n" .
     ftr(fth('seizoen')
     . fth('doelpunten')
     . fth('gem.')
     . fth({cols => 2}, 'topscorer')
     . ($with_penalties ? fth("penalty's") . fth('benut') : '') )
   . $out);
 return $out;
}

sub get_tabel_ruimste_zege($$$)
{# (c) Edwin Spee

 my ($yrA, $yrB, $ABBA) = @_;
# eruit sinds 28 juni: 1994-1995;Arnold (NAC);4 1995-1996;Arnold (NAC);4
 my $out = '';
 for (my $j = 0; $j <= $yrB - $yrA; $j++)
 {my $year = ( $ABBA ? $yrA + $j : $yrB - $j);
  my $seizoen = yr2szn($year);
  my $pu_all = $u_nl->{$seizoen};
  my $tmp_out = ftdl($seizoen);
  for (my $ii = 1; $ii <= 3; $ii++)
  {my $pu = filter_opvallend($pu_all, $ii);
   my $ctn = scalar @$pu ;
   my $cell = '';
   for (my $i=1; $i<$ctn; $i++)
   {$cell .= expand($pu->[$i][0],3) .'-'.expand($pu->[$i][1],3);
    if ($i < $ctn-1) {$cell .= "<br>\n";}
   }
   $tmp_out .= ftdl($cell) . "\n";
   $cell = '';
   for (my $i=1; $i<$ctn; $i++)
   {$cell .= $pu->[$i][2][1] . '-' . $pu->[$i][2][2];
    if ($i < $ctn-1) {$cell .= "<br>\n";}
   }
   $tmp_out .= ftdr($cell) . "\n";
  }
  $out .= ftr($tmp_out);
 }
 $out = '<a name="extr_uitsl"></a>'
 . ftable('border',
  ftr(fth('seizoen') . fth({cols => 2}, 'ruimste zege') .
  fth({cols => 2}, 'meeste treffers <br> (&eacute;&eacute;n van beide)') .
  fth({cols => 2}, 'hoogste totaal'))
  . $out);
 return $out;
}

sub get_toeschouwers_tabel2($$$)
{# (c) Edwin Spee

# Games with highest attandence:
# 88-89 Ajax - Feijenoord 52.000 [Olympic Stadium Amsterdam, sold out]
# 89-90 Ajax - PSV        52.000
# 90-91 Ajax - PSV        52.000
#       Ajax - Feijenoord 52.000
#       Ajax - Vitesse    52.000
# 91-92 Ajax - Feijenoord 48.000
#       Ajax - PSV        48.000
#       Feijenoord - Ajax 48.000
#       [ Both de Kuip and the Olympic Stadium again were sold out, but
#        because of safety-measures less tickets were made available ]
# 92-93 Feijenoord - Ajax 47.644

 my ($yrA, $yrB, $ABBA) = @_;

 my $out = << "EOF";
<table border cellspacing=0>
<tr><th>seizoen<th colspan=2>best bezocht<th colspan=2>minst bezocht
EOF

 for (my $j = 0; $j <= $yrB - $yrA; $j++)
 {
  my $year = ( $ABBA ? $yrA + $j : $yrB - $j);
  my $seizoen = yr2szn($year);
  my $u_szn = $u_nl->{$seizoen};
  $out .= min_max_aantal_toeschouwers($seizoen, $u_szn);
 }
 $out .= qq(</table>\n);

 return $out;
}

sub tpsc_new($)
{# (c) Edwin Spee

 my $l = $_[0];
 my @ls = sort {$b->[1][1][3] <=> $a->[1][1][3]} @{$l};

 my $out = '';
 for (my $i=0; $i < 20; $i++)
 {
  my $seizoen = $ls[$i]->[0];
  my $speler  = $ls[$i]->[1][1];
  $out .= ftr(ftdl($seizoen)
  . ftdl(expand_voetballers($speler->[1], 'std') . ' (' . expand($speler->[2],0) . ')')
  . ftdl($speler->[3]));
 }

 return ftable('border', $out);
}

sub get_stats_eredivisie($$$)
{# (c) Edwin Spee

 my ($yr1, $yr2, $all_data) = @_;
# $all_data = 0: nieuwe optie voor epsig.nl
# $all_data = 1: optie voor xs4all/~spee: wel met geel/rood
# $all_data = 2: optie voor stats...more

 my $yrA = ($all_data == 2 ? first_year() : 1993);

 my $l_extremen  = get_lijst_extremen_uit_standen($yrA, $yr1);
 my $l_tpsc = get_lijst_topscorers($yrA, $yr1);

# TODO Records sinds de invoering van betaald voetbal zijn vetgedrukt.

 my $out = qq(<hr>| <a href="#extr_goals">meeste/minste goals</a>\n) .
   qq(| <a href="#tot_goals">totaal goals/topscorers</a>\n) .
   qq(| <a href="#extr_uitsl">opvallende uitslagen</a>\n);
 if ($all_data)
 {$out .= qq(| <a href="#geel_rood">gele, rode kaarten</a>\n);}
 $out .= qq(| <a href="#toesch">toeschouwersaantallen</a> |<hr>\n);
 $out .= get_tabel_extremen_doelpunten($l_extremen, $yrA, $yr2, 0);
 $out .= "<p>\n";
 $out .= get_tabel_doelpunten($l_extremen, $l_tpsc, $yrA, $yr1, $all_data, 0);
 $out .= "<p>\n";
 $out .= get_tabel_ruimste_zege(1993, $yr2, 0);
 if ($all_data)
 {$out .= "<p>\n" . get_gele_rode_kaarten_tabel(1993, $yr1, 0);}
 $out .= "<p>\n";
 $out .= get_toeschouwers_tabel(1993, $yr2, 0);
 $out .= "<p>\n";
 $out .= get_toeschouwers_tabel2(1993, $yr2, 0);
 $out .= "<p>\n";

 if ($all_data > 1)
 {$out .= tpsc_new ( get_lijst_topscorers( first_year(),  $yr1) );}

 my $dd =max(20090307, $u_nl->{laatste_speeldatum});
return maintxt2htmlpage($out, 'Statistieken eredivisie', 'title2h1',
 $dd, {type1 => 'std_menu'});
}

sub officieuze_standen($$)
{
 my ($type, $yr) = @_;

 my $out = '';
 my $sz1 = yr2szn($yr - 1);
 my $sz2 = yr2szn($yr);
 my $datum_fixed = get_datum_fixed();
 my $yearlast = int($datum_fixed / 10000);
 my $dd =max($datum_fixed, $u_nl->{laatste_speeldatum});
 if (not defined $u_nl->{$sz1})
 {
  $out = "Sorry, season $sz1 is not available.\n";
  return maintxt2htmlpage($out, 'Error Message', 'title2h1', $dd, {type1 => 'std_menu'});
 }

 my $skip2 = not defined $u_nl->{$sz2};
 if ($type ne 'uit_thuis')
 {
  my $u = $u_nl->{$sz1};
  $u = combine_puus($u_nl->{$sz1}, $u_nl->{$sz2}) if not $skip2;
# my $title = ($skip2 ? 'tussenstand' : 'eindstand');
# my $s_echt  = u2s($u_nl->{$sz1}, 1, 1, "$title $sz1", -1);
  my $s_total = u2s(filter_datum($yr*1E4, $yr*1E4 + 1300, $u), 1, 1, "kalenderjaar $yr", -1);
  my $s_wintr = u2s(filter_datum(      0, $yr*1E4 + 1300, $u_nl->{$sz2}), 1, 1, "stand 2e helft $yr", -1) if not $skip2;
  my $s_lente = u2s(filter_datum($yr*1E4, $yr*1E4 + 1300, $u_nl->{$sz1}), 1, 1, "stand 1e helft $yr", -1);
# my $txt_echt  = get_stand($s_echt , 4, 0, [1]);
  my $txt_total = ($skip2 ? '' : get_stand($s_total, 4, 0, [1]));
  my $txt_wintr = ($skip2 ? '' : get_stand($s_wintr, 4, 0, [1]));
  my $txt_lente = get_stand($s_lente, 4, 0, [1]);
  $out = ftable('border',
   ftr( ftdx('vtop', ftable('border', $txt_lente)) .
#       ftdx('vtop', ftable('border', $txt_echt )) .
        ($skip2 ? '' : ftdx('vtop', ftable('border', $txt_wintr))) .
        ($skip2 ? '' : ftdx('vtop', ftable('border', $txt_total))) )) . "\n&nbsp;<p>&nbsp;\n" . $out;
 }
 else
 {
  my $s_total = u2s($u_nl->{$sz2},   1, 1, "uit + thuis $sz2", -1);
  my $s_home  = u2s($u_nl->{$sz2}, 101, 1, "thuis $sz2", -1);
  my $s_away  = u2s($u_nl->{$sz2}, 201, 1, "uit $sz2", -1);
  my $txt_total = get_stand($s_total, 4, 0, [1]);
  my $txt_home  = get_stand($s_home , 4, 0, [1]);
  my $txt_away  = get_stand($s_away , 4, 0, [1]);
  $out = ftable('border',
   ftr( ftdx('vtop', ftable('border', $txt_home )) .
        ftdx('vtop', ftable('border', $txt_away )) .
        ftdx('vtop', ftable('border', $txt_total)) )) . "\n&nbsp;<p>&nbsp;\n" . $out;
 }

 my $title = ($type ne 'uit_thuis' ? 'Winterkampioen en jaarstanden eredivisie' : 'Uit- en thuis standen eredivisie');
 #
 my $options = '';
 for (my $i = 1993; $i <= $yearlast; $i++)
 {
  if ($i == $yr) {next;}
  my $selected = ($i == $yr -1 ? 'selected ' : '');
  if ($type ne 'uit_thuis')
  {
   $options .= qq(<option ${selected}value="$i">$i\n);
  }
  else
  {
   my $szn = yr2szn($i);
   $options .= qq(<option ${selected}value="$i">$szn\n);
  }
 }
 $out = << "EOF";
<form method=get action=https://www.epsig.nl/cgi-bin/shob/officieuze_standen.pl>
Ga naar andere jaren:
<input type=hidden name=type value="$type">
<select name="year">
$options
</select>
<input type="submit" value="verstuur">
</form>
$out
EOF

 return maintxt2htmlpage($out, $title, 'title2h1', $dd, {type1 => 'std_menu'});
}

return 1;