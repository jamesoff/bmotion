# EDIT THIS AND MOVE IT TO settings.tcl

# bMotion - Settings file
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

### GREETINGS
#
# Hi! You're about to configure your bMotion bot.
# Please look through this file carefully and change any settings as needed
# There are a few things which you really should look at, and these are marked
# [important] so you can just search for that if you like.

# Most non-important settings will probably be fine as their defaults. bMotion
# has been tuned to be as non-annoying as possible. This means it might not
# talk as much as you want. But things that talk too much stop being funny
# very quickly.

# Enjoy!



### PERSONALITY STUFF
#
# It's SO you!

# male or female [important]
set bMotionInfo(gender) "male"

# straight, gay, or bi [important]
set bMotionInfo(orientation) "straight"

# list of nicks to respond to, separate with the | character [important]
# regexp is ok, but don't use brackets of any sort: () [] {} <-- NO
# your bot will automatically add its own nick to this
set bMotionSettings(botnicks) "nt|bots|the bots|notopic"

# should the bot strictly match the botnicks?
# "old" behaviour did not require the botnicks to be a word by itself,
# which could cause the bot to respond when it shouldn't really
# 
# for the regexp-inclined, this setting makes bMotion surround the
# botnicks value with \m...\M
#
# old behaviour = 0
# new behaviour = 1
set bMotionSettings(botnicks_strict) 1

# does the bot like 'kinky' stuff (e.g. see action_complex:fucks)
set bMotionSettings(kinky) 0

# greet people we don't know when they join the channel?
# 0 = only greet friends
# 1 = greet everyone
# 2 = disable greetings
# (note: this only affects the default join/quit plugins; 3rd party ones may not honour this)
set bMotionSettings(friendly) 0



### BEHAVIOUR STUFF
#
# Black or white? :)

# set to 1 to skip the gender/orientation checks
# turn this on if you're not going to both using the GENDER stuff
# in userinfo.tcl, or if you'll have a lot of people interacting
# with the bot who aren't in your userfile
set bMotionSettings(melMode) 0

# talk to everyone (this setting is being phased out)
set bMotionSettings(needI) 1

# respond to everything (rather than just stuff directly said to us)
# this setting is being phased out
# if you have a bot by itself, set to 1
# if you have more than one bot running bmotion, set one of them to 1 and all others to 0
set bMotionInfo(balefire) 1

# go away if things get idle?
set bMotionSettings(useAway) 0

# channels to run in (lower case please)
# THIS SETTING IS NOW REDUNDANT AND IS IGNORED
# Use ".chanset #channel +bmotion" instead!
#set bMotionInfo(randomChannels) { "#bitlbee" }

# channels to not announce our away status in (lower case)
# some channels don't like public aways, so don't piss them off :)
set bMotionSettings(noAwayFor) { "#irssi" }



## SYSTEM SETTINGS
#

# percent of typos (output:typos plugin)
set bMotionSettings(typos) 3

# percent of colloqualisms (output:colloq plugin)
set bMotionSettings(colloq) 10

# percent of leet changes (output:leet plugin)
set bMotionSettings(leetRandom) 0.5

# plugins we shouldn't load
set bMotionSettings(noPlugin) "simple:huk,complex:wb"

# minimum delay (mins) between random lines
set bMotionInfo(minRandomDelay) 20

# maximum delay (mins) between random lines
set bMotionInfo(maxRandomDelay) 240

# if nothing's happened on this channel for this many mins, don't say something
# (stop us talking to ourselves too much)
set bMotionInfo(maxIdleGap) 120

# if something was said fewer than this many seconds ago, we consider the
# channel active and say something more appropirate
set bMotionSettings(active_idle_sec) 300

# how long the courtmartial plugin should wait while people are in the brig
# TODO: move this into said plugin
set bMotionInfo(brigDelay) 30

# number of minutes to be silent when told to shut up
set bMotionSettings(silenceTime) 5

# languages to expect for plugins
set bMotionSettings(languages) "en,nl"

# default language to use
set bMotionInfo(language) "en"

# regexp to stop learning of facts
set bMotionSettings(ignorefacts) "is online"

# seconds per character in line
set bMotionSettings(typingSpeed) 0.05

# use the interbot stuff?
# by default, bMotion will broadcast on the botnet to find other bMotions
# so that it can talk to them (when they're in the same channel)
set bMotion_interbot_enable 1

# bias the output probability
# 0 = never trigger
# 1 = normal
# 2 = about twice as likely
# floating-point is fine
set bMotionSettings(bias) 1

# Censor output plugin
# The censor output plugin replaces words in output with "beep"
# This setting gives the words to be replaced. Some work is done to let these
#   be stems, so you don't need to add both "fuck" and "fucking". This is a space
#   separated list of words
# CAVEAT: Some of bMotion's humour comes from double-entendres, and this doesn't
#         filter those out!
set bMotionSettings(censorwords) "cunt shit piss decaf"

# Word to replace with, defaults to BEEP
#set bMotionSettings(censorbeep) "BEEP"

# Enable or disable output plugins at startup
# Format:
#    plugin1:1,plugin2:0,plugin3=#channel
# Enable plugin1 globally, disable plugin2 globally, and enable plugin3 on #channel
# To enable a plugin on more than one channel, list it more than once
# Example: "typos:0,welsh=#wales,dutch:1"
set bMotionSettings(output_preenable) ""

### Flood checking
#
# whether to disable flood checks that would prevent a malicious user 
# from triggering plugins over and over again
#
# WARNING: Disable flood checks at your own risk! Nobody except for 
# yourself will be responsible for any resulting negative effects,
# including, but not limited to nausea, dizziness, G-lines and rabid
# wolverine attacks.
set bMotionSettings(disableFloodChecks) 0


### Abstracts
#
# (Abstracts are bMotion's word lists, and some of them grow as it sees
# things on IRC)

# amount of time (in seconds) before loaded abstracts are purged from
# memory and written to disk
# you probably don't need to change this
set bMotionSettings(abstractMaxAge) 300

# maximum number of items to keep per abstract
# when an abstract has more than this many items, bMotion will start
# forgetting items at random
set bMotionSettings(abstractMaxNumber) 600

# maximum number of things about which facts can be known
# after enough are known, others are forgotten at random
set bMotionSettings(factsMaxItems) 500

# maximum number of facts to know about an item
# forgotten at random etc
set bMotionSettings(factsMaxFacts) 20



### Bitlbee mode
#
# bitlbee mode lets your bot connect to a bitlbee server and thus
# lets bMotion work on MSN, ICQ, etc. You should probably know what
# you're doing if you turn this on, as it's not really supported :)
#
# if you turn this on and connect to a normal IRC server, your bot
# will not work correctly!

set bMotionSettings(bitlbee) 0



### Sleepy stuff
#
# These settings give your bot a bedtime and a time to wake up
# When your bot's asleep, there's no way to wake it up!
# If you don't want it to do that, leave the first setting as 0
# and ignore the rest of this section

# Let the bot get tired and go to sleep? [important]
set bMotionSettings(sleepy) 1

# this is the hour and minute we should go to bed at (bMotion will sometimes stay up a bit later)
# these MUST be strings and MUST have leading zeros: 
# NO: set bMotionSettings(bedtime_hour) 9
# YES: set bMotionSettings(bedtime_hour) "9"
set bMotionSettings(bedtime_hour) "23"
set bMotionSettings(bedtime_minute) "41"

# and the time to wake up
set bMotionSettings(wakeytime_hour) "06"
set bMotionSettings(wakeytime_minute) "30"



### Stats (entirely optional!)
#
# bMotion can report back to me that it's installed, for my own curiosity
# so i can see how many bots are installed (a bit like the eggdrop stats
# module). It can also check for updates, not that there've been any for
# years, but I intend to fix that.
# 
# If you'd like to enable this, set the first setting below to 1 and then
# toggle the others to change exactly what info your bot shares with me.
#
# If you only want to check for updates, leave the first setting as 0 and
# just set the 2nd one to 1.
#
# See the comments in modules/extra/stats.tcl for more information.
# You can see the stats at http://www.bmotion.net/stats

# Send stats? [important]
set bMotion_stats_enabled 0

# Check for new versions (independent from stats)
set bMotion_stats_version 0

# What can we send (if stats_enabled is 1)
# Set these to 0 to disable sending that bit of
# info.

# this is the bot's nick
set bMotion_stats_send(botnick) 1

# the admin info ('admin' in eggdrop config)
set bMotion_stats_send(admin) 1

# the network name ('network' in eggdrop config)
set bMotion_stats_send(network) 1

# bmotion's gender/orientation
set bMotion_stats_send(bminfo) 1



### Copyright info
#
# set this to 0 to stop showing the copyright
# PLEASE DO NOT DISTRIBUTE THIS FILE IF THE VARIABLE IS SET TO 0
set bMotion_show_copyright 1
