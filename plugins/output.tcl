## bMotion plugins loader: output
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

set languages [split $bMotionSettings(languages) ","]
foreach bMotion_language $languages {
  bMotion_putloglev 2 * "bMotion: loading output plugins language = $bMotion_language"
  set files [glob -nocomplain "$bMotionPlugins/$bMotion_language/output_*.tcl"]
  foreach f $files {
		set count [llength [array names bMotion_plugins_output]]
    bMotion_putloglev 1 * "bMotion: loading ($bMotion_language) output plugin file $f"
		set bMotion_noplugins 0
    catch {
      source $f
    } err
		set newcount [llength [array names bMotion_plugins_output]]
		if {($bMotion_testing == 0) && ($newcount == $count) && ($bMotion_noplugins == 0)} {
			putlog "bMotion: ALERT! output plugin file $f added no plugins"
			putlog "Possible error: $err"
		}
  }
}
