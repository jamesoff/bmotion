# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


#bind pub - "!nl" pubm_nl_dutchify

proc bMotion_plugin_complex_dutchify_single_word_replace { in out line } {
  regsub -nocase -all "\[\[:<:\]\]$in\[\[:>:\]\]" $line $out line
  return $line
}


proc bMotion_plugin_complex_dutchify_makeDutch { line } {
  set line [string map -nocase { cow koe } $line]

  #i -> ik
  regexp -nocase -all {[[:<:]]i\'m[[:>:]]} $line {i am} line
  regexp -nocase -all {[[:<:]]it\'s[[:>:]]} $line {it is} line
  regexp -nocase -all {[[:<:]]you\'re[[:>:]]} $line {you are} line
  set line [bMotion_plugin_complex_dutchify_single_word_replace i ik $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace "(is|am) called" "heet" $line]
  regsub -nocase -all {[[:<:]]a(n)?[[:>:]]} $line {een} line
  set line [bMotion_plugin_complex_dutchify_single_word_replace it het $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace am ben $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace are bent $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace "reserved sign" "gereserveerd bordje" $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace "to be" zijn $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace no nee $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace {is (.+)} {\1 is} $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace he hij $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace of van $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace the de $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace this dit $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace at in $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace on op $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace and en $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace has heeft $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace yes ja $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace how hoe $line]
  set line [bMotion_plugin_complex_dutchify_single_word_replace who wie $line]


  #you -> je
  regsub -nocase -all {[[:<:]]you[[:>:]]} $line {je} line

  #...ed --> ge...d
  regsub -nocase -all {(\w+)ed[[:>:]]} $line {ge\1d} line

  #f... -> oph...
  #regsub -nocase -all {[[:<:]]c(\w+)} $line {k\1} line

  #...ify -> ver...en
  regsub -nocase -all {[[:<:]](.+?)ify[[:>:]]} $line {ver\1en} line


  set line [string map -nocase { "to be or not too be that is the question" "er zijn of er niet zijn is de vraag" question vraag chicken kip hello hoi line lijn my mijn have heb nice leuke name naam stolen gestolen want wil must moet hugs knuffelt hug knuffel yes ja thanks dank} $line ]
  set line [string map -nocase { small kleine wrong fout tea thee cosy muts morning morgen think denk that dat too ook also ook does doet middle midden therefore dus perhaps misschien maybe misschien tree BOOM$(* } $line]
  set line [string map -nocase { licking likken licks likt for voor fucks paalt fucking paalen dictionary woordenboek dutch nederlands} $line]
  set line [string map -nocase { honks toetert beeps toetert honk toet} $line]



  #Jeans
  set line [string map -nocase { one een two twee three drie four vier five vijf six zes seven zeven eight acht nine negen ten tien eleven elf twelve twaalf thirteen dertien fourteen veertien fifteen vijftien sixteen zestien seventeen zeventien eighteen achttien nineteen negentien } $line]
  set line [string map -nocase { twenty twintig thirty dertig fourty veertig fifty vijftig sixty zestig seventy zeventig eighty tachtig ninety negentig hundred honderd thousand duizend } $line]
  set line [string map -nocase { first eerste second tweede third derde fourth vierde fifth vijfde sixth zesde seventh zevende eighth achtste ninth negende tenth tiende } $line]
  set line [string map -nocase { where waar when wanneer why waarom what wat } $line]
  set line [string map -nocase { this dit that dat yonder ginds } $line]

  set line [string map -nocase { yesterday gisteren today vandaag tomorrow morgen week week month maand day dag year jaar second seconde minute minuut hour uur } $line]
  set line [string map -nocase { next volgend previous vorig } $line]
  set line [string map -nocase { morning ochtend afternoon middag evening avond night nacht } $line]
  set line [string map -nocase { good goed bad slecht nice leuk pretty mooi ugly lelijk beautiful mooi hideous afzichtelijk disgusting walgelijk } $line]
  set line [string map -nocase { have heeft walk loop walks loopt do doe does doet sleep slaap sleeps slaapt breathe adem breathes ademt look kijk looks kijkt } $line]
  set line [string map -nocase { sit zit sits zit run ren runs rent } $line]

  set line [string map -nocase { sun zon moon maan star ster sky hemel  heaven hemel hell hel ground grond grass gras cloud wolk } $line]
  set line [string map -nocase { bird vogel lion leeuw tiger tijger dog hond cat kat fish vis } $line]
  set line [string map -nocase { dictionary woordenboek word woord translation vertaling } $line]
  set line [string map -nocase { car auto bike fiets train trein plane vliegtuig truck vrachtwagen boat boot ship schip balloon ballon } $line]
  set line [string map -nocase { under onder behind achter before voor } $line]

  set line [string map -nocase { gives geeft throws gooit tickles kietelt } $line]

  #panique
  set line [string map -nocase { not niet talk praten book boek pencil potlood rubber condoom theacup theekopje boat boot } $line]

  set line [bMotion_plugin_complex_dutchify_single_word_replace to naar $line]

  regsub -nocase -all {[[:<:]](ver)(.+?)([auiou])\3([^auiou])(en)[[:>:]]} $line {\1\2\3\4\5} line

  regsub -nocase -all {[[:<:]]([a-z]{4,})ing[[:>:]]} $line {\1end} line

  return $line
}

proc bMotion_plugin_complex_dutchify {nick host handle channel text} {

  regsub "!nl +(.+)" $text {\1} text

  set leetMode 0
  if [regexp -nocase -- "^-l(ee|33)t (.+)" $text blah bling line] {
    set leetMode 1
  } else {
    set line $text
  }

  set line [bMotion_plugin_complex_dutchify_makeDutch $line]

  if {$leetMode == 1} {
    set line [makeLeet2 $line]
  }

  puthelp "PRIVMSG $channel :$nick: $line"
}

bMotion_plugin_add_complex "dutchify" "^!nl" 100 "bMotion_plugin_complex_dutchify" "en"