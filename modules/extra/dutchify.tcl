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

####################################
# How this module works:
# - first the input line is debrittified, removing al abbreviations etc.
# - then common expressions are translated
# - then single words are translated, even the substrings
####################################

proc bMotion_module_extra_dutchify_single_word_replace { in out line } {
  regsub -nocase -all "\[\[:<:\]\]$in\[\[:>:\]\]" $line $out line
  return $line
}

proc bMotion_module_extra_dutchify_single_word_replace_list { {inout} line } {
  foreach {in out} $inout {
	set line [bMotion_module_extra_dutchify_single_word_replace $in $out $line]
  }
  return $line
}

proc bMotion_module_extra_dutchify_makeDutch_multiWord { line } {
  # this is mainly to replace multiple words before grammar is used
  # also, this function isn't called from grammar, so it's less expensive
  set line [string map -nocase {"french kiss" "tongzoen"} $line]

  set line [bMotion_module_extra_dutchify_single_word_replace_list {
	"(is|am) called" "heet"  "reserved sign" "gereserveerd bordje"  "to be" zijn
	{a(n)?} {een}  "you are" "jij bent"  "are you" "ben je"
  } $line]	

  return $line
}

proc bMotion_module_extra_dutchify_makeDutch { line } {
  # these are mainly one-word replacements
  set line [string map -nocase { cow koe } $line]

  #regsub -nocase -all {[[:<:]]a(n)?[[:>:]]} $line {een} line

  # then the more simple ones
  set line [bMotion_module_extra_dutchify_single_word_replace_list {
	it het  am ben  are zijn  i ik no nee  he hij  of van  or of
	the de  at in  on op  and en  has heeft  yes ja  how hoe  who wie  they zij
    do doe  air lucht  fuck neuk  miss mis  kiss kus  she zij  he hij
  } $line]

  set line [string map -nocase { question vraag chicken kip hello hoi line lijn my mijn have heb nice leuke name naam stolen gestolen want wil must moet hugs knuffelt hug knuffel yes ja thanks dank} $line ]
  set line [string map -nocase { small kleine wrong fout tea thee cosy muts morning morgen think denk that dat too ook also ook does doet middle midden therefore dus perhaps misschien maybe misschien tree BOOM$(* } $line]
  set line [string map -nocase { licking likken licks likt for voor fucks paalt fucking palen dictionary woordenboek dutch nederlands} $line]
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
  set line [string map -nocase { have heeft walk loop walks loopt sleep slaap sleeps slaapt breathe adem breathes ademt look kijk looks kijkt } $line]
  set line [string map -nocase { sit zit sits zit run ren runs rent } $line]

  set line [string map -nocase { sun zon moon maan star ster sky hemel  heaven hemel hell hel ground grond grass gras cloud wolk } $line]
  set line [string map -nocase { bird vogel lion leeuw tiger tijger dog hond cat kat fish vis } $line]
  set line [string map -nocase { dictionary woordenboek word woord translation vertaling } $line]
  set line [string map -nocase { car auto bike fiets train trein {(air)?plane} {vliegtuig} truck vrachtwagen boat boot ship schip balloon ballon } $line]
  set line [string map -nocase { under onder behind achter before voor } $line]

  set line [string map -nocase { gives geeft throws gooit tickles kietelt } $line]

  #panique
  set line [string map -nocase { not niet talk praten book boek pencil potlood rubber condoom theacup theekopje boat boot } $line]

  set line [bMotion_module_extra_dutchify_single_word_replace to naar $line]

  return $line
}

proc bMotion_module_extra_dutchify_deBrittify {text} {
  regsub -all "'m\[\[:>:\]\]" $text { am} text
  regsub -all "'ve\[\[:>:\]\]" $text { have} text
  regsub -all "'re\[\[:>:\]\]" $text { are} text
  regsub -all "'ll\[\[:>:\]\]" $text { will} text
  regsub -all "n't\[\[:>:\]\]" $text { not} text

  # special case, we don't plural or possesive form (sp?) to be substituted
  # this will fail with 'has' instead of 'is'
  regsub -all -nocase "\[\[:<:\]\](\[s\]*he)'s\[\[:>:\]\]" $text {\1 is} text

  return $text
}

proc bMotion_module_extra_dutchify_grammar {line} {
  # some rules in this proc will call makeDutch for small parts of word
  set subword ""

  #...ed --> ge...[dt]
  while {[regexp {(\w{3,})ed[[:>:]]} $line discard subword]} {
    bMotion_putloglev 1 * "subword: $subword"
    set subword [bMotion_module_extra_dutchify_makeDutch $subword]
    if {[regexp {(t|k|f|s|ch|p)} [string index $subword end]]} {
	  if {[regexp {[^t]} [string index $subword end]]} {
        regsub -nocase {(\w+)ed[[:>:]]} $line "ge${subword}t" line
	  } else {
        regsub -nocase {(\w+)ed[[:>:]]} $line "ge${subword}" line
	  }
	} else {
      regsub -nocase {(\w+)ed[[:>:]]} $line "ge${subword}d" line
    }
  }

  #...ify -> ver...en
  regsub -nocase -all {[[:<:]](.+?)ify[[:>:]]} $line {ver\1en} line

  # this has something to do with the above translation, but I can't seem
  # to figure out what :) It has something to do with removing double vowels
  regsub -nocase -all {[[:<:]](ver)(.+?)([auiou])\3([^auiou])(en)[[:>:]]} $line {\1\2\3\4\5} line

  # ...ing -> ...end   this fails most of the time :)
  #regsub -nocase -all {[[:<:]]([a-z]{4,})ing[[:>:]]} $line {\1end} line

  return $line
}

proc bMotion_module_extra_dutchify {text} {

  regsub "!nl +(.+)" $text {\1} text

  set leetMode 0
  if [regexp -nocase -- "^-l(ee|33)t (.+)" $text blah bling line] {
    set leetMode 1
  } else {
    set line $text
  }

  set line [bMotion_module_extra_dutchify_deBrittify $line]
  set line [bMotion_module_extra_dutchify_makeDutch_multiWord $line]
  set line [bMotion_module_extra_dutchify_grammar $line]
  set line [bMotion_module_extra_dutchify_makeDutch $line]

  if {$leetMode == 1} {
    set line [makeLeet2 $line]
  }

  return $line
}
