#upgrade system

usage() {
    echo "Usage: sys-upgrade"
    exit 1
}

while getopts '' o &>> /dev/null; do
    case "$o" in
    *)
        usage;;
    esac
done

check_root

# update
sudo apt-get -y -q update
sudo apt-get -y -q upgrade
