## bMotion output plugin: typos (qwerty :)
#
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


#note: if you write your own typos plugin that does this sort of thing, call it "typos" 
#      too because loading two plugins to simulate typing errors is meaningless (mostly)

## Make Typos
#    Attempt to make typos similar to human typing errors
#
proc bMotion_plugin_output_typos { channel line } {
  global bMotionSettings bMotionCache

  set typochance $bMotionSettings(typos)
  set oldLine $line

  #reset typos
  bMotion_plugins_settings_set "output:typos" "typos" "" "" ""
  bMotion_plugins_settings_set "output:typos" "typosDone" "" "" ""

  if {[rand 1000] <= $typochance} { 
    set line [string map -nocase { is si ome oem ame aem oe eo } $line ]
    set typochance [expr $typochance * 0.6] 
  }

  if {[rand 1000] <= $typochance} { 
    set line [string map -nocase { aid iad ers ars ade aed ite eit } $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 1000] <= $typochance} { 
    set line [string map -nocase { hi ih or ro ip pi ho oh "ine " "ing " } $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 1000] <= $typochance} { 
    set line [string map -nocase { he eh re er in ni lv vl sec sex } $line ] 
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 1000] <= $typochance} { 
    set line [string map -nocase { ir ri ou uo ha ah ui iu ig gi nd dn} $line ]
    set typochance [expr $typochance * 0.6]
  }

  if {[rand 1000] <= $typochance} { 
    set line [string map -nocase { " t" "t " } $line ]
    set typochance [expr $typochance * 0.6]
  }

  #go though the line one char at a time
  set chars [split $line {}]
  set newLine ""
  set typochance [expr $bMotionSettings(typos) / 2]
  foreach char $chars {
    if [string match -nocase "a" $char] { 
      if {[rand 1000] < $typochance} { 
        append newLine "sa"
        bMotion_plugin_output_typos_adderror "" "-s"
        continue 
      }
    }
    if [string match -nocase "s" $char] { 
      if {[rand 1000] < $typochance} { 
        append newLine "sd"
        bMotion_plugin_output_typos_adderror "" "-d"
        continue
      }
    }
    if [string match -nocase "e" $char] { 
      if {[rand 1000] < $typochance} { 
        append newLine "re"
        bMotion_plugin_output_typos_adderror "" "-r"
        continue
      }
    }
    if [string match -nocase "d" $char] { 
      if {[rand 1000] < $typochance} { 
        append newLine "df"
        bMotion_plugin_output_typos_adderror "" "-f"
        continue
      }
    }
    if [string match -nocase "z" $char] { 
      if {[rand 1000] < $typochance} { 
        append newLine "zx"
        bMotion_plugin_output_typos_adderror "" "-x"
        continue
      }
    }
    if [string match -nocase "z" $char] { 
      if {[rand 1000] < $typochance} {
        append newLine "z\\"
        bMotion_plugin_output_typos_adderror "" "-\\"
        continue
      }
    }
    if [string match -nocase " " $char] { 
      if {[rand 1000] < $typochance} { 
        bMotion_plugin_output_typos_adderror "" "+space"
        continue
      }
    }
    if [string match -nocase ")" $char] { 
      if {[rand 1000] < $typochance} { 
        append newLine ")_"
        bMotion_plugin_output_typos_adderror "" "-_"
        continue
      }
    }
    #else...
    append newLine $char
  }
  set line $newLine
  
  if {[rand 1000] < $typochance} { 
    set tmpchar [pickRandom {"#" "]"}]
    append line $tmpchar
    bMotion_plugin_output_typos_adderror "" "-$tmpchar"
  }

  if {[rand 1000] < $typochance} { 
    set line [string toupper $line]
    bMotion_plugin_output_typos_adderror "" "-caps"
  }

  if {$oldLine != $line} {
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