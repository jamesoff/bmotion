# bMotion - friendship handler

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



proc getFriendship { nick } {

  if {![validuser $nick]} {

    set handle [nick2hand $nick]

    if {($handle == "*") || ($handle == "")} {

      bMotion_putloglev 1 * "bMotion: couldn't find a handle for $nick to get friendship."

      return 50

    }

  } else {

    set handle $nick

  }



  set friendship 50



  if {$handle != "*"} {

    set friendship [getuser $handle XTRA friend]

    if {$friendship == ""} {

      setFriendship $nick 50  

      set friendship 50

    }

  }

  return $friendship

}



proc getFriendshipHandle { handle } {

  set friendship 50



  set friendship [getuser $handle XTRA friend]

  if {$friendship == ""} {

    setFriendship $nick 50  

    set friendship 50

  }

  return $friendship

}



proc setFriendshipHandle { handle friendship } {

  if {$friendship > 100} {

    bMotion_putloglev 2 * "bMotion: friendship for $nick went over 100, capping back to 90"

    set friendship 90

  }



  if {$friendship < 1} {

    bMotion_putloglev 2 * "bMotion: friendship for $nick went under 1, capping back to 10"

    set friendship 10

  }



  setuser $handle XTRA friend $friendship

}





proc setFriendship { nick friendship } {

  bMotion_putloglev 4 * "setFriendship: nick = $nick, friendship = $friendship"

  set handle [nick2hand $nick]

  if {($handle == "*") || ($handle == "")} {

    bMotion_putloglev 1 * "bMotion: couldn't find a handle for $nick to set friendship."

    return 50

  }


  if {$friendship > 100} {

    bMotion_putloglev 2 * "bMotion: friendship for $nick went over 100, capping back to 9"

    set friendship 99

  }



  if {$friendship < 0} {

    bMotion_putloglev 2 * "bMotion: friendship for $nick went under 0, capping back to 1"

    set friendship 1

  }



 catch {
    setuser $handle XTRA friend $friendship

  }
}



proc driftFriendship { nick drift } {

  bMotion_putloglev 4 * "driftFriendship: nick = $nick, drift = $drift"
  set handle [nick2hand $nick]

  if {($handle == "*") || ($handle == "")} {

    bMotion_putloglev 1 * "bMotion: couldn't find a handle for $nick to drift friendship."

    return 50

  }



  set friendship [getFriendship $handle]

  incr friendship $drift

  setFriendship $nick $friendship

  bMotion_putloglev 2 * "bMotion: drifting friendship for $nick by $drift, now $friendship"

  return $friendship

}



proc getFriendsList { } {

  set users [userlist]

  set r ""

  set best(name) ""

  set best(val) 0

  set worst(name) ""

  set worst(val) 100

  foreach user $users {

    set f [getuser $user XTRA friend]

    if {$f != ""} {

      append r "$user:$f "

    }

    if {$f > $best(val)} {

      set best(val) $f

      set best(name) $user

    }

    if {($f < $worst(val)) && ($f > 0)} {

      set worst(val) $f

      set worst(name) $user

    }

  }

  set r "Best friend: $best(name), worst friend: $worst(name). $r"

  return $r

}



proc bMotionIsFriend { nick } {

  set friendship [getFriendship $nick]

  bMotion_putloglev 2 * "bMotion: friendship for $nick is $friendship"

  if {$friendship < 35} {

    return 0

  }

  return 1

}    



bMotion_putloglev d * "bMotion: friendship module loaded"

