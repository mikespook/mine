#add new user with specified ssh key

usage() {
    echo "Usage: set-auth -n -k -u [-p]"
	printf "\t-n User name\n"
	printf "\t-k SSH key string\n"
    printf "\t-u URL of sshkey\n"
    printf "\t-p Modify password\n"    
    exit 1
}

PASSWD=0

while getopts 'n:k:u:p' o &>> /dev/null; do
    case "$o" in
	n)
        USER_NAME="$OPTARG";;
	k)
        SSH_KEY="$OPTARG";;
	u)
		KEY_URL="$OPTARG";;
	p)
		PASSWD=1;;
    *)
        usage;;
    esac
done

if [ "$USER_NAME" == "" ]; then
    usage
fi

check_root

apt-get -y install php5-cli

if [ "$SSH_KEY" == "" ]; then
	f=`mktemp -u`
	wget -q --no-check-certificate -O $f $KEY_URL
	json=`cat $f`
	SSH_KEY=`php -r "echo json_decode('$json')->key;"`
fi

if [ "$SSH_KEY" == "" ]; then
	usage
fi

__set_sshkey() {
	local user=$1
	local key=$2
	local home=`getent passwd "$user" | cut -d: -f6`
	id $user &>> /dev/null
	[ $? -ne 0 ] && return 1
	mkdir -p $home/.ssh
	echo $key > $home/.ssh/authorized_keys
	chown -R $user:$user $home/.ssh
	chmod 700 $home/.ssh
	chmod 600 $home/.ssh/authorized_keys
}

__set_sshkey "$USER_NAME" "$SSH_KEY"
if [ $? -eq 0 ] || [ $PASSWD -eq 1 ] ;then
	passwd $USER_NAME
fi
