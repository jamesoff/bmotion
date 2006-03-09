## bMotion output plugin: typos (qwerty :)
#
# $Id$
#
# vim: fdm=indent fdn=1
#
# random characters from roz:
#   ngfdngfd,jyr,iyrmyrwgrtewf436546lik,cmhtzmyt35znt43hmtgfnxgrw3\njt5,iut,vvjjhhhhhhhhhhhhhhhhn.

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


#note: if you write your own typos plugin that does this sort of thing, call it "typos"
#      too because loading two plugins to simulate typing errors is meaningless (mostly)

proc bMotion_plugin_output_typos_do { line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_typos_do $line"
	global bMotionSettings

  set typochance $bMotionSettings(typos)

  if {[rand 100] <= $typochance} {
    set line [string map -nocase { is si ome oem ame aem oe eo } $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 100] <= $typochance} {
    set line [string map -nocase { aid iad ers ars ade aed ite eit } $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 100] <= $typochance} {
    set line [string map -nocase { hi ih or ro ip pi ho oh } $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 100] <= $typochance} {
    set line [string map -nocase { he eh re er in ni lv vl sec sex } $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 100] <= $typochance} {
    set line [string map -nocase { ir ri ou uo ha ah ui iu ig gi nd dn} $line ]
    set typochance [expr $typochance * 0.6]
  }

#  if {[rand 1000] <= $typochance} {
#    set line [string map -nocase { " t" "t " } $line ]
#    set typochance [expr $typochance * 0.6]
#  }

  #go though the line one char at a time
  set chars [split $line {}]
  set newLine ""
  set typochance [expr $bMotionSettings(typos) / 2]

  foreach char $chars {
    if [string match -nocase "l" $char] {
      if {[rand 100] < $typochance} {
        append newLine ";l"
        bMotion_plugin_output_typos_adderror "" "-;"
      }
    }

    if [string match -nocase "a" $char] {
      if {[rand 100] < $typochance} {
        append newLine "sa"
        bMotion_plugin_output_typos_adderror "" "-s"
      }
    }
    if [string match -nocase "s" $char] {
      if {[rand 100] < $typochance} {
        append newLine "sd"
        bMotion_plugin_output_typos_adderror "" "-d"
      }
    }
    if [string match -nocase "e" $char] {
      if {[rand 100] < $typochance} {
        append newLine "re"
        bMotion_plugin_output_typos_adderror "" "-r"
      }
    }
    if [string match -nocase "d" $char] {
      if {[rand 100] < $typochance} {
        append newLine "df"
        bMotion_plugin_output_typos_adderror "" "-f"
      }
    }
    if [string match -nocase "z" $char] {
      if {[rand 100] < $typochance} {
        append newLine "zx"
        bMotion_plugin_output_typos_adderror "" "-x"
      }
    }
    if [string match -nocase "z" $char] {
      if {[rand 100] < $typochance} {
        append newLine "z\\"
        bMotion_plugin_output_typos_adderror "" "-\\"
      }
    }
    if [string match -nocase " " $char] {
      if {[rand 100] < $typochance} {
        bMotion_plugin_output_typos_adderror "" "+space"
      }
    }
    if [string match -nocase ")" $char] {
      if {[rand 100] < $typochance} {
        append newLine ")_"
        bMotion_plugin_output_typos_adderror "" "-_"
      }
    }
    #else...
    append newLine $char
  }
	bMotion_putloglev 4 * "returning $newLine"
  return $newLine
}

## Make Typos
#    Attempt to make typos similar to human typing errors
#
proc bMotion_plugin_output_typos { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_typos $channel $line"
  global bMotionSettings 

  set typochance $bMotionSettings(typos)
	bMotion_putloglev 4 * "Typo chance is: $typochance%"
  set oldLine $line

  #reset typos
  bMotion_plugins_settings_set "output:typos" "typos" "" "" ""
  bMotion_plugins_settings_set "output:typos" "typosDone" "" "" ""

  set newLine ""
	
  #split words
	set line [string trim $line]
  set words [split $line " "]

  #typo words
	bMotion_putloglev 4 * "words list is: $words"
	putlog "words is [llength $words] long"
  foreach word $words {
		bMotion_putloglev 4 * "typo_do'ing $word"
    append newLine [bMotion_plugin_output_typos_do $word]
		append newLine " "
  }

  set line [string trim $newLine]

  if {[rand 100] < $typochance} {
    set tmpchar [pickRandom {"#" "]"}]
    append line $tmpchar
    bMotion_plugin_output_typos_adderror "" "-$tmpchar"
		bMotion_putloglev 1 * "typoing a character onto the end of the line"
  }

  if {[rand 100] < $typochance} {
    set line [string toupper $line]
    bMotion_plugin_output_typos_adderror "" "-caps"
		bMotion_putloglev 1 * "typoing in all caps"
  }

  if {[string trim $oldLine] != [string trim $line]} {
    bMotion_plugins_settings_set "output:typos" "typosDone" "" "" "yes"
  }

  return $line
}

proc bMotion_plugin_output_typos_adderror { channel err } {
  set currentErr [bMotion_plugins_settings_get "output:typos" "typos" "" ""]
  if {$currentErr == ""} {
    set currentErr $err
  } else {
    append currentErr " $err"
  }
  bMotion_plugins_settings_set "output:typos" "typos" "" "" $currentErr
}

bMotion_plugin_add_output "typos" bMotion_plugin_output_typos 1 "all"
