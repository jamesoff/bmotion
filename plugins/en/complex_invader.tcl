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
	if { ![bMotion_interbot_me_next $channel] } {
		return 0 
	}
	bMotionDoAction $channel "" "%VAR{randomDootie}"

	# log this action
	bMotion_putloglev d * "bMotion: (invader:duty) hehehe $nick said dootie"
	return 1
}
# end bMotion_plugin_complex_invader_duty

# bMotion_plugin_complex_invader_zim
# general Invader Zim moments. will respond with random Invader Zim statement
proc bMotion_plugin_complex_invader_zim { nick host handle channel text } {
	global randomZimness botnick
	if { ![bMotion_interbot_me_next $channel] } {
		return 0
	}
	bMotionDoAction $channel "" "%VAR{randomZimness}"
	
	#log this action
	bMotion_putloglev d * "bMotion: (invader:zim) $nick invoked the wrath of invader $botnick"
	return 1
}
# end bMotion_plugin_complex_invader_zim

# bMotion_plugin_complex_invader_gir
# general Gir moments, will respond with suitably insane Gir comment
proc bMotion_plugin_complex_invader_gir { nick host handle channel text } {
	global randomGirness botnick
	if { ![bMotion_interbot_me_next $channel] } { 
		return 0 
	}
	bMotionDoAction $channel "" "%VAR{randomGirness}"
	
	#log this action
	bMotion_putloglev d * "bMotion: (invader:gir) i like dootie"
	return 1
}
# end bMotion_plugin_complex_invader_gir

# bMotion_plugin_complex_invader_nick
proc bMotion_plugin_complex_invader_nick { nick host handle channel newnick } {
	if { ![bMotion_interbot_me_next $channel]} { 
		return 0
	}
  
	# check we haven't already done something for this nick
	if { $nick == [bMotion_plugins_settings_get "complex:returned" "lastnick" $channel ""] } {
		return 0
	}

	# check we haven't already done something for this nick
	if { $nick == [bMotion_plugins_settings_get "complex:away" "lastnick" $channel ""] } {
		return 0
	}

	# save as newnick because if they do a /me next it'll be their new nick
	bMotion_plugins_settings_set "complex:away" "lastnick" $channel "" $newnick
	bMotion_plugins_settings_set "complex:returned" "lastnick" $channel "" $newnick
  	bMotionDoAction $channel $nick "%VAR{randomZimNameChange}"
	return 1
}
# end bMotion_plugin_complex_invader_nick

# random zimlike phrases
bMotion_abstract_register "randomZimness"
set randomZimness {
	"yes, my tallest!"
	"how can you have an operation impending doom 2 without me?"
	"doom. doooom."
	"shouldn't you be frying something?"
	"but sir, we're still on our own planet"
	"invader blood runs through my veins like giant radioactive rubber pants... the pants command me! do not ignore my veins!"
	"silence!"
	"pitiful human"
	"Gir... help me... there isn't much time!"
	"MADNESS%colen"
	"have you the brain worms?"
	"you won't make a fool of this Irken invader"
	"I'll just have to wait for the skin to grow back on my eyeballs"
	"ow... my spine"
	"mwahahahahahahahahahaha" 	"you lie... YOU LIEEEEEEE%colen"
	"squealing fools%colen"
	"we will begin by testing your absorbancy."
	"invaders need no one... NO ONE%colen"
	"victory for %me%colen"
	"nothing will stand in my way... not even drool!"
	"so... much... filth!"
	"prepare yourselves for destruction"
	"aaah, the stink of clean"
	"another win for the Irkin Empire... clean lemony fresh victory is mine."
	"i'm not giving up... i'll destroy you%colen"
	"you! burger lord! how is this meat so clean... so pure?!"
	"inferior human organs!"
	"ow! my squealyspooch!"
	"say, you're full of organs aren't you? and you wouldn't notice if you were missing a few?" 	"evaluation: PATHETIC%colen"
	"surely that was no human bee!"
	"when the repairs are done i shall hunt down that evil death bee."
	"why am i so amazing?"
	"what is the meaning of this%colen"
	"there is no so worthy as %me%colen"
	"release the pig%colen"
	"this is no man pig"
	"don't come any closer or i will lay eggs in your stomach"
	"get away... you smell like feet%colen"
	"RIDE THE PIG%colen"
	"stupid silent glue boy"
	"i will annihilate you down to your every last cell"
	"i will be in my lab bathing in paste"
	"i will be... LORD OF ALL HUMANS%colen" 	"i will rule you all with an iron fist"
	"i will prepare food with my iron fist"
	"%%... obey my fist"
	"i am %me%colen"
	"take me to the meat"
	"i have a MIGHTY NEED to use the restroom"
	"LEAVE NO EVIDENCE%colen"
	"do not invoke the wrath of the Irken elite!"
	"stop snivelling little worm monkey"
	"now to release screaming temporal doom"
	"something is broken and it's not your fault?"
	"the very thought of it make me... makes... little... sicky noises"
	"i have a plan... an amazing plan"
	"FOOLS! i am %me!"
	"time for another amazing plan from me... %me!" 	"i have already stuffed my normal human belly with delicious human filth that i could not eat another bite"
	"ah! ah! THE MEAT!! THE HORRIBLE MEAT%colen"
	"meats of evil! meat of EVIL%colen"
	"is it a fair fight... is this moose weilding any projectile weapons?"
	"i told you that you would would rue the day when you messed with %me... now begin your rueing... i'll just sit here and watch."
	"dumb like a moose."
	"the dogs! they're after my meat body of juicy bologna meats."
	"be quiet"
	"why was there bacon in the soap?"
	"i will call you... pusstulio"
	"come my filthy stink children"
	"you will open your eyes... you have to breathe sometime"
	"he is part of the collective now"
	"please buy my candies or my little brother will go insane"
	"they've locked down their fortress... with locks" 	"release me! release me or suffer the wrath of %me"
	"who *are* you people"
	"rise up and use your revolting limbs to escape this prison"
	"nothing can stop %me... nothing! not even this army of zombies!"
	"silence... my victory begins now%colen"
	"more power... give me MORE POWER%colen"
	"prepare to meet your horrible doom"
	"with my mighty fists of horror, and unstoppable cruelty, i am the tool of destruction, vengeance and fury"
	"are we going to have trouble, soldier?"
	"behold the fortress of pain"
	"soon they'll all be after my delicious guts"
	"i have had enough of your smelly mouth filled with corn"
	"as soon as my skeleton stops being broken i will destroy you"
	"when will the lies end?!"
	"wave of doom" 	"%%, you man the tractor beam, i'll pump the cows full of human sewage"
	"sometimes i'm afraid to find out what goes on in that insane head of yours"
	"you dare tell me what i already know?!?!?!"
	"curse you snacks... CURSE YOU%colen"
	"delicious DELICIOUS... I AM NORMAL%colen"
	"i'm in a bear suit"
	"DESTRUCTION IS NICE%colen"
	"the taste of human annihilation grows stronger in my amazing head"
	"people of earth! prepare to meet the mighty foot of my planet"
	"well... yes... i'm an unstoppable death machine" ]
bMotion_abstract_batchadd "randomZimness" [list "i congratulate you in recognising my superiority and choosing me to be your love pig!"
	"your magical love adventure begins now"
	"now cry... CRY like you've never cried...... before"
	"you're after my robot bee%colen"
	"yes yes... i'm a master of comedy, now what's this plan"
	"don't touch anything or i'll melt your face off or something"
	"hey! hey! HEY! hey over here, my tallest! my tallest! my taaaaaalllesst!"
	"I was curious to see when you'd shut up on your own... but it's been three hours now, %ruser... THREE HOURS%colen"
	"oh, I know all kinds of things about you... pretty creepy, huh?"
	"hey, someone's making doughnuts!"
	"The latest plan is about to explode!"
	"but his voice fills me with a terrible rage!"
	"processing... PROCESSING%colen"
	"SON! THERE BETTER NOT BE ANY WALKING DEAD UP THERE!"
	"call them, and tell them we're going to blow them up!"
	"ALERT! Something is happening at the front door! Something... horrible!"
	"you're nothing, earth-boy! go home and shave your giant head of smell with your bad self!"
	"activate the shrinky self-destruct!"
	"you dare insult the pants of %me%colen"
	"get off of me! you smell like human!"
	"%%... analysis: moron!"
	"%%... analysis: annoying!"
	"as president, I will ensure that all mankind HAS ITS LEGS SAWN OFF .... and replaced with legs of PURE GOLD!"
	"%%: Debate.. now! OR SUFFER!"
	"only now can I reveal that, if elected, I will ensure that every student is given a zombie wiener-dog to do their bidding. Can %% say that?"
	"the grotesque monster-boy avoids the issues! just what does he plan on doing about the size of %OWNER{%ruser} giant head? If I am elected, %OWNER{%%} head will be removed, and filled with salted nuts!"
	"the child shrieks like a fruitbat!"
	"well, time to work on my next evil plan."
	"the giant flesh-eating demon squid has escaped! security! protect your master! GIR! Defensive mode!"
	"ah yes... uh... %%! and how is the happiness probe in your brain doing today, FILTHY HUMAN?"
	"stay right there... we're sending someone over to beat you up for playing jokes in the FBI!"
	"no more waffles, GIR. No really, I'm starting to feel sick. *retch*"
	"AARGH! The hideous mutant squid has escaped again and has created an army of cyborg zombie soldiers to do its evil bidding!"
	"your waffle-eating days are over, %%!"
	"Well, thankfully I was able to reprogram those cyborgs at the last minute, and send them off to do HORRIBLE THINGS to the humans."
	"GIR, your waffles have sickened me! FETCH ME THE BUCKET!"
}

# random girlike phrases
bMotion_abstract_register "randomGirness"
set randomGirness {
	"i don't know... weee hoo hoo hoo!"
	"I'm gonna sing the doom song now... dooom doom doom"
	"that's my favourite show"
	"whoooo I'm naked"
	"*sniff* I miss you cupcake"
	"dootie!"
	"wooo... I like destroying"
	"i had no idea."
	"*gasp* it's got chicken legs %VAR{smiles}"
	"i'm so happy %VAR{smiles}"
	"yes, my master."
	"leprechauns"
	"i'm making a cake"
	"yes... wait a minute... no."
	"doo dee doo dedo deee do"
	"i got chocolate bubblegum!"
	"hooray for earth!"
	"weee hehehehehehehehe"
	"let's go to my room, pig"
	"aw... somebody needs a hug %VAR{smiles}"
	"I like you %VAR{smiles}"
	"tacos"
	"where's my moose"
	"oooh... what's that do?"
	"do do do do do do do... do do do do do.... do doo do do do do do... do do do do do doooo"
	"i need tacos... i need them or i explode. that happens sometimes"
	"WHY! WHY my piggy, WHY?? I loved you my piggy... I loved you"
	"i know... i'm scared too"
	"wee... do that again"
	"let's make biscuits... LET'S MAKE BISCUITS"
	"stolen?"
	"i like TV"
	"aw... i wanted to explode"
	"I'm guarding the house"
	"thank you... i love you."
	"i had a coupon"
	"yes... i will stop... i will obey"
	"yay... i'm gonna be sick"
	"do you have any  taquitos?"
	"i had no idea"
	"i can still see you"
	"%REPEAT{4:7:eh}e chicken!! I'm gonna eat you!"
	"aw... you look so cute"
	"me and the squirrel are friends"
	"aw... your little robot toy is broken"
	"hi floor... make me a sandwich"
	"i gotta go pig... i'll see you later"
	"aw... it's broken"
	"you're on fire"
	"yay! brains!"
	"yay... it burns"
	"i don't wanna.... ok"
	"won't the exploding hurt?"
	"it's me! I was the turkey all along!"
	"i made mashed potatoes!"
	"i had a sandwich in my head"
	"so... about my sandwich..."
	"gue%REPEAT{2:7:s} who made waffles!"
}

# random "duty" responses... inevitable Gir
bMotion_abstract_register "randomDootie"
set randomDootie {
	"dootie %VAR{smiles}"
	"doootie dootie dooootie dootie"
	"i like dootie"
	"ooooooooooOOOOOooooo dootie"
	"weee hoo hooo hooo! dootie"
	"dooo-tie. dooo-tie. dooo-tie. dooo-tie. dooo-tie"
	"dootie is my friend"
	"you said dootie %VAR{smiles}"
}

# random zim/gir name change responses
bMotion_abstract_register "randomZimNameChange"
set randomZimNameChange {
	"master, where did you go? I can't see you"
	"master?"
	"where'd my moose go?"
	"we have no time for these games%colen"
	"watch out for the moose"
}

# callbacks

# "duty" plugin responds to "duty" and variations of "dootie"
bMotion_plugin_add_complex "invader(duty)" "duty|doo+(t|d)(ie|y)" 20 "bMotion_plugin_complex_invader_duty" "en"

# "zim" plugin responds to "invade or invasion" "zim" "mwahahaha or hahaha" "victory for" "how dare" "you dare"
bMotion_plugin_add_complex "invader(zim)" "zim|inva(de|sion)|((mwa)?ha(ha)+)|(victory for)|((you|how) dare)" 20 "bMotion_plugin_complex_invader_zim" "en"

# "gir" plugin responds to "gir" "whooo or wooo" "chicken" "doom" "piggy", now with new improved "finally! 
bMotion_plugin_add_complex "invader(gir)" "w(h)?oo+|chicken|gir(!+| )|doo+m|piggy|finally!" 20 "bMotion_plugin_complex_invader_gir" "en"

# nick change response
bMotion_plugin_add_irc_event "invader(nick)" "nick" ".*" 5 "bMotion_plugin_complex_invader_nick" "en"

