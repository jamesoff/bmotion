# bMotion - Settings file
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2002
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

set bMotionInfo(gender) "male"
set bMotionInfo(balefire) 1
set bMotionInfo(randomChannels) { "#molsoft" "#ags" "#exeter" "#namcoarcade" "#startrek" }
#set bMotionInfo(randomChannels) { "#molsoft" }
set bMotionInfo(orientation) "straight"
#set bMotionInfo(orientation) "bi"
set bMotionSettings(needI) 1
set bMotionSettings(melMode) 0
set bMotionSettings(botnicks) "nt|bots|the bots"
set bMotionSettings(typos) 7
set bMotionSettings(colloq) 10
set bMotionSettings(noPlugin) "simple:huk,complex:wb"
#minutes
set bMotionInfo(minRandomDelay) 20
set bMotionInfo(maxRandomDelay) 120

# if nothing's happened on this channel for this much time, don't say something
set bMotionInfo(maxIdleGap) 45
set bMotionInfo(brigDelay) 30

set bMotionSettings(leetRandom) 0.5

set bMotionSettings(languages) "en,nl"
set bMotionInfo(language) "en"

