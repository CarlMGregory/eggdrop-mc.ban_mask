##
# Ban Mask v1.4.2
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.13 or greater.
#  This script will only run with TCL 8.4 or greater
#    (due to a bug in prev. tcl versions).
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug or script not working correctly?
#   http://mc.purehype.net/bugzilla/
# Have a question?
#   http://forum.purehype.net/viewforum.php?f=5
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
# <nick!ident@host | *word*> can contain wild cards.
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

# If the user is still in violation after the re scan (if enabled), what do
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

## SVS Client (Script Version Service) v4.1.2 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?  If you chose to disable
# auto updating, it will not automatically update the script upon finding a
# newer version.
set mc_banm(:config:svs:enable) 1

#
##

##
# Done with configurations, do not edit past here unless you know TCL.
##
#

## SVS insert (pre code)
#Script:mc_banm
catch {unset temp}

foreach temp(bind) [binds mc:banm:*] {
  foreach {temp(1) temp(2) temp(3) temp(4) temp(5)} $temp(bind) break
  catch {unbind $temp(1) $temp(2) $temp(3) $temp(5)}
}

set mc_banm(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_banm :config:*] {
  lappend mc_banm(info:vars) [list $temp(name) $temp(value)]
}
set mc_banm(info:loc) [info script]
array set mc_banm [list \
  script                 "Ban Mask" \
  version                "v1.4.2" \
  svs:script             "banmask" \
  svs:version            "001004002000" \
  svs:client_version     "v4.1.2" \
  svs:client_svs_version "004001002000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "80" \
  svs:get                "/index.tcl"]
set mc_banm(svs:query)    "svs=$mc_banm(svs:script)&"
append mc_banm(svs:query) "version=$mc_banm(svs:version)&"
append mc_banm(svs:query) \
  "svs_version=$mc_banm(svs:client_svs_version)"

if {![info exists numversion] || 
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_banm(script) $mc_banm(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag) will not work with eggdrop $version."
  putloglev o * "$temp(tag) not loaded."
  uplevel #0 {
    if {[info exists temp] && ![array exists temp]} {unset temp}
    set temp(svs_return) [list 0 "Need to upgrade eggdrop."]
  }; return 1
}
## ^

if {![info exists tcl_version] || ($tcl_version < "8.4")} {
  set temp(tag) "$mc_banm(script) $mc_banm(version)"
  putloglev o * "$temp(tag) by MC_8 will only work with TCL 8.4 or greater."
  set temp() "[expr {[info exists tcl_version]?$tcl_version:"unknown"}] ("
  append temp() [expr {[info exists tcl_patchLevel]?$tcl_patchLevel:"unknown"}]
  append temp() ")"
  putloglev o * "$temp(tag) will not work with TCL $temp()."
  putloglev o * "$temp(tag) not loaded."
  uplevel #0 {
    if {[info exists temp] && ![array exists temp]} {unset temp}
    set temp(svs_return) [list 0 "Need to upgrade TCL."]
  }; return 1
}

# Error Catching System (ECS), v4.1.
proc mc:banm:errchk {command args} {
  
  # Enable (1) or disable (0) auto reporting of bugs to mc8@purehype.net.
  # This setting here for those who want to disable it in fear of privacy
  # violations.
  set enable_auto_reporting 1
  
  if {![info exists ::lastCommand]} {set ::lastCommand [list]}
  set ::lastCommand \
    "[list [list [clock seconds] $command $args]] $::lastCommand"
  set ::lastCommand [lrange $::lastCommand 0 4]
  if {![catch {eval $command $args} return]} {return $return}
  if {$::errorCode == "mc.ecs.done"} {return -errorcode mc.ecs.done -code error}
  
  set temp(lastbind) [expr {[info exists ::lastbind]?$::lastbind:"-NULL-"}]
  set temp(eversion) [expr {[info exists ::version]?$::version:"-NULL-"}]
  set message "
    ************************************
    (ECS 4.1) Error found in TCL script.
    --------------
    Script name   : $::mc_banm(script)
    Script version: $::mc_banm(version)
    Egg. Version  : $temp(eversion)
    TCL Version   : [info tclversion] ([info patchlevel])
    --------------
    Last Bind     : $temp(lastbind)
    Last Commands :"
  foreach line $::lastCommand {
    foreach {time command arg} $line break
    append message "\n        ${time}- $command $arg"
  }
  append message "\n    Error stack   :"
  foreach line [split $::errorInfo \n] {
    append message "\n        $line"
  }
  append message "\n    --------------"
  
  set message [lrange [split $message \n] 1 end]
  set offset [string first * [lindex $message 0]]
  set new_message [list]
  foreach line $message {lappend new_message [string range $line $offset end]}
  set message $new_message
  
  if {!$enable_auto_reporting ||
      [catch {socket -async mc.purehype.net 80} sid]} {
    foreach line $message {putloglev o * $line}
    putloglev o * "Submit this bug to http://mc.purehype.net/bugzilla/ . If"
    putloglev o * "you are experiencing problems with bugzilla, contact MC_8"
    putloglev o * "via email at mc8@purehype.net. Please include all"
    putloglev o * "information shown here, in this ECS report."
    putloglev o * "************************************"
    return -errorcode mc.ecs.done -code error
  }
  fconfigure $sid -blocking 0 -buffering line

  set query [list]
  # This info is passed should I need to hunt down the bot's owner for more
  # information.
  lappend query "Admin   : [expr {[info exists ::admin]?$::admin:""}]"
  lappend query "Owner   : [expr {[info exists ::owner]?$::owner:""}]"
  lappend query "Botnick : [expr {[info exists ::botnick]?$::botnick:""}]"
  lappend query "Server  : [expr {[info exists ::server]?$::server:""}]"
  lappend query "Channels: [join [lsort -dictionary [channels]] ", "]"
  lappend query ""
  
  foreach line $message {lappend query $line}
  lappend query "************************************"
  
  set new_query [list]
  foreach line $query {
    regsub -all -- "(\002|\017|\026|\037)" $line "" line
    regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $line "" line
    regsub -all {\%} $line "%25" line
    set i [string length $line]
    while {[regexp {[^a-zA-Z0-9%]} $line toh] && ($i >= 0)} {
      scan "$toh" %c dec
      regsub -all -- "\\${toh}" $line "%[format %X $dec]" line
      incr i -1
    }; lappend new_query $line
  }; set query $new_query
  
  set query "message=[join $query %0a]"
  puts $sid "POST /report_bug.tcl HTTP/1.0\
           \nHost: mc.purehype.net:80\
           \nContent-type: application/x-www-form-urlencoded\
           \nContent-Length: [expr [string length $query] +2]"
  puts $sid \n$query
  close $sid

  foreach line $message {putloglev o * $line}
  putloglev o * "Automatically sending bug report to MC_8."
  putloglev o * "If you have a firewall setup, it may block the sending of this"
  putloglev o * "report. You can check the status of your bug, as soon as MC_8"
  putloglev o * "adds it, at http://mc.purehype.net/bugzilla/ ."
  putloglev o * "************************************"
  
  return -errorcode mc.ecs.done -code error
}
# ^

setudef flag mc.banmask

# banmask [channel|'all']
bind dcc - banmask mc:banm:dcc:banmask
proc mc:banm:dcc:banmask {handle index argument} {
  return [mc:banm:errchk mc:banm:dcc:banmask_ $handle $index $argument]
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
  return [mc:banm:errchk mc:banm:dcc:+banmask_ $handle $index $argument]
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
  return [mc:banm:errchk mc:banm:dcc:-banmask_ $handle $index $argument]
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
   [mc:banm:errchk mc:banm:part_ $nick $uhost $handle $channel $argument]
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
    [mc:banm:errchk mc:banm:nick_ $nick $uhost $handle $channel $newnick]
}
proc mc:banm:nick_ {nick uhost handle channel newnick} {
  if {![isbotnick $newnick] && [validchan $channel]} {
    mc:banm:list scan [list $newnick $uhost $handle $channel]
  }
}

bind join - * mc:banm:join
proc mc:banm:join {nick uhost handle channel} {
  return [mc:banm:errchk mc:banm:join_ $nick $uhost $handle $channel]
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
  return [mc:banm:errchk mc:banm:evnt:save_ $type]
}
proc mc:banm:evnt:save_ {type} {mc:banm:list save}

proc mc:banm:list {command {argument ""}} {
  return [mc:banm:errchk mc:banm:list_ $command $argument]
}
proc mc:banm:list_ {command {argument ""}} {
  global mc_banm botnet-nick botnick

  if {![file exists $mc_banm(:config:datafile)]} {
    close [open $mc_banm(:config:datafile) w]
  }
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
      if {$argument != "-q"} {
        putloglev o * "Reading $mc_banm(script) file..."
      }
      
      set mc_banm(:list:) ""
      set io [open $mc_banm(:config:datafile) r]
      while {![eof $io]} {
        gets $io line

        if {([catch {llength $line} length]) ||
            ($length != "4") ||
            ([lindex $line 0] != "x")} {continue}
        set line [lrange $line 1 end]
        set channel [lindex $line 0]

        if {($channel != "") &&
            ((![validchan $channel]) ||
             (![mc:banm:chanflag $channel mc.banmask]))} {continue}

        lappend mc_banm(:list:) $line
      }; close $io
      
      if {$argument != "-q"} {
        set number [llength $mc_banm(:list:)]
        set s [expr {($number == "1")?"":"s"}]
        putloglev o * "$mc_banm(script): Loaded $number record$s."
      }
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
        putloglev o * "Writing $mc_banm(script) file ..."
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

      if {(!$warned) &&
          ([regexp -- {^(-3|-2|-1)$} $mc_banm(:config:pre:pun)])} {
        switch -- $mc_banm(:config:pre:pun) {
          "-3" {putserv "NOTICE $nick :$reason" ; set done "/notice"}
          "-2" {putserv "PRIVMSG $nick :$reason"; set done "/msg"}
          default {set done ""}
        }
        if {$done != ""} {
          set temp() "$nick ($uhost) \[$channel\] was warned via"
          putloglev o * "$mc_banm(script): $temp() $done.  Match: [lindex $match 1]"
        }
        if {$mc_banm(:config:warn:time)} {
          set number $mc_banm(:config:warn:time)
          if {[lindex [split [expr $number/2.] .] 1]} {incr number}
          utimer $number \
            [list mc:banm:list scan [list $nick $uhost $handle $channel 1]]
        }
      }

      set array [expr {$warned?"post":"pre"}]

      if {$mc_banm(:config:${array}:pun) >= "-1"} {
        set x "ed from $channel."
        if {$mc_banm(:config:${array}:pun) != "-1"} {
          putserv "MODE $channel +b $banmask"
          set x "/banned from $channel."
        }
        if {$mc_banm(:config:${array}:pun) >= "1"} {
          newchanban $channel $banmask ${botnet-nick} $reason \
            $mc_banm(:config:${array}:pun) none
          set temp() [duration [expr $mc_banm(:config:${array}:pun)*60]]
          set x "/banned from $channel. Ban duration: $temp()."
        }
        putserv "KICK $channel $nick :$reason"
        putloglev o * \
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


utimer 2 [list mc:banm:list load]

## SVS insert (post code)
if {![info exists mc_banm(:config:svs:enable)] ||
    ![string match {[01]} $mc_banm(:config:svs:enable)]} {
  set mc_banm(:config:svs:enable) 0
}

bind time - "00 00 *" mc:banm:do_svs
proc mc:banm:do_svs {{args ""}} {
  global mc_banm
  set query $mc_banm(svs:query)
  if {$args == ""} {append query "&log=0"}
  if {[catch {connect $mc_banm(svs:server) $mc_banm(svs:port)} ind]} {
    set temp(1) "SVS problem connecting to $mc_banm(svs:server)"
    set temp(2) "on port $mc_banm(svs:port)"
    putloglev d * "$mc_banm(script): $temp(1) $temp(2):  $ind"
    return 0
  }
  putdcc $ind "GET $mc_banm(svs:get)?$query HTTP/1.0\n"
  putdcc $ind "Host: $mc_banm(svs:server):$mc_banm(svs:port)\n\n"
  control $ind mc:banm:svs_talk
}

proc mc:banm:svs_memory {action} {
  global mc_banm
  switch -- $action {
    
    "setup" {
      upvar index index
      foreach _item [list header memory rfc_memory] {
        upvar $_item $_item
        set $_item [list svs $_item $index]
      }
    }
    
    "remove" {
      upvar index index
      mc:banm:svs_memory setup
      catch {unset mc_banm($header)}
      catch {unset mc_banm($memory)}
      foreach _item [array names mc_banm $rfc_memory:*] {unset mc_banm($_item)}
    }

  }
}

proc mc:banm:svs_talk {index text} {
  global mc_banm
  mc:banm:svs_memory setup
  if {$text == ""} {
    mc:banm:svs_memory remove
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exists mc_banm($header)]} {
    if {$rfc == "002"} {set mc_banm($header) 1}
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_banm(svs:script)} {
        set temp(1) "wanted $mc_banm(svs:script), got $text"
        putloglev d * "$mc_banm(script): SVS Error: $temp(1)"
        mc:banm:svs_memory remove
        return 1
      }
      if {$mc_banm(:config:svs:enable)} {return 0}
      set mc_banm($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    011 {
      if {$mc_banm(:config:svs:enable)} {return 0}
      set mc_banm($rfc_memory:[string index $rfc end]) $text
      return 0
    }
      
    012 {
      if {$mc_banm(:config:svs:enable)} {return 0}
      set mc_banm($rfc_memory:[string index $rfc end]) $text
      return 0
    }
    
    013 {
      if {$mc_banm(:config:svs:enable)} {return 0}
      set mc_banm($rfc_memory:[string index $rfc end]) $text
      return 0
    }
    
    014 {
      if {$mc_banm(:config:svs:enable)} {return 0}
      set mc_banm($rfc_memory:[string index $rfc end]) $text
      return 0
    }
    
    017 {
      if {$mc_banm(:config:svs:enable)} {return 0}
      if {$text == ""} {
        set text "Newer version of this script exists."
      }
      foreach number [list 0 1 2 3 4] {
        if {![info exists mc_banm($rfc_memory:$number)]} {continue}
        regsub -all -- %$number $text $mc_banm($rfc_memory:$number) text
      }
      putloglev o * "SVS, $mc_banm(script): $text"
      mc:banm:svs_memory remove
      return 1
    }

    004 {
      # Quit.
      if {!$mc_banm(:config:svs:enable)} {
        mc:banm:svs_memory remove
        return 1
      }
        
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
              set lsearch_index [lsearch -exact $temp(vars) $item]
              set temp(vars) \
                [lreplace $temp(vars) $lsearch_index $lsearch_index]
              puts $io [list set mc_banm($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:[; ][; ]*(.*))?} $line -> extra]} {
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
                  if {[regexp -- {[^\\]"(?:[; ][; ]*(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:[; ][; ]*(.*))?} $line -> extra]} {
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
        if {[catch {uplevel "source $file~new"}]} {
          file delete -force -- $file~new
          putloglev o * "$mc_banm(script): Auto update failed:"
          putloglev o * $::errorInfo
          putloglev o * \
            "$mc_banm(script): Loading previous script version..."
          uplevel "source $file"
        } else {
          upvar #0 temp upvar_temp
          if {[info exists upvar_temp(svs_return)]} {
            set temp(return_code) [lindex $upvar_temp(svs_return) 0]
            set temp(return_arg) [lindex $upvar_temp(svs_return) 1]
            
            if {!$temp(return_code)} {
              file delete -force -- $file~new
              set temp() "message from new version: $temp(return_arg)"
              putloglev o * "$mc_banm(script): Auto update failed, $temp()"
              putloglev o * \
                "$mc_banm(script): Loading previous script version..."
              uplevel "source $file"
            } else {
              file rename -force -- $file~new $file
              set temp() "good, message from new version: $temp(return_arg)"
              putloglev o * "$mc_banm(script): Auto update test $temp()"
              putloglev o * \
                "$mc_banm(script): Moving and reloading new version..."
              uplevel "source $file"
            }
          } else {
            file rename -force -- $file~new $file
            putloglev o * "$mc_banm(script): Auto update test good."
            putloglev o * \
              "$mc_banm(script): Moving and reloading new version..."
            uplevel "source $file"
          }
        }
      }

      mc:banm:svs_memory remove
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_banm(script): SVS is being redirected to $temp(cache)."
      utimer 6 [list mc:banm:do_svs_ $temp(host) $temp(port) $temp(get)]
      mc:banm:svs_memory remove
      return 1
    }

    300 {
      if {$mc_banm(:config:svs:enable)} {
        lappend mc_banm($memory) $text
      }; return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) [list]}
if {![array exists mc_loaded]} {unset mc_loaded; set mc_loaded(scripts) [list]}
set index [lsearch -exact $mc_loaded(scripts) mc_banm]
set mc_loaded(scripts) [lreplace $mc_loaded(scripts) $index $index mc_banm]
## ^

putloglev o * "$mc_banm(script) $mc_banm(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v1.4.2 (10.07.03)
#  MC_8 -             - Changed 'puthelp''s to 'putserv''s (getting in the
#                       habbit to be ready for eggdrop 1.8, will not support
#                       it).
#  MC_8 -             - Moved all 'putlog''s to 'putloglev o *''s (getting in
#                       the habbit to be ready for eggdrop 1.8, will not support
#                       it).
#  MC_8 -             - Adjusted all timers to even numbers -- eggdrop has a bug
#                       to where strange things happen on odd number timers
#                       (viewing timer list shows blank on odd number timer
#                       call).
#  MC_8 -             - Upgraded ECS. v3.0 -> v4.1
#  MC_8 -             - Upgraded SVS Client.  v4.0.1 -> v4.1.2
#  MC_8 - Mopirelli \ - Script will only work with TCL v8.4 or greater.
#         Bostjan   \   Bugzilla Bug 233 
#         Mat
#
# v1.4.1 (07.26.03)
#  MC_8 - Mopirelli - Fixed bot loosing ban mask entries after restart or bot
#         Bostjan     start.
#         Normand     Bugzilla Bug 234
#                     Bugzilla Bug 320
#  MC_8 - Normand   - Fixed 'can't read "mc_banm(pre:pun)": no such element in
#                     array'.
#                     Bugzilla Bug 320
#
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
#  MC_8 - Duckman - Initial release.
##
