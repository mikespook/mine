#!/bin/bash

# progress display
_() {
    printf "\r%s\n" "$*"
}

# get distribution of OS
dist() {
    which lsb_release &>/dev/null
    if [ $? -eq 0 ] ; then 
        lsb_release -s -i | tr '[:upper:]' '[:lower:]'
    elif [ -f /etc/debian_version ] ; then
        echo debian
    elif [ -f /etc/redhat-release ] ; then
        echo centos
    else
        echo 'FATAL: can not determine OS distribution'
		return 1
    fi
}

# usage: include <base> <dir> <filename> [params]
include() {
    local base=$1; shift
	local dir=$1; shift
    local fn=$1; shift
    local script=$(script_name $base/$dir $fn)
    if [ -f $script ] ; then
		BASE=$base
		DIR=$dir
        . $script $*
    fi
}

# usage: `script_name <base> <filename>`
# return: script path
script_name() {
    if [ -f $1/`dist`/$2.sh ] ; then
        echo $1/`dist`/$2.sh
	elif [ -f $1/common/$2.sh ]; then
		echo $1/common/$2.sh
	else
        echo $1/$2.sh
    fi
}

trim() {
    echo "$(echo $* | xargs)"
}

quote() {
    echo $1|sed -e 's/\//\\\//g'
}

check_user() {
    if [ "$1" != "$USER" ] ; then
        echo "FATAL: user [$1] needed, [$USER] got"
        exit 1
    fi
}

check_root() {
    check_user root
}

waiting_process() {
    i=0
    while [ 1 ] ; do
        case "$(($((++i))%4))" in
            0) printf "%s\b" '-';;
            1) printf "%s\b" '\';;
            2) printf "%s\b" '|';;
            3) printf "%s\b" '/';;
        esac
        local n=$(ps -p "$1" | wc -l)
        if [ $n -eq 1 ]; then
            printf "\r"
            return 0
        fi
        sleep "0.02"
    done
}
