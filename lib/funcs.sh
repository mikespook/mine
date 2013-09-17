#!/bin/bash
# get PS1 string
__mikespook_ps1() {
	local none='\[\033[00m\]'
	local g='\[\033[0;32m\]'
	local c='\[\033[0;36m\]'
	local emy='\[\033[1;33m\]'
	local br='\[\033[1;41m\]'
	local bb='\[\033[1;44m\]'

	local uc=$none
	local p='$'
	if [ $UID -eq "0" ] ; then
    	uc=$br
		p='#'
	fi
	hc=$bb
	if [ -z $SSH_TTY ] ; then
		hc=$c
	fi
	local u="${uc}${debian_chroot:+($debian_chroot)}\u${none}"
	local h="${hc}\h${none}:${g}\w${none}"
	command -v __git_ps1 >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "$u@$h\$(__git_ps1 '[${emy}%s${none}]')${uc}${p}${none} "
	else
		echo "$u@$h${uc}${p}${none} "
	fi
}
