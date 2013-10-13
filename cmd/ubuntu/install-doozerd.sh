#install doozerd service

usage() {
    echo "Usage: install-doozerd [-s type=doozerd|dzns]"
    exit 1
}

while getopts 's:' o &>> /dev/null; do
    case "$o" in
	s)
        SERVICE_TYPE="$OPTARG";;
    *)
        usage;;
    esac
done

[ -z $SERVICE_TYPE ] && SERVICE_TYPE='doozerd|dzns'

if [ ! -f $GOROOT/README ]; then
	echo "Error, go were not installed."
	echo "Please install it by:"
	echo "mikespook install-golang"
	exit 1
fi

check_root

export CGO_CFLAGS="-I/usr/include/zookeeper"
export CGO_LDFLAGS="-lzookeeper_mt"
go get github.com/ha/doozerd

cp $GOBIN/doozerd /usr/bin/doozerd
mkdir -p /etc/doozerd/conf.d/
mkdir -p /etc/doozerd/enabled/

echo $SERVICE_TYPE|grep doozerd > /dev/null
if [ $? -eq 0 ]; then
	cp $BASE/etc/doozerd.conf /etc/doozerd/conf.d/doozerd.conf
	ln -s /etc/doozerd/conf.d/doozerd.conf /etc/doozerd/enabled/20-doozerd.conf
fi
echo $SERVICE_TYPE|grep dzns > /dev/null
if [ $? -eq 0 ]; then
	cp $BASE/etc/dzns.conf /etc/doozerd/conf.d/dzns.conf
	ln -s /etc/doozerd/conf.d/dzns.conf /etc/doozerd/enabled/10-dzns.conf
fi

cp $BASE/etc/init.d_doozerd /etc/init.d/doozerd
chmod +x /etc/init.d/doozerd
[ -f /etc/init.d/doozerd ] && update-rc.d -f doozerd remove
update-rc.d doozerd defaults
