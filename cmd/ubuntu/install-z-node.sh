#install z-node service

usage() {
    echo "Usage: install-z-node [-a attached scripts]"
    exit 1
}

while getopts 'a:' o &>> /dev/null; do
    case "$o" in
	b)
        ATTACHED="$OPTARG";;
    *)
        usage;;
    esac
done

if [ ! -f $GOROOT/README ]; then
	echo "Error, go were not installed."
	echo "Please install it by:"
	echo "mikespook install-golang"
	exit 1
fi

check_root

apt-get -y -qq install liblua5.1-0-dev libzookeeper-mt-dev

export CGO_CFLAGS="-I/usr/include/zookeeper"
export CGO_LDFLAGS="-lzookeeper_mt"
go get github.com/mikespook/z-node

cp $GOBIN/z-node /usr/bin/z-node
cp $BASE/etc/init.d_z-node /etc/init.d/z-node
chmod +x /etc/init.d/z-node	
cp $BASE/etc/z-node.conf /etc/z-node.conf
gobase=`dirname $GOROOT`
[ -d  $gobase/3rdpkg/src/github.com/mikespook/z-node/ ] \
	&& zbase=$gobase/own/src/github.com/mikespook/z-node/
[ -d  $gobase/own/src/github.com/mikespook/z-node/ ] \
	&& zbase=$gobase/own/src/github.com/mikespook/z-node/
mkdir -p /usr/share/z-node
cp $zbase/script/* /usr/share/z-node/

if [ ! -z "$ATTACHED" ]; then
	cp -f $ATTACHED/* /usr/share/z-node/
fi

[ -f /etc/init.d/z-node ] && update-rc.d -f z-node remove
update-rc.d z-node defaults
