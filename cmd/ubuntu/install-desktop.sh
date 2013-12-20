#install desktop enviroment

usage() {
    echo "Usage: install-desktop"
    exit 1
}

while getopts '' o &>> /dev/null; do
    case "$o" in
    *)
        usage;;
    esac
done

check_root

echo "deb http://download.virtualbox.org/virtualbox/debian `lsb_release -cs` contrib" > /etc/apt/sources.list.d/virtualbox.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -

echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

apt-get -y install git meld\
	vim-gtk vim-syntax-go \
	gstm tsocks filezilla\
	claws-mail claws-mail-fancy-plugin claws-mail-trayicon \
	libreoffice libreoffice-l10n-zh-cn hunspell hunspell-en-us

apt-get -y install virtualbox-4.2 dkms
f=Oracle_VM_VirtualBox_Extension_Pack-4.2.18-88780.vbox-extpack
wget -O /tmp/$f http://download.virtualbox.org/virtualbox/4.2.18/$f
VBoxManage extpack install /tmp/$f
rm -f /tmp/$f

apt-get -y --force-yes install google-chrome-stable

f=/etc/tsocks.conf
sed -i -e "s/server = 192.168.0.1/server = 127.0.0.1/" $f
sed -i -e "s/server_port = 1080/server_port = 18080/" $f
