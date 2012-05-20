# bMotion - event supporting functions
#

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

proc finishdildo {} {
	global got 

	set style $got(dildo,style)

	if {$style == "flute"} {
		cum $got(dildo,channel) $got(dildo,nick)
		bMotionDoAction $got(dildo,channel) $got(dildo,nick) "%VAR{dildoFluteFinishes}"

		set got(dildo,nick) ""
		set got(dildo,count) 0
		bMotion_mood_adjust happy 1
		bMotion_mood_adjust horny -2
		return 0
	}

	if {$style == "f_swap"} {
		bMotionDoAction $got(dildo,channel) $got(dildo,dildo) "%VAR{dildoFemaleFemaleSwap}"

		set got(dildo,style) "normal"
		utimer 70 finishdildo
		return 0
	}

	if {$style == "m_swap"} {
		bMotionDoAction $got(dildo,channel) $got(dildo,dildo) "%VAR{dildoMaleMaleSwap}"

		set got(dildo,style) "normal"
		utimer 70 finishdildo
		return 0
	}

	cum $got(dildo,channel) $got(dildo,nick)
	bMotionDoAction $got(dildo,channel) $got(dildo,dildo) "%VAR{dildoFinishes}" $got(dildo,nick)
	set got(dildo,nick) ""
	set got(dildo,count) 0
	bMotion_mood_adjust happy 1
	bMotion_mood_adjust horny -2
}


proc cum {channel nick} {
	global bMotionInfo
	if {![bMotionIsFriend $nick]} {
		bMotionDoAction $channel $nick "%VAR{blehs} I can't cum thinking about someone I don't like"
		return 0
	}
	if {$bMotionInfo(gender) == "male"} {
		bMotionDoAction $channel $nick "/ejaculates over %%"
		bMotion_mood_adjust horny -3
		bMotion_mood_adjust happy 2
		return 0
	}
	bMotionDoAction $channel $nick "/makes herself cum thinking about %%"
	bMotion_mood_adjust horny -3
	bMotion_mood_adjust happy 2
	return 0
}


proc frightened {nick channel} {
	bMotionDoAction $channel $nick "%VAR{frightens} %VAR{unsmiles}"
	bMotion_mood_adjust lonely -1
	bMotion_mood_adjust happy -1
}


proc checkPokemon {which channel} {
	global bMotionInfo 
	if {$bMotionInfo(pokemon) != [string tolower $which]} {
		bMotionDoAction $channel $which "/morphs into %%!"
		set bMotionInfo(pokemon) [string tolower $which]
	}
}


bMotion_putloglev d * "bMotion: event support module loaded"
