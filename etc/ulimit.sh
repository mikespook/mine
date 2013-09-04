if [ $EUID -eq 0 ] ; then
    ulimit -n 65535
fi
ulimit -c unlimited
ulimit -m unlimited
ulimit -s unlimited
ulimit -t unlimited
ulimit -v unlimited
