# ----------------------------------------------------------------------
#
# setup file for the search.cgi script
#
# CGI Magic April 11th 1997
#
# V1.01
#
# http://www.spells.com/cgi/
#
# ----------------------------------------------------------------------

# --- $root_web_path is the server path to the beginning of the directory
# --- tree that you want to search. Your searches all start in this 
# --- directory - note that you can use the "hidden_files" hidden input
# --- on the html search form to hide any directory or file from the search
# --- engine's view, as well as $banned_files below for files that must
# --- never be seen.

$root_web_path = "$ENV{'DOCUMENT_ROOT'}";

# --- $server_url is the actual url for this site, and will be prepended
# --- to hits to create a hypertext reference.

$server_url = "http://$ENV{'SERVER_NAME'}";

# --- $search_script exists to allow you to change the name reference
# --- of the search script, so that, for instance, the script could be
# --- encapsulated in a .bat file. 

$search_script = "search";

# --- $banned_files is a list of any files/directories that must 
# --- NEVER be accessible, whatever the settings in the html input file. 
# --- This prevents someone from making a mirror version of the html 
# --- input form and submitting it with a blank unwanted_files list, 
# --- in order to view all the files on the site.

if ( $ENV{'SERVER_NAME'} =~ m/epsig/i )
{
 $banned_files = "feest2812/|phpmyadmin/|wilma40/|divers/|opinion/|p-b/|pictures/|bookmarks/|include/|fotoalbum/|search/|/private(.*)html";
}
else
{
#$banned_files = "search/|cgi/|/private(.*)html";
 $banned_files = "search";
}

# --- following are subroutines that can be tailored to fit your site
# ----------------------------------------------------------------------


# --- print out the html header ----------------------------------------
sub PrintHeaderHTML
{
    local($user) = @_;
    print <<__HEADERHTML__;
<html><head><title>Resultaten zoekopdracht</title>
<style type="text/css">
body{background:white;color:black;font-family:"Verdana","Arial";font-size:9pt}
h1{font:bold;font-size:12pt}h2{font:bold;font-size:11pt}
th,td{font-size:9pt;padding-top:2pt;padding-bottom:2pt;padding-left:4pt;padding-right:4pt}
</style>
</head>
<body>
<h1><center>Resultaten van uw zoekopdracht</center></h1>
<center>
<hr><p>
</center>
<center><h2>Het woord <font color=#ff0000><i>$keywords</i></font> 
komt voor in de volgende pagina's:</h2></center>
<table border cellspacing="0" width="100%">
__HEADERHTML__
} 


# --- print out the html body -----------------------------------------
# --- note that if you don't want the display to show the path and ----
# --- filename of the found files, you can delete (/$filename) --------
sub PrintBodyHTML
{
    local($filename, $title) = @_;

    print <<__bodyHTML__;
<tr><td>
<b>
<a href="$server_url/$filename">
$title</a>
</b>
</td><td>
/$filename<br>
</td></tr>
__bodyHTML__

}

# --- print out the html footer ----------------------------------------
sub PrintFooterHTML
{
    local($number_of_hits) = @_;

    print <<__FOOTERHTML__;
</table><br><center><b><font size=-1>Uw zoekopdracht leverde <font color=#ff0000> 
$number_of_hits </font>pagina's op met het woord dat u zocht</b>
</font><br>
<font size=2><i><b>Gebruik 'CTRL-F' om het gezochte woord te vinden in de gevonden pagina's.</b> </i></font>
<br>
<a href=$html_url><b>START EEN NIEUWE ZOEKOPDRACHT</b></a>
<p>
<hr>
</center> </body> </html>
__FOOTERHTML__

}


# --- no hits found message ----------------------------------------
sub PrintNoHitsBodyHTML
{
    print <<__NOHITS__;

<tr> <td colspan="2">
<center>
<h2>Er zijn geen pagina's gevonden waarin het gezochte woord voorkomt.</h2>
</center>
</td></tr>
__NOHITS__

#if ($keywords eq 'doit') {print %ENV;}

} # End of PrintNoHitsBodyHTML


# --- no keyword input message -------------------------------------
sub PrintNoKeywordMessage
{
    print <<__TOEND__;
<html><head><title>Resultaten zoekopdracht</title>
<style type="text/css">
body{background:white;color:black;font-family:"Verdana","Arial";font-size:9pt}
h1{font:bold;font-size:12pt}h2{font:bold;font-size:11pt}
th,td{font-size:9pt;padding-top:2pt;padding-bottom:2pt;padding-left:4pt;padding-right:4pt}
</style>
</head>
<body>
<h1><center>Probleem!</center></h1>
<hr>
<p>
<center>
<b>U MOET &eacute;&eacute;n of meerdere woorden invoeren om te zoeken.</b>
<p>
<a href="$html_url"><b>Opnieuw.</b>
<hr>
</p>
</body></html>

__TOEND__

}
# --------------------------------------------------------------------

# Return true
1;
