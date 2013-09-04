#!/bin/bash
base=$HOME/.mikespook/
. $base/funcs.sh
. $base/conf-enabled/*
export PS1=$(__mikespook_ps1)
