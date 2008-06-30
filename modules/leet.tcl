# bMotion - Leet-izer
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

#load alphaset transforms
source "$bMotionModules/leet_settings.tcl"

# Binds
bind pub - "!leet" bMotionLeetChannel
bind msg - leet leetPrivate

proc bMotionLeetChannel {nick host handle channel text} {
  global botnick bMotionInfo
  if {$bMotionInfo(balefire) != 1} {
    return 0
  }
  puthelp "PRIVMSG [chandname2name $channel] :[makeLeet2 $text]"
}

proc makeLeet { line } {
  return "Warning! Call to old makeLeet."
}

proc makeLeet2 {line} {
  global leet bMotionInfo
  if [rand 2] { regsub -nocase -all {(\d+)} $line "1337" line }
  #if [rand 2] { regsub -nocase -all "hackers" $line "hax0rz" line }
  if [rand 2] { regsub -nocase -all "cool" $line "kewl" line }
  if [rand 2] { regsub -nocase -all "dudes" $line "d00dz" line }
  if [rand 2] { regsub -nocase -all "dude" $line "d00d" line }
  #if [rand 2] { regsub -nocase -all "er" $line "hax0r" line }
  #if [rand 2] { regsub -nocase -all "ed" $line "hax0red" line }
  #if [rand 2] { regsub -nocase -all "owned" $line "own0red" line }
  #if [rand 2] { regsub -nocase -all "rocks" $line "rox0rs" line }
  #if [rand 2] { regsub -nocase -all "rock" $line "r0x0r" line }
  if [rand 2] { regsub -nocase -all "boxes" $line "b0xen" line }
  if [rand 2] { regsub -nocase -all "porn" $line "pr0n" line }
  if [rand 2] { regsub -nocase -all "elite" $line "l33t" line }
  if [rand 2] { regsub -nocase -all "your" $line "j00r" line }
  if [rand 2] { regsub -nocase -all "fear" $line "ph33r" line }
  if [rand 2] { regsub -nocase -all "wins" $line "win0rs" line }
  if [rand 2] { regsub -nocase -all "you" $line "j00" line }
  if [rand 2] { regsub -nocase -all "money" $line "monies" line }
  if [rand 2] { regsub -nocase -all "like" $line "liek" line }
  if [rand 2] { regsub -nocase -all "hacking" $line "hax0ring" line }
  if [rand 2] { regsub -nocase -all "skills" $line "skillz" line }

  #...cked -> x0r3d
  if [rand 2] { regsub -nocase -all {\m(\w+?)?cked\M} $line {\1x0r3d} line }

  #...cker(s) -> x0r(s)
  if [rand 2] { regsub -nocase -all {\m(\w+?)?cker(s|z)?\M} $line {\1x0r\2} line }

  #[constonant]ed -> 0r3d
  if [rand 2] { regsub -nocase -all {***:(\w+[^aeiouy])ed\M} $line {\10r3d} line }

  #...s --> ...z
  if [rand 2] { regsub -nocase -all {(\w+)s\M} $line {\1z} line }

  #f... -> oph...
  if [rand 2] { regsub -nocase -all {\mf+(\w+)} $line {ph\1} line }

  #...f -> ...oph
  if [rand 2] { regsub -nocase -all {(\w+?)f+\M} $line {\1ph} line }
  if [rand 2] { set line [string map -nocase { ROFL roflmaolozz!!111 loser lossarzz!! hehe HUHEHUHEHEHUEHUEH ike iek ter tar ife ief hah hehue ule lue ota oat ver var is si ome oem ame aem oe eo aid iad ers ars erz arz per par nic nix aye aey ade aed ite eit} $line ] }
  if [rand 2] { set line [string map -nocase { he eh re er ea ae hi ih or ro ip pi ho oh in ni lol lo!lololololzz! ! !!!111111 ir ri ou uo ha ah ui iu ig gi } $line ] }
  set letters [split [string tolower $line] {}]
  set line ""

  set alphabet [split "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" {}]

  foreach letter $letters {
    set newChar $letter
    if {[rand 10] > $bMotionInfo(leetChance)} {
      if {[regexp -nocase {[A-Za-z]} $letter]} {
        set newChar [pickRandom $leet($letter)]
      }
    }

    if [rand 2] {
      set newChar [string toupper $newChar]
    } else {
      set newChar [string tolower $newChar]
    }
    set line "$line$newChar"
  }

  return $line
}

#end of makeleet2

proc leetPrivate {nick host handle arg} {
  #set handle [finduser $host]
  if {$handle == "*"} {
    return 0
  }
  if [regexp {(\[#!\]\w+) (.+)} $arg ming channel param] {
    set val [makeLeet2 $param]
    putlog "bMotion: $nick asked !$param! to be leeted to !$channel!"
    if {![botonchan $channel]} {
      puthelp "PRIVMSG $nick :Sorry, I'm not on $channel"
      return 0
    }
    if {![onchan $nick $channel]} {
      set name [bMotionTransformNick $nick $nick $host]
      puthelp "PRIVMSG $nick :I'm sorry $name, I can't do that."
      putlog "bMotion: ALERT! $nick failed query leet to $channel ($param)."
      return 0
    }
    puthelp "PRIVMSG [chandname2name $channel] :\[\002$nick\002\] $val"
    return 0
  }

  putlog "bMotion: $nick asked !$arg! to be leeted"
  puthelp "PRIVMSG $nick :[makeLeet2 $arg]"
  return 0
}
