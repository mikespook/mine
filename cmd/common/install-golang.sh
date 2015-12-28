#install golang

usage() {
    echo "Usage: install-golang [-b path base=$HOME]"
    exit 1
}

while getopts 'b:' o &>> /dev/null; do
    case "$o" in
	b)
        SERVICE_BASE="$OPTARG";;
    *)
        usage;;
    esac
done

if [ -z "$SERVICE_BASE" ]; then
    SERVICE_BASE=$HOME
fi

if [ $EUID -eq 0 ]; then
	echo "Installing dependency packages ..."
    if apt-get install -y gcc libc6-dev; then
    	echo "Error, check your network connection!"
    	exit 1
    fi
fi

dpkg -s gcc &> /dev/null && dpkg -s libc6-dev &> /dev/null \
	&& dpkg -s mercurial &> /dev/null

if [ $? -ne 0 ]; then
	echo "Error, dependency packages were not installed."
	echo "Please install them by:"
	echo "apt-get install gcc libc6-dev mercurial"
	exit 1
fi

BIN=$SERVICE_BASE/golang/go/bin
OWN=$SERVICE_BASE/golang/own
PKG=$SERVICE_BASE/golang/3rdpkg

# init the environment
mkdir -p $OWN
mkdir -p $PKG
# setup env-variables
export PATH=$PATH:$BIN
export GOROOT=$SERVICE_BASE/golang/go
# put $SERVICE_BASE/go/3rdpkg at the first
export GOPATH=$PKG:$OWN:$GOROOT

if [ $SERVICE_BASE == $HOME ]; then
    config=$SERVICE_BASE/.profile
else
    PROFILE=/etc/profile.d
    if [ -d $PROFILE ]; then
        config=$PROFILE/golang.sh
    else
        config=/etc/profile
    fi
fi

sed -i -e "/^$/d" $config
sed -i -e "s/^export SERVICE_BASE.*//g" $config
sed -i -e "s/^export PATH=\$PATH:\$GOBIN.*//g" $config
sed -i -e "s/^export GOROOT.*//g" $config
sed -i -e "s/^export GOPATH.*//g" $config

echo "" >>$config
echo "export SERVICE_BASE=$SERVICE_BASE" >> $config
echo 'export GOROOT=$SERVICE_BASE/golang/go' >> $config
echo 'export GOPATH=$SERVICE_BASE/golang/3rdpkg:$GOROOT:$SERVICE_BASE/golang/own' >> $config
echo 'export PATH=$PATH:$GOROOT/bin' >> $config
echo 'export GOROOT_BOOTSTRAP=$SERVICE_BASE/golang/go-bootstrap' >> $config

pushd . > /dev/null
cd $SERVICE_BASE/golang
rm -rf golang
if git clone -b 1.4.2 https://go.googlesource.com/go go1.4; then 
	echo "Error, check your network connection."
	exit 1
fi
popd > /dev/null

ln -s go1.4 go

pushd . > /dev/null
cd $GOROOT/src/
if ./all.bash; then 
	echo "Error, build golang faild."
	exit 1
fi
popd > /dev/null

cp -rf go1.4 go1.5
unlink go
ln -s go1.5 go
ln -s go1.4 go-bootstrap
export GOROOT_BOOTSTRAP=$SERVICE_BASE/golang/go-bootstrap

pushd . > /dev/null
cd $GOROOT/src/
if ./all.bash; then 
	echo "Error, build golang faild."
	exit 1
fi
popd > /dev/null

echo "Golang was installed in $SERVICE_BASE/golang/go."
