#!/bin/bash
base=$HOME/.mikespook/
. $base/lib/funcs.sh
. $base/conf-enabled/*
export PATH=$PATH:$base/bin
export PS1=$(__mikespook_ps1)
