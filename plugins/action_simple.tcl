# bMotion simple action plugins
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

#                         name  regexp            %   responses
#bMotion_plugin_add_action_simple "licks" "(licks|bites) %botnicks" 100 [list "%VAR{rarrs}"]
#TODO: Move this
bMotion_plugin_add_action_simple "moo" "^(goes |does a )?moo+s?( at %botnicks)?" 40 [list "%VAR{moos}"] "all"


# now autoload the rest from plugins/action_simple_*.tcl

set files [glob -nocomplain "$bMotionPlugins/action_simple_*.tcl"]
foreach f $files {
	set count [llength [array names bMotion_plugins_action_simple]]
  bMotion_putloglev 1 * "bMotion: loading simple action plugin file $f"
  catch {
    source $f
  } err
	set newcount [llength [array names bMotion_plugins_action_simple]]
	if {($bMotion_testing == 0) && ($newcount == $count)} {
		putlog "bMotion: ALERT! simple action plugin file $f added no plugins"
		putlog "Possible error: $err"
	}
}
