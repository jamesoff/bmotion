## bMotion plugins loader: admin
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
  bMotion_putloglev 2 * "bMotion: loading admin plugins language = $language"
  set files [glob -nocomplain "$bMotionPlugins/$language/admin_*.tcl"]
  foreach f $files {
		set count [llength [array names bMotion_plugins_admin]]
    bMotion_putloglev 1 * "bMotion: loading ($language) admin plugin file $f"
    catch {
      source $f
    } err
		set newcount [llength [array names bMotion_plugins_admin]]
		if {($bMotion_testing == 0) && ($newcount == $count)} {
			putlog "bMotion: ALERT! admin plugin file $f added no plugins"
			putlog "Possible error: $err"
		}
  }
}
set bMotionInfo(language) $currentlang
unset currentlang

# load default admin stuff regardless
set files [glob -nocomplain "$bMotionPlugins/admin_*.tcl"]
foreach f $files {
  bMotion_putloglev 1 * "bMotion: loading (generic) admin plugin file $f"
  catch {
    source $f
  }
}
