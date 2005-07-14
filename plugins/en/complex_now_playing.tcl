## bMotion plugin: nipples
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

bMotion_plugin_add_complex "now_playing" "(listening to|now playing|NP)\:" 60 bMotion_plugin_complex_now_playing "en"

proc bMotion_plugin_complex_now_playing { nick host handle channel text } {

  if [bMotionLike $nick $host] {
    bMotionDoAction $channel $nick "%VAR{nowPlaying}"
  } else {
    bMotionDoAction $channel $nick "%VAR{nowPlayingDislike}"
  }
  return 1
}
