## bMotion plugins loader: simple
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

set currentlang $bMotionInfo(language)
set languages [split $bMotionSettings(languages) ","]
foreach bMotion_language $languages {
  set bMotionInfo(language) $bMotion_language
  bMotion_putloglev 2 * "bMotion: loading simple plugins language = $bMotion_language"
  set files [glob -nocomplain "$bMotionPlugins/$bMotion_language/simple_*.tcl"]
  foreach f $files {
		set count [llength [array names bMotion_plugins_simple]]
    bMotion_putloglev 1 * "bMotion: loading ($bMotion_language) simple plugin file $f"
		set bMotion_noplugins 0
    catch {
      source $f
    } err
		set newcount [llength [array names bMotion_plugins_simple]]
		if {($bMotion_testing == 0) && ($newcount == $count) && ($bMotion_noplugins == 0)} {
			putlog "bMotion: ALERT! Loading plugins file $f did not add any plugins!"
			putlog "Possible error: $err"
		}
  }
}
set bMotionInfo(language) $currentlang
unset currentlang
