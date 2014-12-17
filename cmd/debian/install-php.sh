#install mongodb with official source

usage() {
    echo "Usage: install-php"
    exit 1
}

while getopts '' o &>> /dev/null; do
    case "$o" in
    *)
        usage;;
    esac
done

check_root

echo "setup php ..."  

wget -q -O - http://www.dotdeb.org/dotdeb.gpg| apt-key add -
dist=`lsb_release -cs`
echo "deb http://packages.dotdeb.org $dist all
deb-src http://packages.dotdeb.org $dist all" >> /etc/apt/sources.list.d/php.list

apt-get -y update
apt-get -y install php5-cli php5-fpm php5-gd \
    php-pear php5-dev php5-mysql php5-mcrypt \
    php5-memcached

# yaf
pecl install yaf
echo 'extension=yaf.so' > /etc/php5/conf.d/yaf.ini
# mongo
pecl install mongo
echo 'extension=mongo.so' > /etc/php5/conf.d/mongo.ini
#
service php5-fpm reload
