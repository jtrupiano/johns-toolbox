#!/bin/bash
#
# First pass attempt at caching bash autocompletion for ruby on rails related commands.
#
# A cache folder is created in ~/ (home directory on linux). If you ever need to clear 
# the autocomplete cache (e.g., you add a plugin or rakefile to a rails project), simply
# delete the relevant file from .bash-complete/ or call this script directly with "clear"
# as the first argument.  
# 
# Caching is per directory with the intention being that for a given project, you will 
# always run rake, cap, or script/generate from the same 
# location.
#
# Add the following to your .bashrc or .profile file to get full value from this script:
#
#   ## Rake with RAILS_ENV=test
#   alias raket="rake RAILS_ENV=test"
#   
#   ## Autocomplete tasks
#   source ~/johns-toolbox/gen-autocomplete.sh
#   
# Now, everytime you try to autocomplete, you'll get the appropriate options.  The first 
# time in a given directory will be slow, but all subsequent <tab> completions will get 
# the benefit of the cache.
# 

export COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
opt=$1

function set_bc_props {
  COMMANDNAME=$1
  DIRNAME=`pwd | awk '{sub(/\//,"",$0); gsub(/\//,"-",$0); print $0}'`
  FNAME=$1-$DIRNAME
}

BC=~/.bash-complete

if [ ! -x $BC ]; then
  mkdir $BC
fi

if [ "$opt" = "clear" ]; then
  rm $BC/*
fi

_rakecomplete() {
  COMPREPLY=()   
  if [ -f ./Rakefile ]; then
    set_bc_props rake  
    if [ ! -f $BC/$FNAME ]; then
      #echo "generating rake completions"
      rake -T | awk 'NR != 1 {gsub(/:/, "\:", $2); print $2}' > $BC/$FNAME
    fi
    COMPREPLY=($(compgen -W "`cat $BC/$FNAME`" --  ${COMP_WORDS[COMP_CWORD]}))
    #complete -C "cat $BC/$FNAME" rake
  fi
  return 0
}
_scriptgencomplete() {
  COMPREPLY=()
  if [ -f ./script/generate ]; then
    set_bc_props script-generate
    if [ ! -f $BC/$FNAME ]; then
      # regenerate script/generate completions
      script/generate --help | awk -F ': ' '/^  (Plugins|Rubygems|Builtin|User):/ { gsub(/, */, "\n", $2); print $2 }' > $BC/$FNAME
    fi
    COMPREPLY=($(compgen -W "`cat $BC/$FNAME`" --  ${COMP_WORDS[COMP_CWORD]}))
  fi
  return 0
}
_capcomplete() {
  if [ -f ./Capfile ]; then
    set_bc_props cap   
    if [ ! -f $BC/$FNAME ]; then
      # regenerate cap completions
      cap -T 2>/dev/null| awk '{{ if ( $3 ~ /\#/ ) print $2}}' > $BC/$FNAME
    fi
    COMPREPLY=($(compgen -W "`cat $BC/$FNAME`" -- ${COMP_WORDS[COMP_CWORD]}))
  fi 
  return 0
}

complete -o default -o nospace -F _rakecomplete rake
complete -o default -o nospace -F _rakecomplete raket
complete -o default -o nospace -F _scriptgencomplete generate
complete -o default -o nospace -F _capcomplete cap
