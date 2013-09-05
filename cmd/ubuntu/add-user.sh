#add new user with specified ssh key

usage() {
    echo "Usage: add-user -n -k -u"
    exit 1
}

while getopts 'n:k:u:' o &>> /dev/null; do
    case "$o" in
	n)
        USER_NAME="$OPTARG";;
	k)
        SSH_KEY="$OPTARG";;
	u)
		KEY_URL="$OPTARG";;
    *)
        usage;;
    esac
done

if [ "$USER_NAME" == "" ]; then
    usage
fi

if [ "$SSH_KEY" == "" ]; then
	f=`mktemp -u`
	wget -q --no-check-certificate -O $f $KEY_URL
	json=`cat $f`
	SSH_KEY=`php -r "echo json_decode('$json')->key;"`
fi

if [ "$SSH_KEY" == "" ]; then
	usage
fi

check_root

__add_user() {
	local user=$1
	local key=$2
	local home=/home/$user
	id $user &>> /dev/null
	[ $? -eq 0 ] && return 1
	adduser --quiet --disabled-password --gecos "" $user
	usermod -a -G sudo $user
	mkdir $home/.ssh
	echo $key > $home/.ssh/authorized_keys
	chown -R $user:$user $home/.ssh
	chmod 700 $home/.ssh
	chmod 600 $home/.ssh/authorized_keys
}

__add_user $USER_NAME $SSH_KEY
