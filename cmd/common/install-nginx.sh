#install nginx with official source

usage() {
    echo "Usage: install-nginx"
    exit 1
}

while getopts '' o &>> /dev/null; do
    case "$o" in
    *)
        usage;;
    esac
done

check_root

echo "setup web server (nginx) ..."  
# import nginx gpg key
wget -q -O - http://nginx.org/keys/nginx_signing.key | apt-key add -
os=`dist`
dist=`lsb_release -cs`
f=/etc/apt/sources.list.d/nginx.list
echo "deb http://nginx.org/packages/$os/ $dist nginx" > $f
echo "deb-src http://nginx.org/packages/$os/ $dist nginx" >> $f

apt-get -y update
apt-get -y install nginx
mkdir -p /etc/nginx/sites-available/
mkdir -p /etc/nginx/sites-enabled/
cp -f $BASE/etc/nginx.conf /etc/nginx/nginx.conf
service nginx reload
