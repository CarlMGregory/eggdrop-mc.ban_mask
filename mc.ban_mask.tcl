##
# Ban Mask v1.2 by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My SVS Website - http://mc.purehype.net:81/
##

##
# This script will ban people matching the specific hostmask you give it.
# I say you can do this with '+ban' but Duckman states a script would be
# more effecent.  His origional idea was a ban nick script -- but why
# stop there when you have ident and possibly crude vhosts.  The idea
# is to ban people that have bad words in there hostmask, but not 
# ban in that specific mask.  Example, set a Ban Mask to *!hell@*,
# if someone matching that join's, it will ban them via *!*hello@host.com.
#
# Something new that makes this script a plus over a normal '+ban' is,
# the ability to use regular expression matching on Ban Masks.
##

##
# Commands are preformed via DCC chat with the bot, here are a listing
# of the commands:
#
# This will show you a list of current ban'd masks.
#  .banmask [#channel]
#
# This will add a new mask ban.
#  .+banmask [#channel] <nick!ident@host or *word*> [reason]
#
# This will remove a mask ban.
#  .-banmask [#channel] <nick!ident@host or *word*>
#
# If you do not specify [#channel] it will be considered as global.
# <nick!ident@host or *word*> can contain wildcards.
##

##
# History
##
# v1.2 (11.14.01)
#  MC_8 - Upgraded SVS v1.2 to v2.0.
#  MC_8 - Changed 'warn:time' from min.s to sec.s.
#  MC_8 - Removed 'warn:msg', will use reason supplied when added.
#  MC_8 - Removed gethost and filt procs, not used.
#  MC_8 - Added newer version of the replace proc.
#  MC_8 - Rewrote how it stores and calls on the database information, will
#         now all go threw 1 procedure (mc:banm:list).
#  MC_8 - Added newer version of the masktype (host masking) proc.
#  MC_8 - Added 'access'.
#  MC_8 - Removed chanflagison, replace with chanflag proc.
#  MC_8 - Changed the commands up a bit.  To add and remove it's '+/-banmask'
#         rather than 'banmask add'.
#
# v1.1 (06.27.01)
#  MC_8 - Kitt - Fixed `Tcl error [mc:banm:dcc:banmask]: no such channel record`
#                   when adding global ban's.  (again)
#  MC_8 - Kitt - Fixed `extra characters after close-quote`.
#  MC_8 - Kitt - Added ability to notice warn, instead well as msg warn.
#  MC_8 - Asarhad - Fixed `Tcl error [mc:banm:dcc:banmask]: no such channel record`
#                   when adding global ban's.
#
# v1.0 (02.08.01)
#  MC_8 - Duckman - Inital release.
##

##
# Settings
##

# Note:
#  There is one setting you set from dcc chat with the bot using .chanset.
#   <+/->mc.banmask  Setting this to +mc.banmask on the specific channel
#                    will enable the channel to utalize this script.
#
#  Example from dcc chat with the bot:
#   .chanset #channel +mc.banmask

# What flag'd users can use the dcc commands?
set mc_banm(access) "o|o"

# What flag'd users do you want the script to ignore?  Set to
# "" to ignore no one.
set mc_banm(ig:flag) "b|"

# What do you want to call the datafile?
set mc_banm(datafile) ".banm.dat"

# If someone is found with a bad mask, what do you want the script to do?
# -3 = /NOTICE Warn
# -2 = /MSG Warn
# -1 = Kick
#  0 = Server Ban
#  1 and up is ban time in min's.
set mc_banm(pre:pun) -3

# If the above setting is -3, -2, or -1, how long (in sec.s) do you want to
# give the user before scanning them again?  Set this to 0 to disable.
set mc_banm(warn:time) 5

# If the user is still in violation after the rescan (if enabled), what do
# you want the script to do?
# -1 = Kick
#  0 = Server Ban
#  1 and up is ban time in min's.
set mc_banm(post:pun) 5

# How do you want to mask the bans?
#     Default == 5
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain (utterly useless, just returns <hostmask>)
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 
#     to 9.  But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain 
#                  with a '?' (question mark) wildcard
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
set mc_banm(banmask) 3

# [0=no/1=yes] Do you want to use regular expression matching rather than
# normal wildcarded matching?  Warning, regular expressions are advanced.
# If you don't know how to use regular expressions... do not turn this on.
# http://tcl.activestate.com/man/tcl8.3/TclCmd/re_syntax.htm#M2
# http://dev.scriptics.com/doc/howto/regexp81.html
set mc_banm(use:regexp) 0


## MC SVS (Script Version Service) v2.0 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_banm(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_banm(svs:check) 0   ;#This is at Midnight
#  set mc_banm(svs:check) 5   ;#This is at 5am
#  set mc_banm(svs:check) 13  ;#This is at 1pm
#  set mc_banm(svs:check) 23  ;#This is at 11pm
set mc_banm(svs:check) 3

# Upon finding a newer version of this script, who do you want this script
# to send a note to telling them of this newer version?
# If more than 1 user is to be notified, seperate each user with a
# ' ' (space).
set mc_banm(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_banm(svs:stableonly) 0




##
# TCL coding below, do not proceed unless
# you know what your doing.
##

set mc_banm(script)      "Ban Mask"
set mc_banm(version)     "v1.2"
set mc_banm(svs:script)  "banmask"
set mc_banm(svs:version) "001002000000"
set mc_banm(svs:server)  "mc.purehype.net"
set mc_banm(svs:port)    "81"
set mc_banm(svs:get)     "/"
set mc_banm(svs:query)   "svs=$mc_banm(svs:script)&version=$mc_banm(svs:version)"

if {$numversion < "1050500"} {
 putlog "$mc_banm(script) $mc_banm(version) by MC_8 will only work on eggdrop 1.5.5 or greater."
 putlog "$mc_banm(script) $mc_banm(version)  will not work with eggdrop $version."
 putlog "$mc_banm(script) $mc_banm(version)  not loaded."
 return 1
}

setudef flag mc.banmask

bind part - * mc:banm:part
proc mc:banm:part {nick uhost hand chan arg} {
 global botnick
 if {([string tolower $nick] == [string tolower $botnick]) &&
     (![validchan $chan])} {
  foreach line [mc:banm:list list $chan] {
#   if {[string tolower [lindex $line 0]] != [string tolower $chan]} {continue}
   mc:banm:list remove $chan [lindex $line 1]
  }
 }
}

bind nick - * mc:banm:nick
proc mc:banm:nick {nick uhost hand chan newnick} {
 global botnick
 if {[string tolower $newnick] != [string tolower $botnick]} {
  mc:banm:scan $newnick $uhost $hand $chan
 }
}

bind join - * mc:banm:join
proc mc:banm:join {nick uhost hand chan} {
 global botnick
 if {[string tolower $nick] == [string tolower $botnick]} {
  foreach user [chanlist $chan] {
   mc:banm:scan $user [getchanhost $user $chan] [nick2hand $user] $chan
  }
 } else {mc:banm:scan $nick $uhost $hand $chan}
}

proc mc:banm:scan {nick uhost hand chan {warned 0}} {
 global mc_banm botnick {botnet-nick}
 if {([string tolower $nick] == [string tolower $botnick]) ||
     (![onchan $nick $chan]) || (![isop $botnick $chan]) ||
     (![mc:banm:chanflag $chan mc.banmask]) ||
     (([matchattr $hand $mc_banm(ig:flag) $chan]) && ($mc_banm(ig:flag) != "")) ||
     ([set match [mc:banm:list match $chan $nick!$uhost]] == "")} {return 0}
 set banmask [mc:banm:masktype $nick!$uhost $mc_banm(banmask)]
 scan $uhost {%[^@]@%s} ident host
 set reason [mc:banm:replace [lindex $match 2] [list %match [lindex $match 1] %banmask $banmask %chan $chan %nick $nick %ident $ident %host $host]]
 if {!$warned} {set array "pre"} else {set array "post"}
 if {(!$warned) && ([regexp -- {^(-3|-2|-1)$} $mc_banm(pre:pun)])} {
  switch -- $mc_banm(pre:pun) {
   -3 { puthelp "NOTICE $nick :$reason"  ; set done "/notice" }
   -2 { puthelp "PRIVMSG $nick :$reason" ; set done "/msg" }
  }
  if {[info exists done]} {
   putlog "$mc_banm(script):  $nick ($uhost) \[$chan\] was warned via $done.  Match: [lindex $match 1]"
  }
  if {$mc_banm(warn:time)} {
   utimer $mc_banm(warn:time) [list mc:banm:scan $nick $uhost $hand $chan 1]
  }
 }
 if {$mc_banm(${array}:pun) >= "-1"} {
  putserv "KICK $chan $nick :$reason"
  set x "ed from $chan."
  if {$mc_banm(${array}:pun) != "-1"} {
   putserv "MODE $chan +b $banmask"
   set x "/banned from $chan."
  }
  if {$mc_banm(${array}:pun) >= "1"} {
   newchanban $chan $banmask ${botnet-nick} $reason $mc_banm(${array}:pun) none
   set x "/banned from $chan. Ban duration: [duration [expr $mc_banm(${array}:pun)*60]]."
  }; putlog "$mc_banm(script): $nick ($uhost) was kick$x  Match [lindex $match 1]"
 }; return 1
}

proc mc:banm:hasaccess {hand {chan {}}} {
 global mc_banm
 if {[validchan $chan]} {
  return [matchattr $hand $mc_banm(access) $chan]
 } else {return [matchattr $hand $mc_banm(access)]}
}

# banmask [#channel]
bind dcc - banmask mc:banm:dcc:banmask
proc mc:banm:dcc:banmask {hand idx arg} {
 global mc_banm
 set chan [lindex $arg 0]
 if {![mc:banm:hasaccess $hand $chan]} {
  putcmdlog "#$hand# Denied (no access): banmask $chan"
  putdcc $idx "$mc_banm(script):  Access denied:  '$mc_banm(access)' is required."
  return 0
 }
 if {(![validchan $chan]) && ($chan != "")} {
  putcmdlog "#$hand# Denied (invalid channel): banmask $chan"
  putdcc $idx "$mc_banm(script): Invalid channel: $chan"
  return 0
 }
 if {($chan != "") && (![mc:banm:chanflag $chan mc.banmask])} {
  putdcc $idx "$mc_banm(script) isn't enabled for $chan.  To enable type '.chanset $chan +mc.banmask'."
  return 0
 }
 if {$chan == ""} {
  putdcc $idx "Current ban'd masks list:"
  foreach ban [mc:banm:list list all] {
   putdcc $idx [format {  %-11s: %s} [lindex $ban 0] [lindex $ban 1]]
   putdcc $idx [format {  %-11s  %s} "" [lindex $ban 2]]
  }
 } else {
  putdcc $idx "Current ban'd masks list for $chan:"
  foreach ban [mc:banm:list list $chan] {
   putdcc $idx [format {  %-11s: %s} [lindex $ban 0] [lindex $ban 1]]
   putdcc $idx [format {  %-11s  %s} "" [lindex $ban 2]]
  }
 }; return 1
}

# +banmask [#channel] <nick!ident@host or *word*> [reason]
bind dcc - +banmask mc:banm:dcc:+banmask
proc mc:banm:dcc:+banmask {hand idx arg} {
 global mc_banm
 if {[validchan [lindex $arg 0]]} {set i 0} else {set i -1}
 set chan [lindex $arg $i]
 set banmask [lindex $arg [expr $i+1]]
 set reason [lrange $arg [expr $i+2] end]; unset i
 if {![mc:banm:hasaccess $hand $chan]} {
  putcmdlog "#$hand# Denied (no access): +banmask $arg"
  putdcc $idx "$mc_banm(script):  Access denied:  '$mc_banm(access)' is required."
  return 0
 }
 if {$banmask == ""} {
  putdcc $idx "$mc_banm(script):  Syntax, +banmask \[#channel\] <nick!ident@host or *word*> \[reason\]"
  return 0
 }
 if {($chan != "") && (![mc:banm:chanflag $chan mc.banmask])} {
  putdcc $idx "$mc_banm(script) isn't enabled for $chan.  To enable type '.chanset $chan +mc.banmask'."
  return 0
 }
 if {![mc:banm:list add $chan $banmask $reason]} {
  putcmdlog "#$hand# Denied (already exists): +banmask $arg"
  putdcc $idx "$mc_banm(script):  Access denied:  '$banmask' already exists."
  return 0
 }
 putcmdlog "#$hand# +banmask $arg"
 if {$chan == ""} {set x "the global"} else {set x "${chan}'s"}
 putdcc $idx "$mc_banm(script):  Added '$banmask' to $x Ban Mask list."
 return 0
}

# -banmask [#channel] <nick!ident@host or *word*>
bind dcc - -banmask mc:banm:dcc:-banmask
proc mc:banm:dcc:-banmask {hand idx arg} {
 global mc_banm
 if {[validchan [lindex $arg 0]]} {set i 0} else {set i -1}
 set chan [lindex $arg $i]
 set banmask [lindex $arg [expr $i+1]]; unset i
 if {![mc:banm:hasaccess $hand $chan]} {
  putcmdlog "#$hand# Denied (no access): -banmask $arg"
  putdcc $idx "$mc_banm(script):  Access denied:  '$mc_banm(access)' is required."
  return 0
 }
 if {$banmask == ""} {
  putdcc $idx "$mc_banm(script):  Syntax, +banmask \[#channel\] <nick!ident@host or *word*>"
  return 0
 }
 if {($chan != "") && (![mc:banm:chanflag $chan mc.banmask])} {
  putdcc $idx "$mc_banm(script) isn't enabled for $chan.  To enable type '.chanset $chan +mc.banmask'."
  return 0
 }
 if {![mc:banm:list remove $chan $banmask]} {
  putcmdlog "#$hand# Denied (doesn't exists): +banmask $arg"
  putdcc $idx "$mc_banm(script):  Access denied:  '$banmask' doesn't exists."
  return 0
 }
 putcmdlog "#$hand# -banmask $arg"
 if {$chan == ""} {set x "the global"} else {set x "${chan}'s"}
 putdcc $idx "$mc_banm(script):  Removed '$banmask' from $x Ban Mask list."
 return 0
}

proc mc:banm:list {command {chan {}} {nuhost {}} {reason {}}} {
 global mc_banm {botnet-nick}  botnick
 if {![file exists $mc_banm(datafile)]} {close [open $mc_banm(datafile) w]}
 if {![info exists mc_banm(:list:)]} {set mc_banm(:list:) ""}
 switch -- $command {
  add {
   if {[mc:banm:list exists $chan $nuhost]} {return 0}
   lappend mc_banm(:list:) [list $chan $nuhost $reason]
   mc:banm:list save -q
   foreach channel [channels] {
    mc:banm:join $botnick [getchanhost $botnick $chan] [nick2hand $botnick $chan] $chan
   }; return 1
  }
  exists {
   foreach line $mc_banm(:list:) {
    if {([string tolower $chan] == [string tolower [lindex $line 0]]) &&
        ([string tolower $nuhost] == [string tolower [lindex $line 1]])} {return 1}
   }; return 0
  }
  list {
   if {$chan == "all"} {return $mc_banm(:list:)}
   set temp ""
   foreach line $mc_banm(:list:) {
    if {[string tolower $chan] == [lindex $line 0]} {lappend temp $line}
   }; return $temp
  }
  load {
   set io [open $mc_banm(datafile) r]; set mc_banm(:list:) ""
   while {![eof $io]} {
    gets $io line
    if {([string index $line 0] == "#") || ([join $line] == "")} {continue}
    lappend mc_banm(:list:) [lrange $line 1 end]
   }; close $io
  }
  match {
   foreach line "[mc:banm:list list] [mc:banm:list list $chan]" {
    set st [lindex $line 1]
    if {(($mc_banm(use:regexp)) && ([regexp -- [string tolower $st] [string tolower $nuhost]])) ||
        ((!$mc_banm(use:regexp)) && ([string match [string tolower $st] [string tolower $nuhost]]))} {
     return $line
    }
   }; return ""
  }
  remove {
   set temp ""; set found 0
   foreach line $mc_banm(:list:) {
    if {(([string tolower $chan] == [string tolower [lindex $line 0]]) || ($chan == "")) &&
        ([string tolower $nuhost] == [string tolower [lindex $line 1]])} {set found 1} \
    else {lappend temp $line}
   }; if {!$found} {return 0}
   set mc_banm(:list:) $temp
   mc:banm:list save -q
   return 1
  }
  save {
   if {$chan != "-q"} {putloglev o * "Writing banmask file ..."}
   set io [open $mc_banm(datafile) w]
   puts $io [list #v1 $mc_banm(version) ${botnet-nick} [clock seconds]]
   foreach line [mc:banm:list list all] {puts $io "x $line"}; close $io
  }
 }
}; mc:banm:list load

bind evnt - save mc:banm:evnt ; proc mc:banm:evnt {type} {mc:banm:list save}

proc mc:banm:masktype {hostmask type} {
 set ident_max-length 9
 set host_max-length 63
 scan $hostmask {%[^!]!%[^@]@%s} nick ident host
 set maskhost 1
 if {[regexp -- {^1[0-9]$} $type]} {
  if {!([regexp -- {^([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)$} $host temp a b c d] && ($a > 0 && $a < 255 && $b < 255 && $c < 255 && $d < 255))} {
   regsub -all {[0-9]} $host "?" host
   set maskhost 0
  };set type [string index $type 1]
 }
 if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
 if {[regexp -- {^[2479]$} $type]} {set ident "*"}
 if {[regexp -- {^[1368]$} $type]} {set ident "*[string trimleft $ident ~]"}
 if {[regexp -- {^[3489]$} $type]} {if {$maskhost} {scan [maskhost $host] {%[^@]@%s} temp host}}
 if {[string length $ident] > ${ident_max-length}} {
  set ident "*[string range $ident [expr [string length $ident]-${ident_max-length}] end]"
 }
 if {[string length $host] > ${host_max-length}} {
  set host "*[string range $host [expr [string length $host]-${host_max-length}] end]"
 }; return [format "%s!%s@%s" $nick $ident $host]
}

proc mc:banm:replace {text subs} {
 if {![catch {string map -nocase $subs $text} output]} {return $output}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $text [lindex $subs [expr $i+1]] text
 }; return $text
}

proc mc:banm:chanflag {channel flag} {
 if {![validchan $channel]} {return -code error "no such channel record"}
 set list [channel info $channel]
 for {set i 0} {![regexp -- {^[0-9]*:[0-9]*$} [lindex $list $i]]} {incr i} {}
 for {} {[regexp -- {^[0-9]*:[0-9]*$} [lindex $list $i]]} {incr i} {}
 set list [lrange $list $i end]
 foreach info [string tolower $list] {
  if {[string range $info 1 end] != [string tolower $flag]} {continue}
  if {[string index $info 0] == "-"} {
   return 0
  } elseif {[string index $info 0] == "+"} {return 1} else {return 2}
 };return -1
}

## SVS v2.0
if {(![info exists mc_banm(svs:enabled)]) ||
    (![regexp -- {^(0|1)$} $mc_banm(svs:enabled)])} {set mc_banm(svs:enabled) 0}
if {(![info exists mc_banm(svs:check)]) ||
    ([regexp -- {[^0-9]} $mc_banm(svs:check)])} {set mc_banm(svs:check) 0}
if {![info exists mc_banm(svs:notify)]} {set mc_banm(svs:notify) $owner}
if {(![info exists mc_banm(svs:stableonly)]) ||
    (![regexp -- {^(0|1)$} $mc_banm(svs:stableonly)])} {set mc_banm(svs:stableonly) 0}
foreach bind [binds mc:banm:svs:time] {
 unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]
}
foreach command [info commands mc:banm:svs:time] {rename $command ""}
if {$mc_banm(svs:enabled)} {
 if {($mc_banm(svs:check) > "23") || ($mc_banm(svs:check) < "0")} {set mc_banm(svs:check) 00}
 if {[string length $mc_banm(svs:check)] == "1"} {set mc_banm(svs:check) 0$mc_banm(svs:check)}
 bind time - "00 $mc_banm(svs:check) *" mc:banm:svs:time
 proc mc:banm:svs:time {{args ""}} {
  global mc_banm
  if {[catch {socket -async $mc_banm(svs:server) $mc_banm(svs:port)} sid]} {;\
   putlog "SVS Error\[$mc_banm(svs:script)/$mc_banm(svs:version)\]:  $sid"
   return 1
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:banm:svs:interface $sid timeout"]
  fileevent $sid readable "mc:banm:svs:interface $sid $tout"
  puts $sid "GET $mc_banm(svs:get)?$mc_banm(svs:query) HTTP/1.0\
           \nHost: $mc_banm(svs:server)\n"
  flush $sid
 }
}
proc mc:banm:svs:interface {sid tout} {
 global mc_banm
 if {$tout == "timeout"} {
  putlog "SVS Warning\[$mc_banm(svs:script)/$mc_banm(svs:version)\]:  SVS Server timed out."
  close $sid
  return 0
 }; after cancel $tout
 set temp 0
 while {![eof $sid]} {
  gets $sid get
  if {$temp < "2"} {
   if {$get == ""} {incr temp; if {$temp == "1"} {set temp 2}}
   continue
  }; if {$get == ""} {continue}
  switch -- [lindex $get 0] {
   003 {
    set reply [lrange $get 1 end]
    if {[lindex $reply 0] != $mc_banm(svs:script)} {
     putlog "SVS Error\[$mc_banm(svs:script)/$mc_banm(svs:version)\]:  SVS Server sent wrong info, got [lindex $reply 0]"
     break   
    }
    if {$mc_banm(svs:stableonly)} {
     set temp [string range $mc_banm(svs:version) 0 8]999
    } else {set temp [string range $mc_banm(svs:version) 0 11]}
    if {[lindex $reply 1] > $temp} {
     set note [lindex $reply 5]
     regsub -- %0 $note [lindex $reply 0] note
     regsub -- %1 $note [lindex $reply 1] note
     regsub -- %2 $note [lindex $reply 2] note
     regsub -- %3 $note [lindex $reply 3] note
     regsub -- %4 $note [lindex $reply 4] note
     regsub -- %version $note $mc_banm(version) note
     foreach to [split $mc_banm(svs:notify) ",; "] {
      if {$to == ""} {continue}
      regsub -- %nick $note $to outnote
      if {[string match *$outnote* [set unotes [notes $to -[notes $to]]]]} {
       set temp 0
       foreach unote $unotes {
        if {$outnote == [lindex $unote 2]} {set temp 1; break}
       }; if {$temp} {continue}
      }
      switch -- [sendnote SVS $to $outnote] {
       0 {
        if {![validuser $notify]} {set x "invalid user"} else {set x "unknown error"}
        putlog "SVS Error\[$mc_banm(svs:script)/$mc_banm(svs:version)\]:  Trying to send note to $to, $x."
       }
       3 {putlog "SVS Error\[$mc_banm(svs:script)/$mc_banm(svs:version)\]:  Trying to send note to $to, notebox too full!"}
      }
     }
    }
   }
  }
 }; close $sid
}
## ^

putlog "$mc_banm(script) $mc_banm(version) by MC_8 loaded."
