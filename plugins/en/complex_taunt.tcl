#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "taunt" "^!taunt" 100 bMotion_plugin_complex_taunt "en"

proc bMotion_plugin_complex_taunt {nick host handle channel text} {
  global randomTauntPrefixes randomTauntSuffixes botnick

  if {![bMotion_interbot_me_next $channel]} {
  	return 1
  }

  set prefix ""
  regsub -nocase "!taunt " $text "" text

  if [regexp -nocase $botnick $text] {
    set text $nick
  }

  if [regexp "(.+)" $text] {
    #check for plural
    if {[string index $text end] == "s"} {
      set plural "s"
    } else {
      set plural ""
    }

    if {$plural != ""} {
      set prefix "$text: You are"
    } else {
      set prefix "$text: You are a"
    }
  }

  bMotionDoAction $channel "" "$prefix %VAR{randomTauntPrefixes} %VAR{randomTauntSuffixes}$plural"
  return 1

}

### and our abstracts...
bMotion_abstract_register "randomTauntPrefixes" {
  "idiot"
  "stupid"
  "minging"
  "incompetent"
  "foolish"
  "silly"
  "prancing"
  "dancing"
  "buffoonesque"
  "horizontally-enhanced"
  "special"
  "Welsh"
  "Northern"
  "Southern"
  "fishguts"
  "imbecile"
  "credulous"
  "cretinous"
  "naughty"
  "disreputable"
  "absurd"
  "capricious"
  "lemon-flavoured"
}

bMotion_abstract_register "randomTauntSuffixes" {
  "fool"
  "idiot"
  "buffoon"
  "mingbeast"
  "incompetent"
  "loser"
  "monstar"
  "foo'"
  "woolhead"
  "kenneth"
  "taunt"
  "individual"
  "failure"
  "imbecile"
  "cretin"
  "chap"
  "waste of space"
  "joker"
  "drone"
  "sailor"
  "moron"
}
