#init system

TIMEZONE='Asia/Shanghai'
LANG="en"
LOCALE="en_US"

usage() {
    echo "Usage: sys-init [-n host-name] [-z timezone=$TIMEZONE] [-l language:locale=$LANG:$LOCALE]"
    exit 1
}

while getopts 'n:z:l:' o &>> /dev/null; do
    case "$o" in
	n)
        HOST_NAME="$OPTARG";;
    z)
        TIMEZONE="$OPTARG";;
	l)
		LANG="${OPTARG%:*}"
		LOCALE="${OPTARG#*:}";;
    *)
        usage;;
    esac
done

if [ -z "$HOST_NAME" ]; then
    usage
fi

check_root

echo "Initializing system ..."

echo "Hostname: $HOST_NAME"
f=/etc/hostname
echo $HOST_NAME > $f
hostname --file $f

echo "Setting up environment ... "

# fix locale
echo "LANG=C
LANGUAGE=$LOCALE:$LANG
LC_CTYPE=\"C\"
LC_NUMERIC=\"C\"
LC_TIME=\"C\"
LC_COLLATE=\"C\"
LC_MONETARY=\"C\"
LC_MESSAGES=\"C\"
LC_PAPER=\"C\"
LC_NAME=\"C\"
LC_ADDRESS=\"C\"
LC_TELEPHONE=\"C\"
LC_MEASUREMENT=\"C\"
LC_IDENTIFICATION=\"C\"
LC_ALL=C" > /etc/profile.d/locale.sh


# update & install
apt-get -y update
apt-get -y install git tmux

# rewrite file limits
cp $BASE/etc/limits.conf /etc/security/limits.d/mikespook.conf
f=/etc/pam.d/common-session
sed -i '$i session required pam_limits.so' $f
cp $BASE/etc/ulimit.sh /etc/profile.d/
pam-auth-update --package --force

# rewrite network params
cp $BASE/etc/sysctl.conf /etc/sysctl.d/60-mikespook.conf
service procps reload || \
	cat /etc/sysctl.d/*.conf /etc/sysctl.conf | sysctl -p -

# ssh
dpkg -s openssh-server
if [ $? ]; then
	echo "Setting up SSH server ..."
	f=/etc/ssh/sshd_config
	sed -i -e "s/^PermitRootLogin .*/PermitRootLogin no/g" $f
	sed -i -e "s/^PubkeyAuthentication .*/PubkeyAuthentication yes/g" $f
	sed -i -e "s/^PasswordAuthentication .*/PasswordAuthentication no/g" $f
	service ssh restart
fi

# update datetime
echo "Updating datetime ... "
f=/usr/share/zoneinfo/$TIMEZONE
if [ -f $f ] ; then
    export TIMEZONE
	cp $f /etc/localtime
else
	echo "Time zone $TIMEZONE is not existing."
fi

ntpdate ntp.ubuntu.com pool.ntp.org
