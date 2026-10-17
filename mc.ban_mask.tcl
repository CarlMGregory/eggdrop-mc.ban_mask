##
# Ban Mask v1.0
#  by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#
# This script, along with others, are best found at bseen.tclslave.net
#
# My SVS Website - http://mc.purehype.net/
##

##
# This script will ban people matching the specific hostmask you give it.
# I say you can do this with .+ban but Duckman states a script would be
# more effecent.  His origional idea was a ban nick script -- but why
# stop there when you have ident and possibly crude vhosts.  The idea
# is to ban people that have bad words in there hostmask.
##

##
# Commands are preformed via DCC chat with the bot, here are a listing
# of the commands:
#
# This will show you a list of current ban'd masks.
#  .banmask [#channel]
# This will add a new mask ban.
#  .banmask [#channel] [add <word [reason]>]
# This will remove a mask ban.
#  .banmask [#channel] [remove <word>]
#
# If you specify [#channel] then the command is channel specific, otherwise
# is is global.  Word will be matched in 3 ways, either the nick, the ident
# or the host.  If you have a banmask setup as "sex" and someone comes in
# with foxy!~world@i.am.a.sexy.nut.com or foxy!~sexy@austin.rr.com or
# allsex1!~world@austin.rr.com they would match the banmask.  "word" can
# contain "*" wildcards.
##

##
# History
##
# v1.0 (02.08.01)
#  MC_8 - Duckman - Inital release.
##

# Note:
#  There is one setting you set from dcc chat with the bot using .chanset.
#   <+/->mc.banmask  Setting this to +mc.banmask on the specific channel
#                    will enable the channel to utalize this script.
#
#  Example from dcc chat with the bot:
#   .chanset #channel +mc.banmask

# What flag'd users do you want the script to ignore?  Set to -|- to ignore
# no one.
set mc_banm(ig:flag) "-|-"

# What do you want to call the datafile?
set mc_banm(datafile) "scripts/.banm.data"

# If someone is found with a bad mask, what do you want the script to do?
# -2 = /MSG Warn
# -1 = Kick
#  0 = Server Ban
#  1 and up is ban time in min's.
set mc_banm(pre:pun) -2

# If the above setting is 0, How long do you want to give them before scanning
# them again for further punishment?  Set to 0 if you don't wanna rescan.
# (in min's)
set mc_banm(warn:time) 1

# What do you want to say for a warning/kick/ban message?
# %banmask will be replaced with the ban'd mask word.
# %chan will be replaced with the current channel.
# %uhost will be replaced with the users nick!ident@host.
set mc_banm(warn:msg) "Hiya, you have 1 minute to get rid of %banmask in your hostmask of %uhost, or ya will be booted from %chan."

# If someone is STILL in the violation of the ban'd mask after giving them
# warning, what do you want the script to do?
# -1 = Kick
#  0 = Server Ban
#  1 and up is ban time in min's.
set mc_banm(post:pun) 5

# How do you want to mask the bans?
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9, but
#     instead of using a * wildcard to replace portions of the host.domain, it uses ?
#     wildcards to replace the numbers in the address.
set mc_banm(banmask) 3

## MC SVS (Script Version Server) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_banm(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_banm(svs:check) 0  ;#This is at Midnight
#  set mc_banm(svs:check) 5  ;#This is at 5am
#  set mc_banm(svs:check) 13  ;#This is at 1pm
#  set mc_banm(svs:check) 23  ;#This is at 11pm
set mc_banm(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_banm(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_banm(svs:stableonly) 0



### END OF CONFIG OPTIONS ###

set mc_banm(version) "v1.0"
set mc_banm(svs:script) "banmask 001000000000"
set mc_banm(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Ban Mask $mc_sf(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Ban Mask $mc_sf(version) will not work with eggdrop $version."
 putlog "Ban Mask $mc_sf(version) not loaded."
 return 1
};setudef flag mc.banmask

utimer 1 mc:bm:init
proc mc:bm:init {} {
 global mc_bm
 foreach chan [string tolower [channels]] {
  if {[mc:bm:inter:chanflagison $chan mc.banmask]} {set mc_bm(:$chan:on:) 1} {
   set mc_bm(:$chan:on:) 0
  }
 };utimer 30 mc:bm:chanscan
}

proc mc:bm:chanscan {} {
 global mc_bm
 foreach chan [string tolower [channels]] {
  if {[mc:bm:inter:chanflagison $chan mc.banmask]} {
   if {!$mc_bm(:$chan:on:)} {
    foreach user [chanlist $chan] {
     mc:bm:scan $user [getchanhost $user $chan] [nick2hand $user] $chan 0
    }
   };set mc_bm(:$chan:on:) 1
  } {set mc_bm(:$chan:on:) 0}
 }
}

bind nick - * mc:bm:nick
proc mc:bm:nick {nick uhost hand chan newnick} {
 global botnick
 if {$newnick != $botnick} {mc:bm:scan $newnick $uhost $hand $chan 0}
}

bind join - * mc:bm:join
proc mc:bm:join {nick uhost hand chan} {
 global botnick
 if {$nick == $botnick} {
  foreach user [chanlist $chan] {
   mc:bm:scan $user [getchanhost $user $chan] [nick2hand $user] $chan 0
  }
 } {mc:bm:scan $nick $uhost $hand $chan 0}
}

proc mc:bm:scan {nick uhost hand chan warned} {
 global mc_banm botnick
 set chan [string tolower $chan]
 if {($nick == $botnick) || (![onchan $nick $chan]) ||
     (![mc:bm:inter:chanflagison $chan mc.banmask])} {return}
 set i 0
 foreach ban $mc_banm(!banmask) {
  if {([string tolower [lindex $ban 0]] == [string tolower $chan]) ||
      ([string tolower [lindex $ban 0]] == "global")} {set i 1;break}
 }
 if {(!$i) || (([matchattr $hand $mc_banm(ig:flag) $chan]) &&
     ($mc_banm(ig:flag) != "-|-"))} {return 0}
 catch {unset mc_temp} ; set mc_temp(banmask) $nick![getchanhost $nick $chan]
 set maskban [mc:bm:inter:masktype $mc_temp(banmask) $mc_banm(banmask)]
 foreach ban $mc_banm(!banmask) {
  if {![string match [string tolower *[join [join [split [lindex $ban 1] *]] *]*] [string tolower $mc_temp(banmask)]]} {continue}
  if {!$warned} {
   switch -- $mc_banm(pre:pun) {
    -2 {
     puthelp "PRIVMSG $nick :[mc:bm:inter:replace $mc_banm(warn:msg) "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"]"
     putlog "$nick was warned for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."
     if {$mc_banm(warn:time)} {
      timer $mc_banm(warn:time) "mc:bm:scan [split $nick] [split $uhost] [split $hand] [split $chan] 1"
     }
    }
    -1 {
     puthelp "KICK $chan $nick :[mc:bm:inter:replace [lrange $ban 2 e] "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"]"
     putlog "$nick was kicked from $chan for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."
    }
    default {
     puthelp "MODE $chan +b $maskban"
     puthelp "KICK $chan $nick :[mc:bm:inter:replace [lrange $ban 2 e] "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"]"
     if {$mc_banm(pre:pun)} {
      newchanban $chan $maskban banmask [mc:bm:inter:replace [lrange $ban 2 e] "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"] $mc_banm(pre:pun)
      putlog "$nick was baned from $chan for $mc_banm(pre:pun) min's for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."
     } {putlog "$nick was baned from $chan for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."}
    }
   }
  } {
   switch -- $mc_banm(post:pun) {
    -1 {
     puthelp "KICK $chan $nick :[mc:bm:inter:replace [lrange $ban 2 e] "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"]"
     putlog "$nick was kicked from $chan for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."
    }
    default {
     puthelp "MODE $chan +b $maskban"
     puthelp "KICK $chan $nick :[mc:bm:inter:replace [lrange $ban 2 e] "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"]"
     if {$mc_banm(post:pun)} {
      newchanban $chan $maskban banmask [mc:bm:inter:replace [lrange $ban 2 e] "%banmask [lindex $ban 1] %chan $chan %uhost $mc_temp(banmask)"] $mc_banm(post:pun)
      putlog "$nick was baned from $chan for $mc_banm(post:pun) min's for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."
     } {putlog "$nick was baned from $chan for having [lindex $ban 1] in his mask:  $mc_temp(banmask)."}
    }
   }
  } ; return
 }
}

bind dcc - banmask mc:bm:dcc:banmask
proc mc:bm:dcc:banmask {hand idx args} {
 global mc_banm botnick ; set args [join $args]
 set chan [string tolower [lindex $args 0]]
 if {([lindex $args 1] == "") &&
     (($chan == "") || ([string index $chan 0] == "#"))} {
  if {$chan == ""} {
   putdcc $idx "Current ban'd masks list:"
   foreach ban $mc_banm(!banmask) {putdcc $idx " [join $ban]"} 
  } {
   putdcc $idx "Current ban'd masks list for $chan:"
   foreach ban $mc_banm(!banmask) {
    if {[lindex $ban 0] == $chan} {putdcc $idx " [join $ban]"}
   }
  }
 } {
  if {[string index $chan 0] != "#"} {
   if {![matchattr $hand m]} {
    putdcc $idx "You must be a global master to preform a global mask ban."
    return 0
   }
   set chan global
   set ar [string tolower [lindex $args 0]]
   set archan [string tolower [lindex $args 1]]
   set reason [lrange $args 2 e]
  } {
   if {![matchattr $hand m|m $chan]} {
    putdcc $idx "You must be a master to preform a mask ban on $chan."
    return 0
   }
   set ar [string tolower [lindex $args 1]]
   set archan [string tolower [lindex $args 2]]
   set reason [lrange $args 3 e]
  }
  if {![mc:bm:inter:chanflagison $chan mc.banmask]} {
   putdcc $idx "$chan's banmask isn't turned on.  To turn it on type `.chanset $chan +mc.banmask'"
   return 0
  }
  if {($ar != "add") && ($ar != "remove")} {
   putdcc $idx "Invalid command $ar, valid options:  add, remove."
   return 0
  }
  if {$ar == "add"} {
   foreach ban $mc_banm(!banmask) {
    if {$chan == "global"} {
     if {([lindex $ban 0] == "global") && ([lindex $ban 1] == $archan)} {
      putdcc $idx "$archan is already setup for a global ban."
      return 0
     }
    } {
     if {(([lindex $ban 0] == $chan) && ([lindex $ban 1] == $archan)) ||
         (([lindex $ban 0] == "global") && ([lindex $ban 1] == $archan))} {
      putdcc $idx "$archan is already setup for a ban."
      return 0
     }
    }
   }
   set mc_banm(!banmask) "$mc_banm(!banmask) \{[split $chan] [split $archan] [split $reason]\}"
   if {$chan == "global"} {
    foreach xchan [string tolower [channels]] {
     if {![mc:bm:inter:chanflagison $chan mc.banmask]} {set mc_bm(:$chan:on:) 0;continue}
     set mc_bm(:$chan:on:) 1
     foreach xnick [chanlist $xchan] {
      mc:bm:scan $xnick [getchanhost $xnick $xchan] [nick2hand $xnick $xchan] $xchan 0
     }
    }
   } {
    foreach xnick [chanlist $chan] {
     mc:bm:scan $xnick [getchanhost $xnick $chan] [nick2hand $xnick $chan] $chan 0
    };set mc_bm(:$chan:on:) 1
   }
  } {
   set i 1 ; set list ""
   foreach ban $mc_banm(!banmask) {
    if {([lindex $ban 0] == $chan) && ([lindex $ban 1] == $archan)} {set i 0} {
     set list "$list \{$ban\}" 
    }
   }
   if {$i} {
    putdcc $idx "$archan isn't a ban'd mask for $chan."
    return 0
   } {
    set mc_banm(!banmask) [string trimleft $list " "]
    putdcc $idx "Removed $archan from the ban list."
   }
  } ; mc:bm:save
 } ; return 1
}

proc mc:bm:save {} {
 global mc_banm
 set io [open $mc_banm(datafile) w]
 foreach ban $mc_banm(!banmask) {
  set ban [split $ban]
  puts $io "[lindex $ban 0] [lindex $ban 1] {[lrange $ban 2 e]}"
 } ; close $io ; putlog "Writing banmask file..."
}

proc mc:bm:inter:masktype {uhost type} {
 if {![string match "*!*@*.*" $uhost]} {
  set nick [lindex [split $uhost "!"] 0]
  if {$nick == ""} {
   set uhost [string range $uhost [expr [string first ! $uhost]+1] e]
   foreach chan [channels] {
    set nick [lindex [findchanuser *$uhost* $chan] 0]
    if {$nick != ""} {break}
   }
   if {$nick == ""} {set uhost $nick!} {set uhost "$nick![mc:bm:inter:gethost $nick]"}
  }
  if {$uhost == "$nick!" || $nothing} {set type "return_nothing"}
 }
 switch -exact $type {
  0 {set ban "*[string range $uhost [string first ! $uhost] e]"}
  1 {set ban "*!*[string trimleft [string range $uhost [expr [string first ! $uhost]+1] e] "~"]"}
  2 {set ban "*!*[string range $uhost [string first @ $uhost] e]"}
  3 {
   set ident [string range $uhost [expr [string first ! $uhost]+1] [expr [string last @ $uhost]-1]]
   set ban "*!*[string trimleft $ident "~"][string range [maskhost $uhost] [string first @ [maskhost $uhost]] e]"
  }
  4 {set ban "*!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"}
  5 {set ban $uhost}
  6 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range $uhost [string last "@" $uhost] e]"
  }
  7 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range $uhost [string last "@" $uhost] e]"
  }
  8 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"
  }
  9 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"
  }
  10 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!$ident$host"
   } {set ban [masktype $uhost 0]}
  }
  11 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!*[string trimleft $ident "~"]$host"
   } {set ban [masktype $uhost 1]}
  }
  12 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ban "*!*$host"
   } {set ban [masktype $uhost 2]}
  }
  13 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 11]} {set ban [masktype $uhost 3]}
  }
  14 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 12]} {set ban [masktype $uhost 4]}
  }
  15 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest [string range $uhost 0 [expr [string last "@" $uhost]-1]]
    set ban $rest$host
   } {set ban [masktype $uhost 5]}
  }
  16 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*[string trimleft [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]] "~"]"
    set ban $rest$host
   } {set ban [masktype $uhost 6]}
  }
  17 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {
    set host [replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*"
    set ban $rest$host 
   } {set ban [masktype $uhost 7]}
  }
  18 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 16]} {set ban [masktype $uhost 8]}
  }
  19 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[findip [string range $host 1 e]] == "0"} {set ban [masktype $uhost 17]} {set ban [masktype $uhost 9]}
  }
  return_nothing {set ban ""}
  default {set ban "*!*[string range $uhost [string first "@" $uhost] e]"}
 }
 set _nick [lindex [split $ban !] 0]
 set _ident [string range $ban [expr [string first ! $ban]+1] [expr [string last @ $ban]-1]]
 set _host [string range $ban [expr [string last @ $ban]+1] e]
 if {$_ident != [set temp [string range $_ident [expr [string length $_ident]-9] e]]} {
  set _ident *[string trimleft $temp *]
 }
 if {$_host != [set temp [string range $_host [expr [string length $_host]-63] e]]} {
  set _host *[string trimleft $temp *]
 } ; return $_nick!$_ident@$_host
}

proc mc:bm:inter:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

proc mc:bm:inter:gethost {args} {
 set nik [lindex [split $args] 0]
 foreach chan [channels] {
  if {[onchan $nik $chan]} {
   return [getchanhost $nik $chan]
  }
 } ; return ""
}

proc mc:bm:inter:filt {data} {
 regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
 regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}

set mc_banm(!banmask) ""
if {![file exists $mc_banm(datafile)]} {
 set io [open $mc_banm(datafile) w] ; close $io
 set temp "\n ^\n `- Datafile not detected, remember to add ban'd masks.\n     `-Commands are explained in the script."
} {
 set io [open $mc_banm(datafile) r]
 while {![eof $io]} {
  set string [gets $io]
  if {[join $string] == ""} {continue}
  set mc_banm(!banmask) "$mc_banm(!banmask) \{[split [lindex $string 0]] [split [lindex $string 1]] [split [lindex $string 2]]\}"
 } ; close $io
 set mc_banm(!banmask) [string trimleft $mc_banm(!banmask) " "]
 set mc_banm(!banmask) [string trimright $mc_banm(!banmask) " "]
 set temp ""
}

proc mc:bm:inter:chanflagison {chan flag} {
 set chan [string tolower $chan]
 foreach info [channel info $chan] {
  if {[string range $info 1 e] == $flag} {
   if {[string index $info 0] == "-"} {return 0} {return 1}
  }
 };return 0
}

if {$mc_banm(svs:enabled)} {
 if {($mc_banm(svs:check) > "23") || ($mc_banm(svs:check) < "0")} {set mc_banm(svs:check) 00}
 if {[string length $mc_banm(svs:check)] == "1"} {set mc_banm(svs:check) 0$mc_banm(svs:check)}
 if {$mc_banm(svs:stableonly)} {
  set mc_banm(svs:script) [string range $mc_banm(svs:script) 0 [expr [string length $mc_banm(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_banm(svs:oldcheck) * * *" mc:banm:svs:time}
 set mc_banm(svs:oldcheck) $mc_banm(svs:check)
 bind time - "00 $mc_banm(svs:check) * * *" mc:banm:svs:time
 proc mc:banm:svs:time {min hour day month year} {
  global mc_banm
  catch {control [connect [lindex $mc_banm(svs:server) 0] [lindex $mc_banm(svs:server) 1]] mc:banm:svs:interface}
 }
}
proc mc:banm:svs:interface {idx args} {
 global mc_banm;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_banm(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_banm(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_banm(svs:script) 1]} {
    set note [mc:banm:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:banm:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:banm:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_banm(version)}"]
    set note [mc:banm:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:banm:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:banm:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:banm:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_banm(svs:notify) ",;"]] {
     set outnote [mc:banm:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_banm(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_banm(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:banm:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

if {[info exists mc_banm()]} {
 putlog " ,- mc_banm() detected -- you cannot change the words in the ()'s!"
 putlog " |- This script may not function correctly..."
 putlog " V"
}
putlog "Ban Mask $mc_banm(version) by MC_8 loaded. $temp"