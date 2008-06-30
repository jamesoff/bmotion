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

bMotion_plugin_add_complex "st-readings" "%botnicks:?,? (enable|activate) (.+) (detectors?|sensors?)!?$" 100 bMotion_plugin_complex_readings "en"

proc bMotion_plugin_complex_readings { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "${botnicks}:?,? (enable|activate) (.+) (detectors?|sensors?)!?$" $text ming bhar moo reading] {
    set readingLevel [rand 101]
    bMotionDoAction $channel $channel "%VAR{readings_scan}"
    set reading "[string toupper [string range $reading 0 0]][string range $reading 1 end]"
    bMotion_plugins_settings_set "complex:readings" "reading" "reading" "" $reading
    bMotionDoAction $channel $nick "%VAR{readings_result}"
    bMotionGetUnLonely
    return 1
  }
}

bMotion_abstract_register "readings_scan"
bMotion_abstract_batchadd "readings_scan" {
  "/scans %%"
  "/analyses %%"
  "/checks %%"
  "/waves tricorder around a bit"
  "/looks at %ruser"
}

bMotion_abstract_register "readings_result"
bMotion_abstract_batchadd "readings_result" {
  "%%: That reads as %NUMBER{10000} %VAR{units}."
  "%SETTING{complex:readings:reading:reading:_} levels of %NUMBER{101} percent detected."
}
