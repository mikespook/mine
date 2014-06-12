#add new user

USER=mikespook
PASSWORD=false

usage() {
    echo "Usage: $0 -h [-u $USER] [-p]"
	echo " -h Host of SSH key"
	echo " -u User name to be created"
	echo " -p Initializing password"
	exit 3
}

while getopts 'h:u:p' o &>> /dev/null; do
    case "$o" in
    h)
        HOST="$OPTARG";;
	u)
		USER="$OPTARG";;
    p)
        PASSWORD=true;;
    *)
        usage;;
    esac
done

check_root

id $USER &>> /dev/null
[ $? -eq 0 ] && echo "User $USER already existed." && exit 2

echo "Adding user $USER ..."

adduser --quiet --disabled-password --gecos "" $USER
egrep -i "^admin" /etc/group
[ $? -ne 0 ] && addgroup --system admin
usermod -a -G admin $USER

echo "Setting SSH key ..."
home=`getent passwd "$USER" | cut -d: -f6`
if [ ! -z "$HOST" ]; then
	mkdir -p $home/.ssh
	scp $HOST:~/.ssh/authorized_keys $HOME/.ssh/
	chown -R $USER:$USER $home/.ssh
	chmod 700 $home/.ssh
	chmod 600 $home/.ssh/authorized_keys
fi

$PASSWORD && passwd $USER

exit 0
