package Shob_Tools::Html_Head_Bottum;
use strict; use warnings;
#=========================================================================
# DECLARATION OF THE PACKAGE
#=========================================================================
# following text starts a package:
use Shob_Tools::Settings;
use Shob_Tools::General;
use Shob_Tools::Error_Handling;
use Shob_Tools::Html_Stuff;
use Shob_Tools::Idate;
use File::Spec;
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
 '&get_robot_string',
 '&maintxt2htmlpage',
 '&get_menu',
 '&menu_bottum',
 '&bespaar_bandbreedte',
 '&bespaar_bandbreedte_ref',
 '$setCookie',
 #========================================================================
);

our $setCookie = get_js_function(File::Spec->catfile('my_scripts', 'tools.js'), 'setCookie');

sub get_robot_string
{# (c) Edwin Spee

 return qq(<meta name="robots" content="noindex,follow">\n);
}

sub bespaar_bandbreedte_ref($)
{# (c) Edwin Spee

 my ($ptxt) = @_;

 $$ptxt =~ s/<!--[^!]*-->//igom;
 if ($$ptxt !~ m/<pre>/iom)
 {
  $$ptxt =~ s/ +/ /igom;
  $$ptxt =~ s/^ *//igom;
 }
 $$ptxt =~ s/ *$//igom;
}

sub bespaar_bandbreedte($)
{# (c) Edwin Spee

 my ($out) = @_;

 $out =~ s/<!--[^!]*-->//igom;
 if ($out !~ m/<pre>/iom)
 {
  $out =~ s/ +/ /igom;
  $out =~ s/^ *//igom;
 }
 $out =~ s/ *$//igom;

 return $out;
}

sub html_head
{# (c) Edwin Spee
 # versie 1.2 14-aug-2005 extra \n bij script type javascript
 # versie 1.1 17-jun-2005 + optie base-url
 # versie 1.0 17-jan-2005 gekopieerd uit web_funcs met kleine aanpassingen

 #<!-- generated by ????.pl -->
 #
 # mooie uitbreidingen: shortcut icon; bv voor sport/klaverjassen
 #
 # <link rel="shortcut icon" href="name.ico" type="image/ico" />
 #
 # en
 #
 # onclick="window.external.AddFavorite('http://www.my-url.nl',document.title);"
 # Deze website toevoegen aan uw favorieten

 my ($title, $phead, $body) = @_;
 #
 # $phead = []: leeg
 # $phead = [$pjs, $pmeta, $pstyle, $plang, [$pbase]]
 #  $pjs = [0]: leeg
 #  $pjs = [1, string]: string (bij lege string wel de js-meta-tag)
 #  $pjs = [2, string]: link naar include-pagina
 #  $pmeta = [0]: leeg
 #  $pmeta = [1, string]: string met meta-tag(s)
 #  $pstyle = [0]: default-style (dus afhankelijk van body)
 #  $pstyle = [1, string]: eigen style definitie in string
 #  $plang  = [0]: default: NL
 #  $plang  = [1, string]: string met landcode (of leeg)
 #  $pbase  = [0,1]: leeg
 #  $pbase  = [2]: base url = www.epsig.nl

 my $head_title =
  qq(<html lang="NL"><head><title>$title</title>\n);
 my $js_meta_tag = ( $body =~ m/<script/imo ?
  qq(<meta http-equiv="Content-Script-Type" content="text/javascript">\n) : '');

 if (not scalar @$phead)
 {# defaults:
  return join('', $head_title, $js_meta_tag, get_style(1, $body),
   "</head><body>\n");
 }
 else
 { #plang nog niet geimplementeerd !!!
   my $hdtxt = $head_title . $js_meta_tag;
   if ($phead->[1][0]==1) {$hdtxt .= $phead->[1][1];}

   #$hdtxt .= ($phead->[2][0]==1? $phead->[2][1] : get_style(1, $body));
   if ($phead->[2][0] == 2)
   {
    if (scalar @$phead > 4 and $phead->[4][0]>=2)
    {
     $hdtxt .= get_style(3, $body);
    }
    else
    {
     $hdtxt .= get_style(2, $body);
    }
   }
   else {$hdtxt .= $phead->[2][0] == 1? $phead->[2][1] : get_style(1, $body)};

   $hdtxt .= ($phead->[0][0]==1? qq(<script type="text/javascript" language="javascript">\n)
    . $phead->[0][1] . '</script>' : '');
   $hdtxt .= ($phead->[0][0]==2? qq(<script type="text/javascript" language="javascript" src="$phead->[0][1]">)
    . '</script>' : '');
   if (scalar @$phead > 4 and $phead->[4][0]==2)
   {$hdtxt .= qq(<base href="$www_epsig_nl/">\n);}
   if (scalar @$phead > 4 and $phead->[4][0]==3)
   {$hdtxt .= qq(<base href="http://www.epsig.nl/">\n);}
   if ($body =~ m/brexit/iso)
   {$hdtxt .= qq(<script type="text/javascript" language="javascript" src="countdown.js"></script>);}
   $hdtxt .= "</head><body>\n";
   return $hdtxt;
 }
}

sub make_top_menu
{# (c) Edwin Spee
 # versie 1.0 17-jan-2005 gekopieerd uit web_funcs met kleine aanpassingen

 my ($ptopmenu, $title) = @_;
 # $ptopmenu = [0]: leeg
 # $ptopmenu = [1]: <h1>$title</h1>
 # $ptopmenu = [2, string]: string
 if ($ptopmenu->[0] == 0)
 {return '';}
 elsif ($ptopmenu->[0] == 1)
 {return "<h1>$title</h1>\n";}
 elsif ($ptopmenu->[0] == 2)
 {return $ptopmenu->[1];}
 else
 {shob_error('strange_else', ["ptopmenu = $ptopmenu"]);}
}

sub maintxt2htmlpage($$$$$)
{# (c) Edwin Spee

 my ($out, $title, $type, $dd, $pmenu) = @_;

 my $newStyle = 0;
 my $options = -1;
 if (ref $out eq 'ARRAY')
 {
  $out = yellow_red($out);
  $newStyle = 1;
  $options  = 2;
 }
 elsif ($out =~ m/div class/)
 {
  $newStyle = 1;
  $options  = 2;
 }

 if ($type eq 'title2h1') {$out = "<h1>$title</h1>\n$out";}

#if (ref $pmenu ne 'HASH') {shob_error('tst_filename', []);}

 my $menu_bottum;
 if (defined($pmenu->{mymenu}))
 {$menu_bottum = $pmenu->{mymenu};}
 elsif ($pmenu->{type1} eq 'no_menu_no_kookie')
 {$menu_bottum = '';}
 elsif ($pmenu->{type1} eq 'no_menu')
 {$menu_bottum = '';}
 else
 {
  my $skip1 = (defined($pmenu->{skip1}) ? $pmenu->{skip1} : -1);
  my $root  = (defined($pmenu->{root}) ? $pmenu->{root} : '');
  my $epsig = (defined($pmenu->{root}) ? 0 : 1);
  if ($pmenu->{type1} eq 'std_menu')
  {
   $menu_bottum = menu_bottum($root, $skip1, $options, $dd, $epsig);
  }
  elsif ($pmenu->{type1} eq 'small_menu')
  {
   my $epsig = 2;
   $menu_bottum = menu_bottum($root, $skip1, $options, $dd, $epsig);
  }
  elsif ($pmenu->{type1} eq 'menu_no_kookie')
  {
   my $skip1 = 99; # TODO skip kan nu alleen gebruikt worden om kookies_string te onderdrukken
   $menu_bottum = menu_bottum($root, $skip1, $options, $dd, $epsig);
  }
  else
  {
   $menu_bottum = menu_bottum($root, $skip1, $options, $dd, $pmenu->{type1});
  }
 }

 my $phead = [ [0], [0], [0], [0]];
 # TODO hash voor phead
 if (defined($pmenu->{robot})) {$phead->[1] = [1, get_robot_string()];}
 if (defined($pmenu->{pjs})) {$phead->[0] = $pmenu->{pjs};}
 if ($newStyle) {$phead->[2] = [2];}
 elsif (defined($pmenu->{style})) {$phead->[2] = [1, $pmenu->{style}];}
 if (defined($pmenu->{baseurl})) {$phead->[4] = [$pmenu->{baseurl}];}

 $out .= $menu_bottum;
 return html_head($title, $phead, $out) . $out . "\n</body></html>\n";
}

sub get_style
{# (c) Edwin Spee

 my ($css, $body) = @_;

 my $margin = ''; my $bgcolor = 'white';
 if ($body =~ m/class=i/imo)
 {
  $margin = ';margin-left:10%;margin-right:10%';
  $bgcolor = '#ffffe0';
 }

 my $style = qq(<style type="text/css">\n) .
  qq(body{background:$bgcolor;color:black$margin;font-family:"Verdana","Arial";font-size:9pt}\n) .
  "h1{font-weight:bold;font-size:12pt}";
 if ($css >= 2)
 {
  my $root = ($css > 2 ? '/' : '');
  return << "EOF"
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" type="text/css" href="${root}epsig.css">
EOF
 }
 elsif ($css == 0)
 {$style .=
  "h2{font-weight:bold;font-size:11pt}h3{font-weight:bold;font-size:10pt}\n".
  "th,td{font-size:9pt;padding-top:2pt;padding-bottom:2pt;padding-left:4pt;padding-right:4pt}\n".
  ".h{background:navy;color:white;font-weight:bold;font-size:11pt}\n".
  '.l{text-align:left}'.
  ".r{text-align:right}.c{text-align:center}\n";
 }
 else
 {
  if ($body =~ m/h2/imo) {$style .= 'h2{font-weight:bold;font-size:11pt}';}
  if ($body =~ m/h3/imo) {$style .= 'h3{font-weight:bold;font-size:10pt}';}
  if ($body =~ m/acronym/imo)
 #{$style .= 'acronym{border-bottom:1px dotted #000;cursor:help;}';}
  {
   $style .= 'acronym{font:italic;cursor:help;}';
  }
  if ($body =~ m/(<th)|(<td)/imo)
  {
   $style .=
    "\nth,td{font-size:9pt;padding-top:2pt;padding-bottom:2pt;padding-left:4pt;padding-right:4pt}\n";
  }
  if ($body =~ m/class="?h/imo)
  {
   $style .= ".h{background:navy;color:white;font-weight:bold;font-size:11pt}\n";
  }
  if ($body =~ m/class="?i/imo)
  {
   $style .= ".i{background:red;color:yellow;font-weight:bold;font-size:11pt}\n";
  }

  my $extra_return = 0;

  if ($body =~ m/class="?k/imo)
  {
   $extra_return = 1;
   $style .= '.k{font-family:"Courier New","Courier";font-weight:bold;font-size:14pt}';
  }
  if ($body =~ m/class="?l/imo)
  {
   $extra_return = 1;
   $style .= ".l{text-align:left}";
  }

  if ($body =~ m/class="?r/imo)
  {
   $extra_return = 1; $style .= ".r{text-align:right}";
  }

  my $zoek_result_c = $body =~ m/class="?c/imo;
  my $zoek_result_s = $body =~ m/class="?s\b/imo;

  if ($zoek_result_c and $zoek_result_s)
  {
   $extra_return = 1; $style .= ".c,.s{text-align:center}";
  }
  elsif ($zoek_result_c)
  {
   $extra_return = 1; $style .= ".c{text-align:center}";
  }
  elsif ($zoek_result_s)
  {
   $extra_return = 1;
   $style .= ".s{text-align:center}"; #liever: text-align:"-" maar wordt slecht ondersteund
  }

  if ($extra_return) {$style .= "\n";}
 }
 if ($body =~ m/class="?screenonly/)
 {
  $style .= << 'EOF';
@media print
{.screenonly {visibility:hidden;}
A:link, A:visited {color:black; text-decoration:none}
A:active {color:marcoon; text-decoration:none}}
@media screen, projection
{.screenonly {visibility:visible;}}
EOF
 }
 $style .= "</style>";
 return $style;
}

sub get_menu
{# (c) Edwin Spee

 my ($root, $skip, $options, $datum, @urls) = @_;

 if ($options == -99) {return '';}
 my $maxUrls = 10;

 my $l_urls = ($#urls+1)/2;
 my $txtout = '';
 my $window = $maxUrls / 2;
 if ($skip < $window)
 {
  $window += ($window - $skip);
 }
 elsif ($skip > $l_urls - $window - 1)
 {
  $window += $skip - ($l_urls - $window - 1);
 }
 for (my $i=0; $i<$l_urls; $i++)
 {
  my $skipi = ($l_urls > $maxUrls and abs($i-$skip) > $window);
  my $skipj = ($i == 0 or $i == $l_urls-1);
  my $skipk = ($i == 1 or $i == $l_urls-2);
  next if $skipi and not ($skipj or $skipk);

  my $links = '';
  if ($skipk and $skipi)
  {
   $links .= ' ... ';
  }
  elsif ($i!=$skip)
  {
   $links .= '<a href="'.$root.$urls[2*$i].'">'.$urls[2*$i+1].'</a>';
  }
  else
  {
   $links .= $urls[2*$i+1];
  }
  if ($options > 1)
  {$txtout .= $links . " |\n";}
  else
  {$txtout .= ftd($links) . "\n";}
 }

 my $dd = 'd.d. ' . $datum ;
 if ($options == -1)
 {$txtout = $txtout . ftd($dd) if $datum ne -1;
  $txtout = ftable('border', "\n" . ftr($txtout));
 }
 elsif ($options > 1 and $datum ne -1)
 {$txtout = '| ' . $txtout . $dd . ' |';}
 elsif ($options > 1)
 {$txtout = '| ' . $txtout;}

 return $txtout;
}

sub menu_bottum($$$$$)
{# (c) Edwin Spee

 my ($dir, $skip, $options, $idate, $type) = @_;

 my $datum = getidate($idate, 0);
 my $hopa1  = ($web_index eq '' ? $www_epsig_nl : "$www_epsig_nl/$web_index");
 my $hopa2  = ($web_index eq '' ? $www_epsig_nl : "$web_index");

 my $empty = ' <td width=10%>&nbsp;</td>';
 my $width = 'width=80%';
 my $wdth2 = ' width=100%';

 my ($gfx_txt, $txt_gfx, $txt_gfx2, $amsrot, $rotams, $rotams2, $versie, $versie2) = (0) x 8;
 if ($type =~ m/(.+);(.dam);(.+)/)
 {
  $gfx_txt  = $1;
  $txt_gfx  = ($gfx_txt eq 'gfx' ? 'txt' : 'gfx');
  $txt_gfx2 = ($gfx_txt eq 'gfx' ? 'tekst-only' : 'met&nbsp;plaatjes');
  $amsrot   = $2;
  $rotams   = ($amsrot eq 'adam' ? 'rdam' : 'adam');
  $rotams2  = ($amsrot eq 'adam' ? 'rotterdams' : 'amsterdams');
  $versie   = $3;
  $versie2  = "_$versie";
  if ($versie eq 'std') {$versie2 = '';}
  $datum = -1;
  $empty = '';
  $width = 'width=100%';
  $wdth2 = '' if $gfx_txt eq 'klein';
 }

 my @pages1 = (
'reactie.html',                       'mail-me',
$hopa2,                               'homepage',
'klaverjas_faq.html',                 'klaverjassen',
'sport.html',                         'sport');
 my @pages2 = (
"$www_epsig_nl/reactie.html",         'mail-me',
$hopa1,                               'homepage',
"$www_epsig_nl/klaverjas_faq.html",   'klaverjassen',
"$www_epsig_nl/sport.html",           'sport');
 my @pages3 = (
'reactie.html',                       'mail-me',
$hopa2,                               'homepage');
 my @pages4 = (
'javascript:NieuwSpel();',            'nieuw&nbsp;spel',
'klaverjas_faq.html',                 'settings/faq',
"kj_${gfx_txt}_$rotams$versie2.html", $rotams2,
"kj_${txt_gfx}_$amsrot$versie2.html", $txt_gfx2,
'reactie.html',                       'mail-me',
$hopa2,                               'homepage',
'sport.html',                         'sport');

 my @pages = @pages1;
    @pages = @pages2 unless $type;
    @pages = @pages3 if $type eq 2;
    @pages = @pages4 if $type =~ m/;/;

 my $menu;
 if ($options == 2)
 {
  $menu  = '<div class="footer">';
  $menu .= get_menu('', $skip, $options, $datum, @pages);
  $menu .= '</div>' . "\n";
 }
 else
 {
  $menu = "<table$wdth2> <tr>$empty\n" .
   "<td $width align=center>" .
   get_menu('', $skip, $options, $datum, @pages) .
   "</td>$empty </tr> </table>\n";
 }

 if ($type =~ m/;/)
 {$menu .= << "EOF";
<script type="text/javascript" language="javascript">
$setCookie
StartSpel();
</script>
EOF
 }

 return $menu;
}

return 1;