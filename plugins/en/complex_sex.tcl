## sex plugin for bMotion
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

bMotion_plugin_add_complex "sex-oral" "^%botnicks go down on " 100 "bMotion_plugin_complex_sex_go_down_on" "en"
bMotion_plugin_add_complex "sex-oral2" "^%botnicks eat (.+) out" 100 "bMotion_plugin_complex_sex_go_down_on_2" "en"

proc bMotion_plugin_complex_sex_go_down_on { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "${botnicks}:?,? (please)?go down on (.+)" $text ming ming1 ming2 details] {    
    bMotionGoDownOn $channel $details $nick    
    return 1
  }
}

proc bMotion_plugin_complex_sex_go_down_on_2 { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^${botnicks},?:? (please)?eat (.+) out" $text ming ming1 ming2 who] {
    bMotionGoDownOn $channel $who $nick
    return 1
  }
}

## supporting functions

proc bMotionGoDownOn {channel nick forNick} {
    global mood goDowns botnick bMotionCache
    regsub {^([^ ]+)( .+)?} $nick {\1} nick
    bMotion_putloglev d * "bMotion: Was asked to go down on '$nick' in $channel by $forNick"
    if {[regexp -nocase "(himself|herself|your?self)" $nick] || [isbotnick $nick]} { 
      bMotionDoAction $channel "" "No. (ERR_EXCESS_RIBS)"
      return 0
    }
    if [string match -nocase "me" $nick] { set nick $forNick }

    set host [getchanhost $nick]
    if {$host == ""} {
      putserv "NOTICE $forNick :Sorry, I can't find $nick to go down on for you."
      return 0
    }
    if {![bMotionLike $nick $host]} {
      bMotionDoAction $channel $nick "No, they're not my type."
      return 0
    }
    bMotion_putloglev d * "bMotion: Went down on $nick for $forNick"
    bMotionDoAction $channel $nick [pickRandom $goDowns]
    #TODO:
    #if [matchattr [nick2hand $nick $host] b|K $channel] {
    #  bMotionDoAction $channel "" "%PICKBOT[name=$nick]%|%BOT[¬VAR{rarrs}]"
    #}
    incr mood(horny) 1
    incr mood(happy) 1
    incr mood(lonely) -1
    set bMotionCache(lastDoneFor) "$nick $forNick"
    return 0
}