#install vim

usage() {
    echo "Usage: install-vim"
    exit 1
}

while getopts '' o &>> /dev/null; do
    case "$o" in
    *)
        usage;;
    esac
done

apt-get -y install vim vim-scripts exuberant-ctags

# setup vim plugin
mkdir -p $HOME/.vim/bundle

pushd .
cd $HOME/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle
popd

