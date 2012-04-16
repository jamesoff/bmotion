# bMotion - Global variable init
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2008
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

# Defaults

# Mood stuff is in mood.tcl

if {![info exists got]} {
  set got(tissues,nick) ""
  set got(tissues,channel) ""
  set got(coffee,nick) ""
  set got(coffee,channel) ""
  set got(bodyPaint,nick) ""
  set got(bodyPaint,channel) ""
  set got(dildo,nick) ""
  set got(dildo,count) 0
  set got(dildo,style) ""
}

if {![info exists bMotionInfo]} {
  set bMotionInfo(pokemon) "pikachu"
  set bMotionInfo(cloaked) 0
  set bMotionInfo(warp) 0
  set bMotionInfo(impulse) 0
  set bMotionInfo(brig) ""
  set bMotionInfo(leet) 0
  set bMotionInfo(dutch) 0
  set bMotionInfo(leetChance) 3
  set bMotionInfo(silence) 0
  set bMotionInfo(away) 0
  set bMotionInfo(clothing) 5
}

set bMotionCache(away) ""
set bMotionCache(lastGreeted) ""
set bMotionCache(lastHows) ""
set bMotionCache(lastDoneFor) ""
set bMotionCache(teamRocket) ""
set bMotionCache(lastLeft) ""
set bMotionCache(opme) ""
set bMotionCache(typos) 0
set bMotionCache(typoFix) ""
set bMotionCache(remoteBot) ""
set bMotionCache(randomUser) ""

set bMotion_typos [list]
set bMotion_typo_mutex ""

bMotion_plugins_settings_set "system" "lastPlugin" "" "" ""
bMotion_plugins_settings_set "system" "last_simple" "" "" ""

#this is set later
set botnicks ""

set arrcachearr ""
set arrcachenick ""
set colenMings [expr srand([clock clicks])]

set bMotionAdminFlag "n"

#typing queue
set bMotionQueue [list]
set bMotionQueueTimer 0

set bMotionThisText ""

#0 for off
set bMotionGlobal 1

set bMotionPluginHistory [list]

set bMotionChannels [list]

# 0 -> 1 -> 2 -> 0
set BMOTION_SLEEP(AWAKE) 0
set BMOTION_SLEEP(BEDTIME) 1
set BMOTION_SLEEP(ASLEEP) 2
set BMOTION_SLEEP(OVERSLEEPING) 3

# start off awake
set bMotionSettings(asleep) $BMOTION_SLEEP(AWAKE)
set bMotionTiredness 0

set bMotionDebug [list]

