## bMotion: complex action support plugin: dildo
#
# $Id$
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

#we need complex_action:hands
if {![bMotion_plugin_check_depends "action_complex:hands"} {
	return 0
}

#### DILDO (oh god :)
proc bMotion_complex_action_hands_dildo { channel nick item2 } {
  bMotion_putloglev 1 * "bMotion: ... ah ha, a dildo ($item2)"
  driftFriendship $nick 2
  global got
  set style "normal"

  set useTimer 0
  set style "normal"
  #female bot
  if {$bMotionInfo(gender) == "female"} {
    global got

    #already got two
    if {$got(dildo,count) >= 2} {
      bMotionDoAction $channel $nick "Blimey, I'm already using two, that's plenty enough."
      return 0
    }

    #not horny enough
    if {$mood(horny) < 3} {
      bMotion_putloglev 1 * "bMotion: but not horny enough (!), they'll have to do better (they'll never learn otherwise)"
      bMotionDoAction $channel $nick "I'm not in the mood for that. Haven't you heard of foreplay?"
      bMotionGetUnLonely
      return 0
    }

    #play with it 
    #TODO: Rationalise this!
    global dildoPlays
    if {$got(dildo,count) == 1} {
      set got(dildo,count) 2
      global secondDildoPlays
      bMotionDoAction $channel $item2 [pickRandom $secondDildoPlays]
      return 0
    }
    #> 1.) if a bloke hands a female bot a dildo the female bot will shaft
    #> herself with it. If that dildo happens to be a flute the female bot
    #> will go "and this one time at band camp..." and then shaft herself
    #> with it.

    if {[bMotionGetGender $nick $host] == "male"} {
      #-- hander is male          
      if [string match -nocase "*flute*" $item] {
        global dildoFlutePlays
        bMotionDoAction $channel $item [pickRandom $dildoFlutePlays] $nick
        set useTimer 1
        set style "flute"
      } else {
        bMotionDoAction $channel $nick [pickRandom $dildoPlays] $item
        set useTimer 1
      }
    } else {
      #-- hander is female
      #> 2.) if a woman hands a female bot (bi/lesbian) a dildo then the
      #> female bot will shaft the woman with it and herself in turn or
      #> something like that... Same flute stuff going on. If the bot is not
      #> bi or lesbos then it will just fuck itself with it
      if [regexp -nocase "(bi|lesbian)" $bMotionInfo(orientation)] {
        #gay female bot
        #do each in turn
        #first do the other person, then the timer'll handle us later
        global dildoFemaleFemale
        bMotionDoAction $channel $nick [pickRandom $dildoFemaleFemale] $item
        set useTimer 1
        set style "f_swap"
      } else {
        #straight bot
        bMotionDoAction $channel $item [pickRandom $dildoPlays] $nick
        set useTimer 1
      }
    }

    bMotion_putloglev 1 * "bMotion: dildo (female) timer starting"

    if {$useTimer == 1} {
      set got(dildo,count) 1
      set got(dildo,nick) $nick
      set got(dildo,channel) $channel
      set got(dildo,dildo) $item2
      set got(dildo,style) $style
      utimer 70 finishdildo
    }
    return 0

  } else {
    #male bot

    #already got one
    if {$got(dildo,count) == 1} {
      bMotionDoAction $channel $nick "Blimey, I'm already using one, that's enough."
      return 0
    }

    #not horny enough
    if {$mood(horny) < 3} {
      bMotion_putloglev 1 * "bMotion: but not horny enough (!), they'll have to do better (they'll never learn otherwise)"
      bMotionDoAction $channel $nick "I'm not in the mood for that. Haven't you heard of foreplay?"
      bMotionGetUnLonely
      return 0
    }

    if {[bMotionGetGender $nick $host] == "male"} {
      #--hander is male
      #> 3.) if a bloke hands a male bot a dildo and the bot is strait then it
      #> will discard it. If the bot is gay or bi then it will shaft the bloke
      #> with it and shaft itself with it.
      if {$bMotionInfo(orientation) == "straight"} {
        #straight bot
        global thanks
        bMotionDoAction $channel $nick "\"[pickRandom $thanks]\""
        bMotionGetUnLonely
        bMotionDoAction $channel $nick "/discards the $item"
        return 0
      } else {
        global dildoMaleMale
        bMotionDoAction $channel $nick [pickRandom $dildoMaleMale] $item            
        #take turns
        set useTimer 1
        set style "m_swap"
      }
    } else {
      #-- hander is female
      #> 4.) if a woman hands a male bot a dildo and the bot is strait or bi
      #> it will shaft the woman with it. If the bot is gay it will shaft
      #> itself.
      if {[regexp -nocase "(straight|bi)" $bMotionInfo(orientation)]} {
        #do the hander
        global dildoMaleFemale
        bMotionDoAction $channel $nick [pickRandom $dildoMaleFemale] $item
        return 0
      } else {
        #gay bot
        #do ourselves
        global dildoMaleMale
        bMotionDoAction $channel $nick [pickRandom $dildoMalePlays] $item
        set useTimer 1
        set style "normal"
      }          
    } 
    #male bot, female hander
    bMotion_putloglev 1 * "bMotion: dildo (male) timer starting"
    if {$useTimer == 1} {
      set got(dildo,count) 1
      set got(dildo,nick) $nick
      set got(dildo,channel) $channel
      set got(dildo,dildo) $item2
      set got(dildo,style) $style
      utimer 70 finishdildo
    }
    return 0
  }
  
}
