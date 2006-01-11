## bMotion plugins loader: complex action
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
foreach language $languages {
  set bMotionInfo(language) $language
  bMotion_putloglev 2 * "bMotion: loading complex action plugins language = $language"
  set files [glob -nocomplain "$bMotionPlugins/$language/action_complex_*.tcl"]
  foreach f $files {
		set count [llength [array names bMotion_plugins_action_complex]]
    bMotion_putloglev 1 * "bMotion: loading ($language) complex action plugin file $f"
    catch {
      source $f
    } err
		set newcount [llength [array names bMotion_plugins_action_complex]]
		if {($bMotion_testing == 0) && ($newcount == $count)} {
			putlog "bMotion: ALERT! complex action plugin file $f added no plugins"
			putlog "Possible error: $err"
		}
  }
}
set bMotionInfo(language) $currentlang
unset currentlang
