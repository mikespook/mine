#!/bin/bash

# wrap __git_ps1
__mikespook_git_ps1() {
	if [ "$PWD" != "$HOME" ] ; then
		command -v __git_ps1 >/dev/null 2>&1
		__git_ps1 $1
	fi
}

# get PS1 string
__mikespook_ps1() {
	local none='\[\033[00m\]'
	local lg='\[\033[1;32m\]'	
	local lr='\[\033[1;31m\]'	
	local c='\[\033[0;36m\]'
	local emy='\[\033[1;33m\]'
	local bb='\[\033[1;44m\]'

	local uc=$lg
	local p='$'
	if [ $UID -eq "0" ] ; then
    	uc=$lr
		p='#'
	fi
	hc=$bb
	if [ -z $SSH_TTY ] ; then
		hc=$c
	fi
	local u="${uc}${debian_chroot:+($debian_chroot)}\u${none}"
	local h="${hc}\h${none}:${g}\w${none}"
	echo "$u${emy}@${none}$h\$(__mikespook_git_ps1 '[${emy}%s${none}]')${uc}${p}${none} "
}
