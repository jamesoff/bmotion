# bMotion simple plugins
#
# Modify this to fit your needs :)
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

#                         name  regexp            %  responses
bMotion_plugin_add_simple "url-img" {(http|ftp)://([[:alnum:]]+\.)+[[:alnum:]]{2,3}.+\.(jpg|jpeg|gif|png)} 25 "%VAR{rarrs}" "en"
bMotion_plugin_add_simple "url-gen" {(http|ftp)://([[:alnum:]]+\.)+[[:alnum:]]{2,3}} 15 "%VAR{bookmarks}" "en"
bMotion_plugin_add_simple "ali g" "^((aiii+)|wikkid|innit|respect|you got me mobile|you iz)" 40 "%VAR{aiis}" "en"
bMotion_plugin_add_simple "wassup" "^wa+((ss+)|(zz+))u+p+(!*)?$" 40 "wa%REPEAT{4:12:a}up!" "en"
bMotion_plugin_add_simple "oops" "^(oops|who+ps|whups|doh |d\'oh)" 40 "%VAR{ruins}" "en"
bMotion_plugin_add_simple "shocked" "^((((=|:|;)-?(o|0))|(!+))|blimey|crumbs|i say)$" 40 "%VAR{shocked}" "en"
bMotion_plugin_add_simple "bof" "^bof$" 30 "alors" "en"
bMotion_plugin_add_simple "alors" "^alors$" 30 "bof" "en"
bMotion_plugin_add_simple "foo" "^foo$" 30 "bar" "en"
bMotion_plugin_add_simple "bar" "^bar$" 30 "foo" "en"
bMotion_plugin_add_simple "moo" "^mooo*!*$" 40 "%VAR{moos}" "en"
bMotion_plugin_add_simple ":(" "^((:|;|=)(\\\(|\\\[))$" 40 "%VAR{boreds}" "en"
bMotion_plugin_add_simple "bored" "i'm bored" 40 "%VAR{boreds}" "en"
bMotion_plugin_add_simple "transform" "^%botnicks:?,? transform and roll out" 100 [list "/transforms into %VAR{sillyThings} and rolls out"] "en"
bMotion_plugin_add_simple "didn't!" "^i didn'?t!?$" 40 "%VAR{ididntresponses}" "en"
bMotion_plugin_add_simple "ow" "^(ow+|ouch|aie+)!*$" 50 "%VAR{awwws}" "en"
#kis moved the following line to complex_questions because it was breaking stuff.
#kis bMotion_plugin_add_simple "question-have" "^%botnicks:?,? do(n'?t)? you (like|want|find .+ attractive|get horny|(find|think) .+ (is ?)horny|have|keep)" 100 "%VAR{yesnos}" "en"
bMotion_plugin_add_simple "dude" "^Dude!$" 40 "%VAR{sweet}" "en"
bMotion_plugin_add_simple "sweet" "^Sweet!$" 40 "%VAR{dude}" "en"
bMotion_plugin_add_simple "asl-catch" {[0-9]+%slash[mf]%slash.+} 75 "%VAR{greetings}" "en"
bMotion_plugin_add_simple "sing-catch" {^#.+#$} 40 [list "no singing%colen" "shh%colen"] "en"