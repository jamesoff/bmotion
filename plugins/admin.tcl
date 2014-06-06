## bMotion plugins loader: admin
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
	bMotion_log "plugins" "INFO" "loading admin plugins language = $bMotion_language"
	set files [glob -nocomplain "$bMotionPlugins/$bMotion_language/admin_*.tcl"]
	foreach f $files {
		set count [llength [array names bMotion_plugins_admin]]
		bMotion_log "plugins" "DEBUG" "loading ($bMotion_language) admin plugin file $f"
		catch {
			source $f
		} err
		set newcount [llength [array names bMotion_plugins_admin]]
		if {($bMotion_testing == 0) && ($newcount == $count)} {
			bMotion_log "plugins" "ERROR" "ALERT! admin plugin file $f added no plugins"
			bMotion_log "plugins" "DEBUG" "Possible error: $err"
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
