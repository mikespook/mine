#init system

usage() {
    echo "Usage: sys-init [-n host-name] [-z timezone=Asia/Shanghai] [-l locale=zh_CN]"
    exit 1
}

while getopts 'n:z:l:' o &>> /dev/null; do
    case "$o" in
	n)
        HOST_NAME="$OPTARG";;
    z)
        TIMEZONE="$OPTARG";;
	l)
		LOCALE="$OPTARG";;
    *)
        usage;;
    esac
done

if [ "$HOST_NAME" == "" ]; then
    usage
fi

f=/usr/share/zoneinfo/$TIMEZONE
if [ -f $f ] ; then
    export TIMEZONE
else
    export TIMEZONE='Asia/Shanghai'
fi

if [ -z $LOCALE ] ; then
	LOCALE=zh_CN
fi

check_root

echo "init system, pleas wait ..."

echo "modify hostname: $HOST_NAME"
f=/etc/hostname
echo $HOST_NAME > $f
hostname --file $f

echo "setup common environment ... "

# fix locale
echo "export LANGUAGE=\"$LOCALE:en\"
export LC_ALL=\"C\"
export LC_PAPER=\"$LOCALE.UTF-8\"
export LC_ADDRESS=\"$LOCALE.UTF-8\"
export LC_MONETARY=\"$LOCALE.UTF-8\"
export LC_NUMERIC=\"$LOCALE.UTF-8\"
export LC_TELEPHONE=\"$LOCALE.UTF-8\"
export LC_IDENTIFICATION=\"$LOCALE.UTF-8\"
export LC_MEASUREMENT=\"$LOCALE.UTF-8\"
export LC_TIME=\"$LOCALE.UTF-8\"
export LC_NAME=\"$LOCALE.UTF-8\"
export LANG=\"C\"" > /etc/profile.d/locale.sh

# update & install
echo "update & install ... "

apt-get -y update
apt-get -y install vim git liblua5.1-0

# rewrite file limits
echo "system limits ..."
cp $BASE/etc/limits.conf /etc/security/limits.d/mikespook.conf
f=/etc/pam.d/common-session
sed -i '$i session required pam_limits.so' $f
cp $BASE/etc/ulimit.sh /etc/profile.d/
pam-auth-update --package --force

# rewrite network params
echo "network params ..."
cp $BASE/etc/sysctl.conf /etc/sysctl.d/60-mikespook.conf
service procps reload || \
	cat /etc/sysctl.d/*.conf /etc/sysctl.conf | sysctl -p -

# ssh
dpkg -s openssh-server
if [ $? ]; then
	echo "sshd settings ..."
	f=/etc/ssh/sshd_config
	sed -i -e "s/^PermitRootLogin .*/PermitRootLogin no/g" $f
	sed -i -e "s/^PubkeyAuthentication .*/PubkeyAuthentication yes/g" $f
	sed -i -e "s/^PasswordAuthentication .*/PasswordAuthentication no/g" $f
	service ssh restart
fi

# update datetime
echo "update system datetime ... "
f=/usr/share/zoneinfo/$TIMEZONE
cp $f /etc/localtime
ntpdate ntp.ubuntu.com cn.pool.ntp.org
