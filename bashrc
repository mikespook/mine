#!/bin/bash
base=$HOME/.mikespook/
. $base/lib/funcs.sh
[ "$(ls -A $base/conf-enabled)" ] && . $base/conf-enabled/*
export PATH=$PATH:$base/bin
export PS1=$(__mikespook_ps1)
