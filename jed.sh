#!/bin/sh --
# find jed and set settings, etc.
case $0 in 
  # sourced from /bin/sh ...
  *sh) unset JED_ROOT JED_LIBRARY;;
esac

if [ -z "$JED_ROOT" ]; then
  unset JED_LIBRARY

  # look for a global configuation file 
  type jed_root>/dev/null 2>&1
  if [ $? -eq 0 ]; then tmp=`jed_root`; else tmp="not found"; fi
  
  # look for common directories
  for tmp in \
    $tmp \
    /opt/jed \
    /usr/jed /usr/slang/jed  \
    /usr/local/jed /usr/local/slang/jed \
    /data/local/opt/jed /data/local/opt/slang/jed \
    /data/local/usr/jed /data/local/usr/slang/jed \
    /data/local/usr/local/jed /data/local/usr/local/slang/jed \
    /data/calc/eva/usr/local/jed /data/calc/eva/usr/local/slang/jed \
    $HOME/usr/jed $HOME/usr/slang/jed \
    $HOME/usr/local/jed $HOME/usr/local/slang/jed \
  ;
  do
    if [ -d "$tmp" ]; then JED_ROOT=$tmp; export JED_ROOT; break; fi
  done
fi
unset tmp

if [ ! -z "$JED_ROOT" ]; then 
  if [ -z "$JED_LIBRARY" ]; then
    JED_LIBRARY="${JED_ROOT}/lib"; export JED_LIBRARY;
    
    # check if the corresponding slang library extensions exist
    # NB: JED_LIBRARY is comma-delimited!
  
    # from /usr/local/jed -> /usr/local/slang/lib
    slanglib=`dirname $JED_ROOT`"/slang/lib"
    if [ -d "$slanglib" ]; then
      JED_LIBRARY="$slanglib,${JED_LIBRARY}"; 
    fi
    
    for tmp in /usr /usr/local $HOME/usr $HOME/usr/local
    do
      tmp="$tmp/slang/lib"
      if [ -d "$tmp" -a "$tmp" != "$slanglib" ]; then
        JED_LIBRARY="$tmp,${JED_LIBRARY}";
      fi
    done
    unset slanglib
  fi
  unset tmp

  case $0 in
    # sourced from /bin/sh ...
    *sh) ;; # skip following

    # called as executable
    *) bg=; cmd=$JED_ROOT/bin/`basename $0`;
      case $cmd in
        */xjed.bg | */Xjed)     # execute in background mode
          cmd=$JED_ROOT/bin/xjed; bg='&'
        ;;
      esac
      
      if [ ! -x "$cmd" ]; then echo "$cmd not found"; exit 1; fi
      
      LANG=C; export LANG       # Jed doesn't like commas, and neither do I
      # echo '->'$cmd $*$bg'<-'
      eval exec $cmd $* $bg
    ;;
  esac
fi
 
