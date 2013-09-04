# usage information
## Need a help for help, eh?
## usage: help [command]

get_cmd_intro() {
    if [ -f $1 ] ; then
        local title=$(basename $1 $2)
        local intro=$(sed -n '1 s/#//p' $1)
        echo "\t${title%%_*}\t\t$(trim $intro)\n"
    fi
}

usage() {
	local cmd=`basename $0`
    echo "Usage:

	$cmd command [arguments]

The commands are:
"
    # commands list here
    for f in $base/`dist`/*.sh; do
        local list="$list$(get_cmd_intro $f .sh)"
    done
    for f in $base/*.sh; do
        local list="$list$(get_cmd_intro $f .sh)"
    done

    printf "$list"|sort|uniq

    echo "
Use '$cmd help [command]' for more information about a command.
	"
}
if [ -f $base/`dist`/$1.sh ] ; then 
    . $base/`dist`/$1.sh -h
elif [ -f $base/$1.sh ] ; then 
	. $base/$1.sh -h
else
    usage
fi
