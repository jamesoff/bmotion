# bMotion - Internal counters
#
# $Id$
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2003
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

if {![info exists bMotion_counters]} {
  set bMotion_counters(dummy,dummy) 0
}

proc bMotion_counter_init { section name } {
  global bMotion_counters

  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  if [info exists bMotion_counters($section,$name)] {
    bMotion_putloglev d * "not reiniting counter for $section $name"
    return 0
  }

  bMotion_putloglev d * "initing counter for $section $name"
  set bMotion_counters($section,$name) 0
}

proc bMotion_counter_incr { section name { amount 1 } } {
  global bMotion_counters

  bMotion_putloglev 1 * "incring counter $section $name by $amount"
  
  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  incr bMotion_counters($section,$name) $amount
}

proc bMotion_counter_get { section name } {
  global bMotion_counters
  
  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  return $bMotion_counters($section,$name)
}

proc bMotion_counter_set { section name amount } {
  global bMotion_counters

  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  set bMotion_counters($section,$name) $amount
}
