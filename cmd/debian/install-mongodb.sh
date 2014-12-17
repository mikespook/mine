#install mongodb with official source

usage() {
    echo "Usage: install-mongodb"
    exit 1
}

while getopts '' o &>> /dev/null; do
    case "$o" in
    *)
        usage;;
    esac
done

check_root

echo "setup mongodb ..."  

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' >> /etc/apt/sources.list.d/mongodb.list

apt-get -y update
apt-get -y install mongodb-org

sed -i -e '/^bind_ip/d' /etc/mongodb.conf
echo 'bind_ip=127.0.0.1' >> /etc/mongodb.conf
sed -i -e '/^nohttpinterface/d' /etc/mongodb.conf
echo 'nohttpinterface=false' >> /etc/mongodb.conf
