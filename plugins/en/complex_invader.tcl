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
	#global randomZimNameChange
	#set nickresponse [ pickRandom $randomZimNameChange ]
	#return $nickresponse 
  if {![bMotion_interbot_me_next $channel]} { return 0 }
  bMotionDoAction $channel $nick "%VAR{randomZimNameChange}"
  return 1
}
# end bMotion_plugin_complex_invader_nick

# random zimlike phrases
set randomZimness { 
	"yes, my tallest!"
	"how can you have an operation impending doom 2 without me?"
	"doom. doooom."
	"shouldn't you be frying something?"
	"but sir, we're still on our own planet"
	"invader blood runs through my viens like giant radioactive rubber pants... the pants command me! do not ignore my viens!"
	"silence!"
	"pitiful human"
	"Gir... help me... there isn't much time!"
	"MADNESS%colen"
	"have you the brain worms?"
	"you won't make a fool of this Irken invader"
	"I'll just have to wait for the skin to grow back on my eyeballs"
	"ow... my spine"
	"mwahahahahahahahahahaha"
	"you lie... YOU LIEEEEEEE%colen"
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
	"say, you're full of organs aren't you? and you wouldn't notice if you were missing a few?"
	"evaluation: PATHETIC%colen"
	"surely that was no human bee!"
	"when the repairs are done i shall hunt down that evil death bee."
	"why am i so amasing?"
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
	"i will be... LORD OF ALL HUMANS%colen"
	"i will rule you all with an iron fist"
	"i will prepare food with my iron fist"
	"you... obey my fist"
	"i am %me%colen"
	"take me to the meat"
	"i have a MIGHTY NEED to use the restroom"
	"LEAVE NO EVIDENCE%colen"
	"do not invoke the wrath of the Irken elite!"
	"stop sniveling little worm monkey"
	"now to release screaming temporal doom"
	"something is broken and it's not your fault?"	
	"the very thought of it make me... makes... little... sicky noises"
	"i have a plan... an amasing plan"
	"FOOLS! i am %me!"
	"time for another amasing plan from me... %me!"
	"i have already stuffed my normal human belly with delicious human filth that i could not eat another bite"
	"ah! ah! THE MEAT!! THE HORRIBLE MEAN%colen"
	"meats of evil! meat of EVIL%colen"
	"is it a fair fight... is this moose weilding any projectile weapons?"
	"i told you that you would would rue the day when you messed with %me... now begin your rueing... i'll just sit here and watch."
	"dumb like a moose."
	"the dogs! they're after my meat body of juicy bologna meats."
	"be quiet"
	"why was there bacon in the soap?"
	"i will call you... pusstulio"
	"come my filthy stink children"
	"you will open your eyes... you have to breath sometime"
	"he is part of the collective now"
	"please buy my candies or my little brother will go insane"
	"they've locked down their fortress... with locks"
	"release me! release me or suffer the wrath of %me"
	"who are you people"
	"rise up and use your revolting limbs to escape this prison"
	"nothing can stop %me... nothing! not even this army of zombies"
	"silence... my victory begins now"
	"more power... give me MORE POWER%colen"
	"prepare to meet your horrible doom"
	"with my mighty fists of horror, and unstoppable cruelty, i am the tool of destruction, vengeance and fury"
	"are we going to have trouble soldier"
	"behold the fortress of pain"
	"soon they'll all be after my delicious guts"
	"i have had enough of your smelly mouth filled with corn"
	"as soon as my skeleton stops being broken i will destroy you"
	"when will the lies end?!"
	"wave of doom"
	"you man the tractor beam, i'll pump the cows full of human sewage"
	"sometimes i'm afraid to find out what goes on in that insane head of yours"
	"you dare tell me what i already know?!?!?!"
	"curse you snacks... CURSE YOU%colen"
	"delicious DELICIOUS... I AM NORMAL%colen"
	"i'm in a bear suit"
	"DESTRUCTION IS NICE%colen"
	"the taste of human annihilation grows stronger in my amasing head"
	"people of earth! prepare to meet the mighty foot of my planet"
	"well... yes... i'm an unstoppable death machine"
	"i congradulate you in recognising my superiority and choosing me to be your love pig!"
	"you magical love adventure begins now"
	"now cry... CRY like you've never cried...... before"
	"you're after my robot bee%colen"
	"yes yes... i'm a master of comedy, now what's this plan"
	"don't touch anything or i'll melt your face off or something"
}

# random girlike phrases
set randomGirness {
	"i don't know... weee hoo hoo hoo!"
	"I'm gonna sing the doom song now... dooom doom doom"
	"that's my favourite show"
	"whoooo I'm naked"
	"*sniff* I miss you cupcake"
	"dootie!"
	"wooo... I like destroying"
	"i had no idea."
	"ahhh... it's got chicken legs %VAR{smiles}"
	"i'm so happy %VAR{smiles}"
	"yes, my master."
	"lepricauns"
	"i'm making a cake"
	"yes... wait a minute... no."
	"doo dee doo dedo deee do"
	"i got chocolate bubblegum!"
	"hooray for earth!"
	"weee hehehehehehehehe"
	"let's go to my room, pig"
	"aw.. somebody needs a hug %VAR{smiles}"
	"I like you"
	"tacos"
	"where's my moose"
	"oooh... what's that do?"
	"do do do do do do do... do do do do do.... do doo do do do do do... do do do do do doooo"
	"i need tacos... i need them or i explode. that happens sometimes"
	"WHY! WHY my piggy, WHY?? I loved you my piggy... I loved you"
	"i know... i'm scared too"
	"wee... do that again"
	"let's make biscuts... LET'S MAKE BISCUTS"
	"stolen?"
	"i like TV"
	"aw... i wanted to explode"
	"I'm guarding the house"
	"thank you... i love you."
	"i had a coupon"
	"yes... i will stop... i will obey"
	"yay... i'm gonna be sick"
	"do you have any  tacidos?"
	"ahh... it's got chicken legs"
	"i had no idea"
	"i can still see you"
	"chicken!! I'm gonna eat you"
	"aw... you look so cute"
	"me and the squirrel are friends"
	"aw... your little robot toy is broken"
	"hi floor... make me a sandwich"
	"i gotta go pig... i'll see you later"
	"aw... it's broken"
	"you're on fire"
	"yay! brains!"
	"yay... i burns"
	"i don't wanna.... ok"
	"won't the exploding hurt?"
}

# random "duty" responses... inevitable Gir
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
set randomZimNameChange {
	"master where did you go? I can't see you"
	"master?"
	"where'd my moose go?"
}

# callbacks

# "duty" plugin responds to "duty" and variations of "dootie"
bMotion_plugin_add_complex "invader(duty)" "duty|doo+(t|d)(ie|y)" 40 "bMotion_plugin_complex_invader_duty" "en"

# "zim" plugin responds to "invade or invasion" "zim" "mwahahaha or hahaha" "victory for" "how dare" "you dare"
bMotion_plugin_add_complex "invader(zim)" "zim|inva(de|sion)|((mwa)?ha(ha)+)|(victory for)|((you|how) dare)" 40 "bMotion_plugin_complex_invader_zim" "en"

# "gir" plugin responds to "gir" "whooo or wooo" "chicken" "doom" "piggy"
bMotion_plugin_add_complex "invader(gir)" "w(h)?oo+|chicken|gir(!+| )|doo+m|piggy" 40 "bMotion_plugin_complex_invader_gir" "en"

# nick change response
bMotion_plugin_add_nick_action "invader(nick)" ".*" 40 "bMotion_plugin_complex_invader_nick" "en"

