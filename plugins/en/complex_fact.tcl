## bMotion plugin: bhar (etc)
#
# $Id$
#
# vim: fdm=indent fdn=1


###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_complex "fact" {\m(is|was|=|am)\M} 100 bMotion_plugin_complex_fact "en"


proc bMotion_plugin_complex_fact { nick host handle channel text } {
  global bMotionFacts bMotionFactTimestamps

  set ignoretext [bMotion_setting_get "ignorefacts"]
  if {$ignoretext != ""} {
    if [regexp -nocase $ignoretext $text] {
      return 0
    }
  }

#don't let trivia trigger us
	if [string match "*answer was*" $text] {
		return 0
	}
  
  if {[string range $text end end] == "?"} { return 0 }
  if [regexp -nocase {\m([^ !"]+)[!" ]+(is|was|==?|am) ?([a-z0-9 '_/-]+)} $text matches item blah fact] {
    set item [string tolower $item]
    if {([string length $fact] < 3) || ([string length $fact] > 30)} { return 0 }
    if [regexp "(what|which|have|it|that|when|where|there|then|this|who|you|you|yours|why|he|she)" $item] {
      return 0
    }
    if {$item == "i"} {
      set item [string tolower $nick]
    }
    regsub {\mme\M} $fact $nick fact
    set fact [string tolower [string trim $fact]]
    regsub {\mmy\M} $fact "%OWNER{$nick}" fact
    bMotion_putloglev d * "fact: $item == $fact"
    lappend bMotionFacts(what,$item) $fact
    set bMotionFactTimestamps(what,$item) [clock seconds]
  }
	#return 0 because we don't put anything to irc, so we shouldn't get in the way
  return 0
}

