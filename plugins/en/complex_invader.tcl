# $Id$
#
# simsea's "Invader Zim" plugin

###############################################################################
# This is a bMotion plugin
# Copyright (C) Andrew Payne 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

# bMotion_plugin_complex_invader_duty
# specific Gir moment... whenever anyone says duty (or duty sounding word)
# bMotion responds with some suitably random dootie phrase
proc bMotion_plugin_complex_invader_duty { nick host handle channel text } {
	global randomDootie
  if {![bMotion_interbot_me_next $channel]} { return 0 }
	bMotionDoAction $channel "" "%VAR{randomDootie}"

	# log this action 
	bMotion_putloglev d * "bMotion: (invader:duty) hehehe $nick said dootie"
}
# end bMotion_plugin_complex_invader_duty

# bMotion_plugin_complex_invader_zim
# general Invader Zim moments. will respond with random Invader Zim statement
proc bMotion_plugin_complex_invader_zim { nick host handle channel text } {
	global randomZimness botnick
  if {![bMotion_interbot_me_next $channel]} { return 0 }
	bMotionDoAction $channel "" "%VAR{randomZimness}"
	
	#log this action
	bMotion_putloglev d * "bMotion: (invader:zim) $nick invoked the wrath of invader $botnick"
}
# end bMotion_plugin_complex_invader_zim

# bMotion_plugin_complex_invader_gir
# general Gir moments, will respond with suitably insane Gir comment
proc bMotion_plugin_complex_invader_gir { nick host handle channel text } {
	global randomGirness botnick
  if {![bMotion_interbot_me_next $channel]} { return 0 }
	bMotionDoAction $channel "" "%VAR{randomGirness}"
	
	#log this action
	bMotion_putloglev d * "bMotion: (invader:gir) i like dootie"
}
# end bMotion_plugin_complex_invader_gir

# bMotion_plugin_complex_invader_nick
proc bMotion_plugin_complex_invader_nick { nick host handle channel newnick } {
  if {![bMotion_interbot_me_next $channel]} { return 1 }
  
  #check we haven't already done something for this nick
  if {$nick == [bMotion_plugins_settings_get "complex:returned" "lastnick" $channel ""]} {
    return 0
  }

  #check we haven't already done something for this nick
  if {$nick == [bMotion_plugins_settings_get "complex:away" "lastnick" $channel ""]} {
    return 0
  }

  #save as newnick because if they do a /me next it'll be their new nick
  bMotion_plugins_settings_set "complex:away" "lastnick" $channel "" $newnick


  #save as newnick because if they do a /me next it'll be their new nick
  bMotion_plugins_settings_set "complex:returned" "lastnick" $channel "" $newnick
  
  bMotionDoAction $channel $nick "%VAR{randomZimNameChange}"
  return 0
}
# end bMotion_plugin_complex_invader_nick

# random zimlike phrases
bMotion_abstract_register "randomZimness"

# random girlike phrases
bMotion_abstract_register "randomGirness"

# random "duty" responses... inevitable Gir
bMotion_abstract_register "randomDootie"

# random zim/gir name change responses
bMotion_abstract_register "randomZimNameChange"

# callbacks

# "duty" plugin responds to "duty" and variations of "dootie"
bMotion_plugin_add_complex "invader(duty)" "duty|doo+(t|d)(ie|y)" 20 "bMotion_plugin_complex_invader_duty" "en"

# "zim" plugin responds to "invade or invasion" "zim" "mwahahaha or hahaha" "victory for" "how dare" "you dare"
bMotion_plugin_add_complex "invader(zim)" "zim|inva(de|sion)|((mwa)?ha(ha)+)|(victory for)|((you|how) dare)" 20 "bMotion_plugin_complex_invader_zim" "en"

# "gir" plugin responds to "gir" "whooo or wooo" "chicken" "doom" "piggy"
bMotion_plugin_add_complex "invader(gir)" "w(h)?oo+|chicken|gir(!+| )|doo+m|piggy" 20 "bMotion_plugin_complex_invader_gir" "en"

# nick change response
bMotion_plugin_add_irc_event "invader(nick)" "nick" ".*" 5 "bMotion_plugin_complex_invader_nick" "en"

