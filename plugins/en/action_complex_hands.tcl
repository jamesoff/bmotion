## bMotion complex plugin: hands
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

bMotion_plugin_add_action_complex "hands" "(hands|gives) %botnicks " 100 bMotion_plugin_complex_action_hands "en"

proc bMotion_plugin_complex_action_hands { nick host handle channel text } {
  global botnicks
	if {[regexp -nocase "(hands|gives) $botnicks (a|an|the|some)? (.+)" $text bling act bot preposition item]} {
	  bMotion_putloglev d * "bMotion: Got handed !$item! by $nick in $channel"

    #Coffee
		if [regexp -nocase "(cup of )?coffee" $item] {
      bMotion_plugin_complex_action_hands_coffee $channel $nick
      return 1
		}

    #hug
    if [regexp -nocase "^hug" $item] {
      if [bMotion_plugin_check_depend "action_complex:hugs"] {
        bMotion_plugin_complex_action_hugs $nick $host $handle $channel ""
        return 1
      }
    }

    # Tissues
    if [regexp -nocase "((box of)|a)? tissues?" $item] {
      bMotion_plugin_complex_action_hands_tissues $channel $nick
      return 1
    }

    # Body paint
    if [regexp -nocase "(chocolate|strawberry) (sauce|bodypaint|body paint|body-paint)" $item] {
      bMotion_plugin_complex_action_hands_bodypaint $channel $nick
      return 1
    }

    # pie
    if [regexp -nocase "pie" $item] {
      bMotion_plugin_complex_action_hands_pie $channel $nick
      return 1
    }

    #spliff
    if [regexp -nocase "(spliff|joint|bong|pipe|dope|gear|pot)" $item] {
      bMotion_plugin_complex_action_hands_spliff $channel $nick $handle
      return 1
    }

    #dildo
    if [regexp -nocase "(dildo|vibrator|cucumber|banana|flute)" $item bling item2] {
      if [bMotion_plugin_check_depend "action_complex:hands_dildo"] {
        bMotion_plugin_complex_action_hands_dildo $channel $nick $item $item2
      }
      return 1
    } 
    #end of "hands dildo"

    #catch everything else
    bMotionDoAction $channel $item "%VAR{hand_generic}"
    
    #we'll add it to our random things list for this session too
    bMotion_abstract_add "sillyThings" $item
  } 
  #end of "hands" handler
}


# supporting functions

##### COFFEE
proc bMotion_plugin_complex_action_hands_coffee { channel nick } {
  global got
  set coffeeNick [bMotion_plugins_settings_get "complexaction:hands" "coffee_nick"  "" ""]
  bMotion_putloglev 1 * "bMotion: ...and it's a cup of coffee... mmmmmmm"
  if {$coffeeNick != ""} {
    bMotion_putloglev 1 * "bMotion: But I already have one :/"
    bMotionDoAction $channel $nick "%%: thanks anyway, but I'm already drinking the one $coffeeNick gave me :)"
    return 1
  }
  driftFriendship $nick 2
  bMotionDoAction $channel "" "%VAR{thanks}"
  bMotionDoAction $channel "" "mmmmm..."
  bMotionDoAction $channel "" "/drinks the coffee %VAR{smiles}"
  bMotion_plugins_settings_set "complexaction:hands" "coffee_nick" "" "" $nick
  bMotion_plugins_settings_set "complexaction:hands" "coffee_channel" "" "" $channel
  utimer 45 { bMotion_plugin_complex_action_hands_finishcoffee }
  return 1
}

proc bMotion_plugin_complex_action_hands_finishcoffee { } {
  global mood
  set coffeeChannel [bMotion_plugins_settings_get "complexaction:hands" "coffee_channel" "" ""]
	bMotionDoAction $coffeeChannel "" "/finishes the coffee"
	bMotionDoAction $coffeeChannel "" "mmmm... thanks :)"
  incr mood(happy) 1
	bMotion_plugins_settings_set "complexaction:hands" "coffee_nick" "" "" ""
}


##### TISSUES

proc bMotion_plugin_complex_action_hands_tissues { channel nick } {
  bMotion_putloglev 1 * "bMotion: ...and it's a box of tissues! ~rarr~"
  global mood
  if {$mood(horny) < -3} {
    bMotion_putloglev 1 * "bMotion: But i'm not in the mood"
    bMotionDoAction $channel "" "$nick: thanks, but i'm not in the mood for that right now :("
  }

  set tissuesNick [bMotion_plugins_settings_get "complexaction:hands" "tissues_nick" "" ""]
  if {$tissuesNick != ""} {
    bMotion_putloglev 1 * "bMotion: But I already have one :/"
    bMotionDoAction $channel "" "$nick: thanks anyway, but I'm already using the tissues $tissuesNick gave me :) *uNF*"
  }

  driftFriendship $nick 2
  bMotionDoAction $channel "" "%VAR{thanks}"
  bMotionDoAction $channel $nick "/locks %himherself in the bathroom"
  bMotion_plugins_settings_set "complexaction:hands" "tissues_nick" "" "" $nick
  bMotion_plugins_settings_set "complexaction:hands" "tissues_channel" "" "" $channel

  #TODO: this mood stuff is OLD
  incr mood(lonely) -1
  incr mood(horny) -1
  incr mood(happy) 2

  utimer 90 bMotion_plugin_complex_action_hands_finishtissues
}

proc bMotion_plugin_complex_action_hands_finishtissues { } {
  global mood
  set tissuesChannel [bMotion_plugins_settings_get "complexaction:hands" "tissues_channel" "" ""]
  bMotionDoAction $tissuesChannel "" "uNF *squeaky* *boing* *squirt*"
  bMotionDoAction $tissuesChannel "" "/finishes using the tissues"
  bMotion_plugins_settings_set "complexaction:hands" "tissues_nick" "" "" ""

  #TODO: this mood stuff is OLD
  incr mood(happy) 1
  incr mood(horny) -2
}


###### BODY PAINT

proc bMotion_plugin_complex_action_hands_bodypaint { channel nick } {
  bMotion_putloglev 1 *  "bMotion: Ooh ooh body paint!"
  if {![bMotionLike $nick]} {
    frightened $nick $channel
    return 0
  }

  global bMotionInfo
  driftFriendship $nick 2
  if {$bMotionInfo(gender) == "male"} {
    bMotionDoAction $channel $nick "/applies it to %%"
    bMotionDoAction $channel $nick "/licks it off"
    return 0
  }

  #female
  set bodyPaintNick [bMotion_plugins_settings_get "complexaction:hands" "paint_nick" "" ""]

  if {$bodyPaintNick != ""} {
    bMotion_putloglev 1 * "bMotion: But I'm already wearing some"
    bMotionDoAction $channel $bodyPaintNick "Thanks $nick but I'm already waiting for %% to lick some body paint off me"
    return 0
  }

  bMotionDoAction $channel $nick "/smears it over herself and waits for %% to come and lick it off"
  bMotion_plugins_settings_set "complexaction:hands" "paint_nick" "" "" $nick
  bMotion_plugins_settings_set "complexaction:hands" "paint_channel" "" "" $channel
  utimer 60 bMotion_plugin_complex_action_hands_finishPaint
  return 0
}

proc bMotion_plugin_complex_action_hands_finishPaint { } {
  set bodyPaintNick [bMotion_plugins_settings_get "complexaction:hands" "paint_nick" "" ""]
  set bodyPaintChannel [bMotion_plugins_settings_get "complexaction:hands" "paint_channel" "" ""]
  bMotionDoAction $bodyPaintChannel $bodyPaintNick "/gets bored of waiting for %% and licks the body paint off by herself instead"
  bMotion_plugins_settings_set "complexaction:hands" "paint_nick" "" "" ""
  bMotionGetHorny
  bMotionGetLonely
}

##### PIE

proc bMotion_plugin_complex_action_hands_pie { channel nick } {
  driftFriendship $nick 1
  bMotion_putloglev 1 * "bMotion: ah ha, pie :D"
  bMotionGetHappy
  bMotionGetUnLonely
  bMotionDoAction $channel $nick ":D%|thanks %%%|/eats pie"
  return 0
}

##### SPLIFF

proc bMotion_plugin_complex_action_hands_spliff { channel nick handle } {
  global mood

  driftFriendship $nick 1
  bMotion_putloglev 1 * "bMotion: ... and it's mind-altering drugs! WOOHOO!"
  bMotion_putloglev 1 * "bMotion: ...... wheeeeeeeeeeeeeeeeeeeeeeeeeeeeeee...."
  incr mood(stoned) 2
  checkmood $nick $channel
  bMotionDoAction $channel $nick "%VAR{smokes}"
  return 0
}

# abstracts
set hand_generic {
  "%VAR{thanks}"
  "%REPEAT{3:6:m} %%"
  "Do I want this?"
  "Just what I've always wanted %VAR{smiles}"
}