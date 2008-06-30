#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "hands" "(hands|gives) %botnicks " 100 bMotion_plugin_complex_action_hands "en"

proc bMotion_plugin_complex_action_hands { nick host handle channel text } {
	global botnicks
	if {[regexp -nocase "(hands|gives) $botnicks ((a|an|the|some) )?(.+)" $text bling act bot moo preposition item]} {
		bMotion_putloglev d * "bMotion: Got handed !$item! by $nick in $channel"

		#Coffee
		if [regexp -nocase "(cup of )?coffee" $item] {
			driftFriendship $nick 5
			bMotion_plugin_complex_action_hands_coffee $channel $nick
			return 1
		}

		#hug
		if [regexp -nocase "^hug" $item] {
			if [bMotion_plugin_check_depend "action_complex:hugs"] {
			driftFriendship $nick 5
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
		if [regexp -nocase {\mpie\M} $item] {
			driftFriendship $nick 5
			bMotion_plugin_complex_action_hands_pie $channel $nick
			return 1
		}

		#spliff
		if [regexp -nocase "(spliff|joint|bong|pipe|dope|gear|pot)" $item] {
			driftFriendship $nick 3
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

		#check to see if it's a nick
		# we won't check handles as people will probably just tab-complete nicks
		if [onchan $item $channel] {
			if [bMotionIsFriend $item] {
				if [bMotionLike $item] {
					# we REALLY like them
					bMotionDoAction $channel $nick "%VAR{hand_sex_person}"
					driftFriendship $nick 5
					return 1
				}
				bMotionDoAction $channel $nick "%VAR{hand_like_person}"
				driftFriendship $nick 3
				return 1
			} else {
				bMotionDoAction $channel $nick "%VAR{hand_dislike_person}"
				driftFriendship $nick -3
				return 1
			}
		}

		# not a nick, let's carry on with the generic stuff
		bMotion_abstract_add "sillyThings" $item

		set original_item $item
		set item [string tolower [bMotion_strip_article $item]]
		regsub "s$" $item "" item

		# check if we already know if we don't like this
		if [bMotion_abstract_contains "_bmotion_dislike" $item] {
			bMotionDoAction $channel $original_item "%VAR{hand_dislike}" $nick
			return 1
		}

		if [bMotion_abstract_contains "_bmotion_like" $item] {
			bMotionDoAction $channel $original_item "%VAR{hand_like}" $nick
			return 1
		}

		if {[rand 100] > 80} {
			bMotionDoAction $channel $original_item "%VAR{hand_dislike}" $nick
			bMotion_abstract_add "_bmotion_dislike" $item
		} else {
			bMotionDoAction $channel $original_item "%VAR{hand_like}" $nick
			bMotion_abstract_add "_bmotion_like" $item
		}
		return 1
	} 
	#end of "hands" handler
}


# supporting functions

##### COFFEE
proc bMotion_plugin_complex_action_hands_coffee { channel nick } {
	global got
	set coffeeNick [bMotion_plugins_settings_get "complexaction:hands" "coffee_nick"	"" ""]
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
bMotion_abstract_register "hand_generic" {
	"%VAR{thanks}"
	"%REPEAT{3:6:m} %%"
	"Do I want this?"
	"Just what I've always wanted %VAR{smiles}"
}

bMotion_abstract_register "_bmotion_like"
bMotion_abstract_register "_bmotion_dislike"

bMotion_abstract_register "hand_like" {
  "%REPEAT{3:10:m} %%"
  "/plays with %hisher %%"
  "%VAR{smiles}%|/shares with %2"
  "%VAR{smiles}%|/shares with %ruser{friend}"
  "i like these"
	"ooh! %VAR{smiles}"
	"my favourite!"
	"%2++"
	"%VAR{thanks}"
	"just what i've always wanted %VAR{smiles}"
}

bMotion_abstract_register "hand_dislike" {
  "oh no %%"
  "/throws it in the bin"
  "/throws it at %ruser{enemy}"
  "/jams it up %hisher arse%|that's what i think of that."
	"/jams it up %2%|do not want"
	"do not want"
	"/wipes %hisher %VAR{bodypart} with it"
	"erk not %%"
	"thanks very much%|except I hate these"
	"do i want this?"
}

bMotion_abstract_register "hand_sex_person" {
	"oof"
	"%REPEAT{3:8:m}"
	"%VAR{hand_like_person}"
}

bMotion_abstract_register "hand_like_person" {
	"%VAR{smiles}"
	"i like %%%|they are my friend %VAR{smiles}"
}

bMotion_abstract_register "hand_dislike_person" {
	"ugh"
	"meh"
	"do not want"
	"do not like"
	"i don't like %%"
	"get it off me %VAR{unsmiles}"
	"%VAR{unsmiles}"
	"%% is not my friend %VAR{unsmiles}"
	"but %% is nasty to me %VAR{unsmiles}"
}
