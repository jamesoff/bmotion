# bMotion - event supporting functions
#
# $Id$
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

proc finishdildo {} {
	global got mood 

	set style $got(dildo,style)

	if {$style == "flute"} {
		cum $got(dildo,channel) $got(dildo,nick)
		bMotionDoAction $got(dildo,channel) $got(dildo,nick) "%VAR{dildoFluteFinishes}"

		set got(dildo,nick) ""
		set got(dildo,count) 0
		incr mood(happy) 1
		incr mood(horny) -2
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
	incr mood(happy) 1
	incr mood(horny) -2
}


proc cum {channel nick} {
	global bMotionInfo
	global mood
	if {![pastWatershedCheck $nick]} { return 0 }
	if {![bMotionIsFriend $nick]} {
		bMotionDoAction $channel $nick "%VAR{blehs} I can't cum thinking about someone I don't like"
		return 0
	}
	if {$bMotionInfo(gender) == "male"} {
		bMotionDoAction $channel $nick "/ejaculates over %%"
		incr mood(horny) -3
		incr mood(happy) 2
		return 0
	}
	bMotionDoAction $channel $nick "/makes herself cum thinking about %%"
	incr mood(horny) -3
	incr mood(happy) 2
	return 0
}


proc frightened {nick channel} {
	global mood
	bMotionDoAction $channel $nick "%VAR{frightens} %VAR{unsmiles}"
	incr mood(lonely) -1
	incr mood(happy) -1
}


proc checkPokemon {which channel} {
	global bMotionInfo
	if {$bMotionInfo(pokemon) != [string tolower $which]} {
		bMotionDoAction $channel $which "/morphs into %%!"
		set bMotionInfo(pokemon) [string tolower $which]
	}
}


bMotion_putloglev d * "bMotion: event support module loaded"
