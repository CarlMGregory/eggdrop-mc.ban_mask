##
# Ban Mask v1.4
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.13 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug?  http://mc.purehype.net/bugzilla/
##

##
# Description
##
# This script will ban people matching the specific ban-mask.  Sure, you can
# just use +ban to do such things, but the advantage with doing it this way is;
#   1) Can setup a ban-mask via this script, but have it mask the actual ban
#      differently, as to not reveal how the ban is masked, therefor making it
#      so it's harder to do a ban evasion.
#   2) You can do regular expression type ban masking, as well as the
#      traditional glob style.
##

##
# Commands (dcc)
##
# banmask [channel|'all']
#   This will show you a list of current banned masks.
#
# +banmask [channel] <nick!ident@host | *word*> [reason]
#   This will add a new mask ban.
#
# -banmask [channel] <nick!ident@host | *word*>
#   This will remove a mask ban.
#
# If you do not specify [channel] it will be considered as global.
# <nick!ident@host | *word*> can contain wildcards.
#
# chanset [channel] <+/->mc.banmask
#   Setting this will enable, +, or disable, -, the script for the given
#   channel.
##

##
# Configuration
##
#

# What flagged users can use the dcc commands?
set mc_banm(:config:access) "o|o"

# What flagged users do you want the script to ignore?  Set to
# "" to ignore no one.
set mc_banm(:config:ig:flag) "b|"

# What do you want to call the datafile?
set mc_banm(:config:datafile) ".banm.dat"

# If someone is found with a bad mask, what do you want the script to do?
# -3 = /NOTICE Warn
# -2 = /MSG Warn
# -1 = Kick
#  0 = Server Ban
#  1 and up is ban time in min's.
set mc_banm(:config:pre:pun) -3

# If the above setting is -3, -2, or -1, how long (in sec.s) do you want to
# give the user before scanning them again?  Set this to 0 to disable.
set mc_banm(:config:warn:time) 60

# If the user is still in violation after the rescan (if enabled), what do
# you want the script to do?
# -1 = Kick
#  0 = Server Ban
#  1 and up is ban time in min's.
set mc_banm(:config:post:pun) 5

# How do you want to mask the bans?
#         0 - *!user@host.domain
#         1 - *!*user@host.domain
#         2 - *!*@host.domain
#         3 - *!*user@*.domain
#         4 - *!*@*.domain
#         5 - nick!user@host.domain
#         6 - nick!*user@host.domain
#         7 - nick!*@host.domain
#         8 - nick!*user@*.domain
#         9 - nick!*@*.domain
#       You can also specify a type of 10-19 which corresponds to types 0-9,
#       using this sub rule;  If host.domain is a(n)-
#         name - Instead of using a * wildcard to replace portions of the
#                host.domain, it replaces the numbers in the host.domain with a
#                '?' (question mark) wildcard.
#         ip   - It will mask as normal, with no '?' (question mark)
set mc_banm(:config:banmask) 3

# [0=no/1=yes] Do you want to use regular expression matching rather than
# normal wild carded matching?  Warning, regular expressions are advanced.
# If you don't know how to use regular expressions... do not turn this on.
# http://tcl.activestate.com/man/tcl8.3/TclCmd/re_syntax.htm#M2
# http://dev.scriptics.com/doc/howto/regexp81.html
set mc_banm(:config:use:regexp) 0


## SVS Client (Script Version Service) v4.0.1 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?
set mc_banm(:config:svs:enable) 1


#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

#Script:mc_banm

catch {unset temp}
set mc_banm(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_banm :config:*] {
  lappend mc_banm(info:vars) [list $temp(name) $temp(value)]
}
set mc_banm(info:loc) [info script]
array set mc_banm [list \
  script                 "Ban Mask" \
  version                "v1.4" \
  svs:script             "banmask" \
  svs:version            "001004000000" \
  svs:client_version     "v4.0.1" \
  svs:client_svs_version "004000001000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "81" \
  svs:get                "/index.tcl"]
set mc_banm(svs:query)    "svs=$mc_banm(svs:script)&"
append mc_banm(svs:query) "version=$mc_banm(svs:version)&"
append mc_banm(svs:query) "svs_version=$mc_banm(svs:client_svs_version)"

if {![info exists numversion] || ($numversion < "1061300")} {
  set temp(tag) "$mc_banm(script) $mc_banm(version)"
 putloglev o * "$temp(tag) by MC_8 will only work on eggdrop 1.6.13 or greater."
 putloglev o * "$temp(tag)  will not work with eggdrop $version."
 putloglev o * "$temp(tag)  not loaded."
  return 1
}

# Error system, v3.0
proc mc:banm:error {command error arg} {
  global mc_banm version lastbind errorInfo
  putlog "Error in script $mc_banm(script) $mc_banm(version)."
  putlog "    Error System: v3.0"
  putlog "       Last Bind: [expr {[info exists lastbind]?$lastbind:"-NULL-"}]"
  putlog "         Command: $command"
  putlog "       Arguments: $arg"
  putlog "       Error Msg: $error"
  putlog "    Egg. Version: [expr {[info exists version]?$version:"-NULL-"}]"
  putlog "     TCL Version: [info tclversion]"
  putlog "  TCL Patchlevel: [info patchlevel]"
  putlog "*** Please submit this bug so MC_8 can fix it.  Visit"
  putlog "*** http://mc.purehype.net/bugzilla/ to properly report the bug."
  putlog \
    "*** Please include ALL info. in the bug report, including the next(s)."
  error $errorInfo
}

proc mc:banm:errchk {command arg} {
  if {![catch {eval $command $arg} return]} {return $return}
  mc:banm:error $command $return $arg
  return 0
}
# ^

setudef flag mc.banmask

# banmask [channel|'all']
bind dcc - banmask mc:banm:dcc:banmask
proc mc:banm:dcc:banmask {handle index argument} {
  return [mc:banm:errchk mc:banm:dcc:banmask_ [list $handle $index $argument]]
}
proc mc:banm:dcc:banmask_ {handle index argument} {
  global mc_banm

  set channel [lindex $argument 0]

  set temp(channel) [expr {($channel == "all")?"":$channel}]
  if {![mc:banm:list has_dcc_access [list $handle $temp(channel)]]} {
    putloglev c * "#$handle# Denied (no access); banmask $channel"
    putdcc $index \
      "$mc_banm(script): Access denied; '$mc_banm(:config:access)' is required."
    return 0
  }

  if {$channel == "all"} {
    set temp(1) ""
    set temp(2) all
  } elseif {$channel != ""} {
    if {![validchan $channel]} {
      putloglev c * "#$handle# Denied (invalid channel); banmask $channel"
      putdcc $index "$mc_banm(script): Invalid channel; $channel"
      return 0
    }
    if {![mc:banm:chanflag $channel mc.banmask]} {
      set temp() [lindex [binds *dcc:chanset] 0]
      if {($temp() != "") &&
          ([matchattr $handle [lindex $temp() 1] $channel])} {
        set temp(message) \
          "To enable, type '.[lindex $temp() 2] $channel +mc.banmask'."
      } else {set temp(message) ""}
      putdcc $index \
        "$mc_banm(script) isn't enabled for $channel. $temp(message)"
      return 0
    }
    set temp(1) "$channel "
    set temp(2) $channel
  } else {
    set temp(1) "global "
    set temp(2) ""
  }

  putdcc $index "Current $temp(1)banned masks list:"
  foreach ban [mc:banm:list list $temp(2)] {
    set temp(channel) [lindex $ban 0]
    set temp(channel) [expr {($temp(channel) == "")?"global":$temp(channel)}]
    putdcc $index \
      [format {  %-11s: %s (%s)} $temp(channel) [lindex $ban 1] [lindex $ban 2]]
  }

  return 1
}

# +banmask [channel] <nick!ident@host | *word*> [reason]
bind dcc - +banmask mc:banm:dcc:+banmask
proc mc:banm:dcc:+banmask {handle index argument} {
  return [mc:banm:errchk mc:banm:dcc:+banmask_ [list $handle $index $argument]]
}
proc mc:banm:dcc:+banmask_ {handle index argument} {
  global mc_banm

  set channel [lindex $argument 0]
  set i [expr {[validchan $channel]?"0":"-1"}]
  set channel [lindex $argument $i]
  set banmask [lindex $argument [incr i]]
  set reason  [join [lrange $argument [incr i] end]]
  unset i

  if {![mc:banm:list has_dcc_access [list $handle $channel]]} {
    putloglev c * "#$handle# Denied (no access); +banmask $argument"
    putdcc $index \
      "$mc_banm(script): Access denied: '$mc_banm(:config:access)' is required."
    return 0
  }

  if {$banmask == ""} {
    putdcc $index \
      "Usage: +banmask \[channel\] <nick!ident@host | *word*> \[reason\]"
    return 0
  }

  if {$channel != ""} {
    if {![validchan $channel]} {
      putloglev c * "#$handle# Denied (invalid channel); banmask $channel"
      putdcc $index "$mc_banm(script): Invalid channel; $channel"
      return 0
    }
    if {![mc:banm:chanflag $channel mc.banmask]} {
      set temp() [lindex [binds *dcc:chanset] 0]
      if {($temp() != "") &&
          ([matchattr $handle [lindex $temp() 1] $channel])} {
        set temp(message) \
          "To enable, type '.[lindex $temp() 2] $channel +mc.banmask'."
      } else {set temp(message) ""}
      putdcc $index \
        "$mc_banm(script) isn't enabled for $channel. $temp(message)"
      return 0
    }
    set temp(x) "$channel's"
  } else {
    set temp(x) "the global"
  }

  if {![mc:banm:list add [list $channel $banmask "$handle: $reason"]]} {
    putloglev c * "#$handle# Denied (already exists): +banmask $argument"
    putdcc $index "$mc_banm(script): Access denied; '$banmask' already exists."
    return 0
  }

  putdcc $index "$mc_banm(script): Added '$banmask' to $temp(x) ban mask list."
  return 1
}

# -banmask [channel] <nick!ident@host | *word*>
bind dcc - -banmask mc:banm:dcc:-banmask
proc mc:banm:dcc:-banmask {handle index argument} {
  return [mc:banm:errchk mc:banm:dcc:-banmask_ [list $handle $index $argument]]
}
proc mc:banm:dcc:-banmask_ {handle index argument} {
  global mc_banm

  set channel [lindex $argument 0]
  set i [expr {[validchan $channel]?"0":"-1"}]
  set channel [lindex $argument $i]
  set banmask [lindex $argument [incr i]]
  unset i

  if {![mc:banm:list has_dcc_access [list $handle $channel]]} {
    putloglev c * "#$handle# Denied (no access): -banmask $argument"
    putdcc $index \
      "$mc_banm(script): Access denied; '$mc_banm(:config:access)' is required."
    return 0
  }

  if {$banmask == ""} {
    putdcc $index "Usage: +banmask \[channel\] <nick!ident@host | *word*>"
    return 0
  }

  if {$channel != ""} {
    if {![validchan $channel]} {
      putloglev c * "#$handle# Denied (invalid channel); banmask $channel"
      putdcc $index "$mc_banm(script): Invalid channel; $channel"
      return 0
    }
    if {![mc:banm:chanflag $channel mc.banmask]} {
      set temp() [lindex [binds *dcc:chanset] 0]
      if {($temp() != "") &&
          ([matchattr $handle [lindex $temp() 1] $channel])} {
        set temp(message) \
          "To enable, type '.[lindex $temp() 2] $channel +mc.banmask'."
      } else {set temp(message) ""}
      putdcc $index \
        "$mc_banm(script) isn't enabled for $channel. $temp(message)"
      return 0
    }
    set temp(x) "$channel's"
  } else {
    set temp(x) "the global"
  }

  if {![mc:banm:list remove [list $channel $banmask]]} {
    putloglev c * "#$handle# Denied (doesn't exists); +banmask $argument"
    putdcc $index "$mc_banm(script): Access denied; '$banmask' doesn't exists."
    return 0
  }

  putdcc $index \
    "$mc_banm(script): Removed '$banmask' from $temp(x) ban mask list."
  return 1
}

bind part - * mc:banm:part
proc mc:banm:part {nick uhost handle channel argument} {
  return \
   [mc:banm:errchk mc:banm:part_ [list $nick $uhost $handle $channel $argument]]
}
proc mc:banm:part_ {nick uhost handle channel argument} {
  if {([isbotnick $nick]) && (![validchan $channel])} {
    foreach line [mc:banm:list list $channel] {
      mc:banm:list remove [list $channel [lindex $line 1]]
    }
  }
}

bind nick - * mc:banm:nick
proc mc:banm:nick {nick uhost handle channel newnick} {
  return \
    [mc:banm:errchk mc:banm:nick_ [list $nick $uhost $handle $channel $newnick]]
}
proc mc:banm:nick_ {nick uhost handle channel newnick} {
  if {![isbotnick $newnick] && [validchan $channel]} {
    mc:banm:list scan [list $newnick $uhost $handle $channel]
  }
}

bind join - * mc:banm:join
proc mc:banm:join {nick uhost handle channel} {
  return [mc:banm:errchk mc:banm:join_ [list $nick $uhost $handle $channel]]
}
proc mc:banm:join_ {nick uhost handle channel} {
  if {[isbotnick $nick]} {
    foreach user [chanlist $channel] {
      mc:banm:list scan [list $user [getchanhost $user $channel] \
        [nick2hand $user] $channel]
    }
  } else {
    mc:banm:list scan [list $nick $uhost $handle $channel]
  }
}

bind evnt - save mc:banm:evnt:save
proc mc:banm:evnt:save {type} {
  return [mc:banm:errchk mc:banm:evnt:save_ [list $type]]
}
proc mc:banm:evnt:save_ {type} {mc:banm:list save}

proc mc:banm:list {command {argument ""}} {
  return [mc:banm:errchk mc:banm:list_ [list $command $argument]]
}
proc mc:banm:list_ {command {argument ""}} {
  global mc_banm botnet-nick botnick

  if {![file exists $mc_banm(:config:datafile)]} {close [open $mc_banm(:config:datafile) w]}
  if {![info exists mc_banm(:list:)]} {set mc_banm(:list:) ""}

  switch -- $command {
    "add" {
      mc:banm:unlist $argument channel banmask reason

      if {[mc:banm:list exists [list $channel $banmask]]} {return 0}

      lappend mc_banm(:list:) [list $channel $banmask $reason]

      mc:banm:list save -q

      foreach channel [channels] {
        mc:banm:join $botnick [getchanhost $botnick] ${botnet-nick} $channel
      }

      return 1
    }
    "exists" {
      mc:banm:unlist $argument channel banmask

      foreach line $mc_banm(:list:) {
        if {([string tolower $channel] == [string tolower [lindex $line 0]]) &&
            ([string tolower $banmask] == [string tolower [lindex $line 1]])} {
          return 1
        }
      }; return 0
    }
    "has_dcc_access" {
      mc:banm:unlist $argument handle {channel ""}

      return [expr {[validchan $channel]?
                    [matchattr $handle $mc_banm(:config:access) $channel]:
                    [matchattr $handle $mc_banm(:config:access)]}]
    }
    "list" {
      # global listing;  list
      # channel listing; list $channel
      # all listing;     list all
      set channel $argument

      if {$channel == "all"} {return $mc_banm(:list:)}

      set temp() ""
      foreach line $mc_banm(:list:) {
        if {[string tolower $channel] == [lindex $line 0]} {
          lappend temp() $line
        }
      }; return $temp()
    }
    "load" {
      set mc_banm(:list:) ""
      set io [open $mc_banm(:config:datafile) r]
      while {![eof $io]} {
        gets $io line

        set line [split $line]
        if {[lindex $line 0] != "x"} {continue}
        set line [join [lrange $line 1 end]]

        if {([string trim $line " "] == "") ||
            ([catch {llength $line} output]) ||
            ($output != "3") ||
            (([set channel [lindex $line 0]] != "") &&
             ((![validchan $channel]) ||
              (![mc:banm:chanflag $channel mc.banmask])))} {continue}

        lappend mc_banm(:list:) $line
      }; close $io
    }
    "match" {
      mc:banm:unlist $argument channel nuhost
      set nuhost [string tolower $nuhost]

      foreach line "[mc:banm:list list] [mc:banm:list list $channel]" {
        set banmask [lindex $line 1]
        if {(($mc_banm(:config:use:regexp)) &&
             ([regexp -nocase -- $banmask $nuhost])) ||
            ((!$mc_banm(:config:use:regexp)) &&
             ([string match [string tolower $banmask] $nuhost]))} {
          return $line
        }
      }; return ""
    }
    "remove" {
      mc:banm:unlist $argument channel banmask
      set channel [string tolower $channel]
      set banmask [string tolower $banmask]

      set temp(list) ""
      set temp(found) 0
      foreach line $mc_banm(:list:) {
        if {($channel == [string tolower [lindex $line 0]]) &&
            ($banmask == [string tolower [lindex $line 1]])} {
          incr temp(found)
        } else {
          lappend temp(list) $line
        }
      }
      if {!$temp(found)} {return 0}

      set mc_banm(:list:) $temp(list)

      mc:banm:list save -q
      return 1
    }
    "save" {
      if {$argument != "-q"} {
        putloglev o * "Saving $mc_banm(script) file ..."
      }

      set io [open $mc_banm(:config:datafile) w]
      puts $io [list #v1 $mc_banm(version) ${botnet-nick} [clock seconds]]
      foreach line [mc:banm:list list all] {
        puts $io "x $line"
      }
      close $io
    }
    "scan" {
      mc:banm:unlist $argument nick uhost handle channel {warned 0}
      set nuhost $nick!$uhost

      if {([isbotnick $nick]) || (![botisop $channel]) ||
          (![onchan $nick $channel]) ||
          (![mc:banm:chanflag $channel mc.banmask]) ||
          (([matchattr $handle $mc_banm(:config:ig:flag) $channel]) &&
           ($mc_banm(:config:ig:flag) != "")) ||
          ([set match [mc:banm:list match [list $channel $nuhost]]] == "")} {
        return 0
      }

      set banmask [mc:banm:maskhostbytype $nuhost $mc_banm(:config:banmask)]

      set temp() [split $uhost @]
      set ident [join [lrange $temp() 0 [expr [llength $temp()]-2]] @]
      set host [lindex $temp() end]

      set reason [mc:banm:replace -- [lindex $match 2] [list \
        %match   [lindex $match 1] \
        %banmask $banmask \
        %chan    $channel \
        %nick    $nick \
        %ident   $ident \
        %host    $host]]

      if {(!$warned) && ([regexp -- {^(-3|-2|-1)$} $mc_banm(:config:pre:pun)])} {
        switch -- $mc_banm(:config:pre:pun) {
          "-3" {puthelp "NOTICE $nick :$reason" ; set done "/notice"}
          "-2" {puthelp "PRIVMSG $nick :$reason"; set done "/msg"}
          default {set done ""}
        }
        if {$done != ""} {
          set temp() "$nick ($uhost) \[$channel\] was warned via"
          putlog "$mc_banm(script): $temp() $done.  Match: [lindex $match 1]"
        }
        if {$mc_banm(:config:warn:time)} {
          utimer $mc_banm(:config:warn:time) \
            [list mc:banm:list scan [list $nick $uhost $handle $channel 1]]
        }
      }

      set array [expr {$warned?"post":"pre"}]

      if {$mc_banm(${array}:pun) >= "-1"} {
        set x "ed from $channel."
        if {$mc_banm(${array}:pun) != "-1"} {
          putserv "MODE $channel +b $banmask"
          set x "/banned from $channel."
        }
        if {$mc_banm(${array}:pun) >= "1"} {
          newchanban $channel $banmask ${botnet-nick} $reason \
            $mc_banm(${array}:pun) none
          set temp() [duration [expr $mc_banm(${array}:pun)*60]]
          set x "/banned from $channel. Ban duration: $temp()."
        }
        putserv "KICK $channel $nick :$reason"
        putlog \
          "$mc_banm(script): $nick ($uhost) was kick$x  Match [lindex $match 1]"
      }; return 1
    }
  }
}


## More Tools quick procs.
## -- http://mc.purehype.net/script_info.tcl?script=moretools

# badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:banm:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
wrong # args: should be "mc:banm:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use 2list here, don't want to evoke a 'too many nested
  # calls to Tcl_EvalObj' error since '2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) || (($llength != "end") &&
      ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:banm:unlist {{args ""}} {
  mc:banm:badargs $args 1 end "argsList ?varName varName ...?"
  set argList [lindex $args 0]
  set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
  set argNames [lrange $args 1 end]
  if {![llength $argNames]} {
    return [expr {(![catch {llength $argList}])?
      [join $argList]:$argList}]
  }
  for {set index 0} {$index < [llength $argNames]} {incr index 1} {
    set argName     [lindex $argNames $index]
    set argListItem [lindex $argList  $index]

    set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
    set setTo   [lindex $argName_ 1]
    set argName [lindex $argName_ 0]

    if {$argName == ""} {continue}

    upvar 1 $argName var

    if {[expr $index+1] > [llength $argList]} {
      if {[llength $argName_] == "2"} {set var $setTo}
    } else {
      if {$argName == "args"} {
        set var [lrange $argList $index end]
        incr index [expr [llength $var]-1]
      } else {set var $argListItem}
    }
  }; return $index
}

# 2list <text>
#     version:
#       v1.0
proc mc:banm:2list {{args ""}} {
  mc:banm:badargs $args 1 1 "text"
  mc:banm:unlist $args text

  return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.1
proc mc:banm:maskhostbytype {{args ""}} {
  mc:banm:badargs $args 1 2 "nick!ident@host.domain ?type?"
  mc:banm:unlist $args nuhost type

  set type [expr {($type == "")?5:$type}]
  if {![regexp -- {^1?[0-9]$} $type]} {
    set valid "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
    error "bad type \"$type\": must be [join $valid ", "]"
  }

  # Define the maximum length the ircd allows for an ident.  Standard is 9,
  # however I made it to a variable incase someone wants to change it up.
  set ident_max-length 9

  # Define the maximum length the ircd allows for a hostname/ ip.  Standard is
  # 63, however I made it to a variable incase someone wants to change it up.
  set host_max-length 63

  if {![regexp -- {^(.*[^!])!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
    error "invalid nick!ident@host.domain: $nuhost"
  }

  set maskhost 1
  if {[string length $type] == "2"} {
    # Type must be 10-19.
    if {[info tclversion] < "8.1"} {
      set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
    } else {
      set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
    }
    set re_syntax ^$re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2\$

    if {![regexp -- $re_syntax $host]} {
      regsub -all -- {[0-9]} $host ? host
      set maskhost 0
    }; set type [string index $type 1]
  }

  # Previous version used regexp instead of these string matches.  String match
  # in this case is ~3 microseconds faster.
  if {[string match {[0-4]} $type]} {set nick *}
  if {[string match {[2479]} $type]} {set ident *}
  if {[string match {[1368]} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
  if {[string match {[3489]} $type] && $maskhost} {
    set host [lindex [split [maskhost $host] @] end]
  }

  if {[set length [string length $ident]] > ${ident_max-length}} {
    set ident *[string range $ident [expr $length-${ident_max-length}] end]
  }
  if {[set length [string length $host]] > ${host_max-length}} {
    set host *[string range $host [expr $length-${host_max-length}] end]
  }

  return $nick!$ident@$host
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:banm:replace {{args ""}} {
  mc:banm:badargs $args 2 4 "?switches? text substitutions"
  set switches ""
  for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
    if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
      error "bad switch \"$arg\": must be -nocase, or --"
    }
    if {$switch == "-"} {
      incr i
      break
    }; lappend switches $switch
  }
  set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
  set text [lindex $args $i]
  set substitutions [lindex $args [expr $i+1]]
  mc:banm:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

  # Check to see if $substitutions is in list format, if not make it so.
  set substitutions [mc:banm:2list $substitutions]

  if {[info tclversion] >= "8.1"} {
    return [expr {($nocase)?
      [string map -nocase $substitutions $text]:
      [string map $substitutions $text]}]
  }

  set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
  foreach {a b} $substitutions {
    regsub -all -- $re_syntax $a {\\\1} a
    if {$nocase} {regsub -all -nocase -- $a $text $b text} \
    else {regsub -all -- $a $text $b text}
  }; return $text
}

# chanflag <channel> <flag>
#     version:
#       v3.1
proc mc:banm:chanflag {{args ""}} {
  mc:banm:badargs $args 2 2 "channel flag"
  mc:banm:unlist $args channel flag

  if {![validchan $channel]} {error "no such channel record"}

  # Try the 'channel' commands' 'get' option first, it's faster since it is
  # written in C by the eggdrop development team.
  if {![catch {channel get $channel $flag} output]} {return $output}

  set temp(chaninfo) [string tolower [channel info $channel]]
  if {[lsearch -exact $temp(chaninfo) +[string tolower $flag]] >= "0"} {
    return 1
  }; return 0
}

## End of More Tools quick procs.


mc:banm:list load

if {![info exists mc_banm(:config:svs:enable)] ||
    ![string match {[01]} $mc_banm(:config:svs:enable)]} {
  set mc_banm(:config:svs:enable) 0
}

bind time - "00 00 *" mc:banm:do_svs
proc mc:banm:do_svs {{args ""}} {
  global mc_banm
  set query $mc_banm(svs:query)
  if {$args == ""} {append query "&log=0"}
  set index [connect $mc_banm(svs:server) $mc_banm(svs:port)]
  putdcc $index "GET $mc_banm(svs:get)?$query HTTP/1.0\n"
  putdcc $index "Host: $mc_banm(svs:server):$mc_banm(svs:port)\n\n"
  control $index mc:banm:svs_talk
}

proc mc:banm:svs_talk {index text} {
  global mc_banm
  set header [list svs header $index]
  set memory [list svs memory $index]
  if {$text == ""} {
    catch {unset mc_banm($header)}
    catch {unset mc_banm($memory)}
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exist mc_banm($header)]} {
    if {$rfc == "002"} {
      # Done with http header and useless information.
      if {!$mc_banm(:config:svs:enable)} {
        catch {unset mc_banm($header)}
        catch {unset mc_banm($memory)}
        return 1
      }
      set mc_banm($header) 1
    }
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_banm(svs:script)} {
        set temp(1) "wanted $mc_banm(svs:script), got $temp(text:0)"
        putloglev d * "$mc_banm(script): SVS Error: $temp(1)"
        catch {unset mc_banm($header)}
        catch {unset mc_banm($memory)}
        return 1
      }
      return 0
    }

    011 {return 0}
    012 {return 0}
    013 {return 0}
    014 {return 0}
    017 {return 0}

    004 {
      if {[info exists mc_banm($memory)]} {
        set file $mc_banm(info:loc)~new
        set temp(vars) $mc_banm(info:vars)
        set io [open $file w]
        for {set i 0} {$i <= [llength $mc_banm($memory)]} {incr i} {
          set line [lindex $mc_banm($memory) $i]
          set regexp {^[; ]*set mc_banm\((:config:[^)]*)\) *(.?)}
          if {[regexp -- $regexp $line -> name type]} {
            set continue 0
            foreach item $temp(vars) {
              set item_name [lindex $item 0]
              set item_value [lindex $item 1]
              if {$name != $item_name} {continue}
              set index [lsearch -exact $temp(vars) $item]
              set temp(vars) [lreplace $temp(vars) $index $index]
              puts $io [list set mc_banm($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:;* *(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_banm($memory) $i]
                }
                puts $io ""
              } elseif {$type == "\""} {
                regsub -- {"} $line "" line
                while {1} {
                  if {[regexp -- {[^\\]"(?:;* *(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:;* *(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_banm($memory) $i]
                }
                puts $io ""
              }
              set continue 1
              break
            }
            if {$continue} {continue}
          }
          puts $io $line
        }
        close $io
        set file $mc_banm(info:loc)
        putloglev o * "$mc_banm(script): Auto update testing new script..."
        if {[catch {uplevel "source $file~new"} error]} {
          file delete -force -- $file~new
          putloglev o * "$mc_banm(script): Auto update failed: $error"
          putloglev o * "$mc_banm(script): Auto update loading previous script."
          uplevel "source $file"
        } else {
          file rename -force -- $file~new $file
          putloglev o * "$mc_banm(script): Auto update test good, reloading."
          uplevel "source $file"
        }
      }

      catch {unset mc_banm($header)}
      catch {unset mc_banm($memory)}
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_banm(script): SVS is being redirected to $temp(cache)."
      utimer 5 [list mc:banm:do_svs_ $temp(host) $temp(port) $temp(get)]
      catch {unset mc_banm($header)}
      catch {unset mc_banm($memory)}
      return 1
    }

    300 {
      lappend mc_banm($memory) $text
      return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) ""}
set index [lsearch -exact $mc_loaded(scripts) mc_banm]
lreplace mc_loaded(scripts) $index $index mc_banm

putlog "$mc_banm(script) $mc_banm(version) by MC_8 loaded."


##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v1.4 (07.17.03)
#  MC_8 - - Upgraded SVS client.  v3.1.1 -> v4.0.1
#  MC_8 - - Fixed 'illegal channel: *'.
#           Bugzilla Bug 310
#
# v1.3 (10.23.01)
#  MC_8 -      - Added ECS, Error Catching System.  none -> v3.0
#  MC_8 -      - Added `2list` tcl command.  none -> v1.0
#  MC_8 -      - Added `badargs` tcl command.  none -> v1.0
#  MC_8 -      - Upgraded `chanflag` tcl command.  old -> v3.1
#  MC_8 -      - Upgraded `replace` tcl command.  old -> v1.3
#  MC_8 -      - Upgraded `masktype` tcl command, changed name to
#                `maskhostbytype`.  old -> v2.1
#  MC_8 -      - Added `unlist` tcl command.  none -> v1.0
#  MC_8 -      - Moved `scan` and `hasaccess` into the list procedure.
#  MC_8 -      - Rewrote all procs to be more efficient.
#  MC_8 -      - Upgraded SVS Client.  v2.0 -> v3.1.1
#  MC_8 - kuto - Fixed, 'illegal channel:' when adding globally.  [bug: 104]
#
# v1.2 (11.14.01)
#  MC_8 - - Upgraded SVS v1.2 to v2.0.
#  MC_8 - - Changed 'warn:time' from min.s to sec.s.
#  MC_8 - - Removed 'warn:msg', will use reason supplied when added.
#  MC_8 - - Removed gethost and filt procs, not used.
#  MC_8 - - Added newer version of the replace proc.
#  MC_8 - - Rewrote how it stores and calls on the database information, will
#           now all go threw 1 procedure (mc:banm:list).
#  MC_8 - - Added newer version of the masktype (host masking) proc.
#  MC_8 - - Added 'access'.
#  MC_8 - - Removed chanflagison, replace with chanflag proc.
#  MC_8 - - Changed the commands up a bit.  To add and remove it's '+/-banmask'
#           rather than 'banmask add'.
#
# v1.1 (06.27.01)
#  MC_8 - Kitt      - Fixed `extra characters after close-quote`.
#  MC_8 - Kitt      - Added ability to notice warn, instead well as msg warn.
#  MC_8 - Asarhad / - Fixed `Tcl error [mc:banm:dcc:banmask]: no such channel
#         Kitt        record` when adding global ban's.
#
# v1.0 (02.08.01)
#  MC_8 - Duckman - Inital release.
##
