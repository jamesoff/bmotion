## bMotion plugins loader: nick
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
foreach language $languages {
  bMotion_putloglev 2 * "bMotion: loading irc event plugins language = $language"
  set files [glob -nocomplain "$bMotionPlugins/$language/irc_*.tcl"]
  foreach f $files {
    bMotion_putloglev 1 * "bMotion: loading ($language) irc event plugin file $f"
    catch {
      source $f
    }
  }
}
