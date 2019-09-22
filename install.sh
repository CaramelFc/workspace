# install third module

set -e

mkdir -p .third_module

mkdir -p /tmp/vim-config-log

current_root_dir=`pwd`

universal_ctags(){
    mkdir -p .third_module/ctags
    git clone https://github.com/universal-ctags/ctags.git ./.third_module/ctags
    cd .third_module/ctags && ./autogen.sh
    mkdir build && ./configure --prefix=`pwd`"/build"
    make
    make install
    cd $current_root_dir
    echo "export PATH=~/.vim/.third_module/ctags/build/bin:\$PATH" >> env.sh
    touch /tmp/vim-config-log/universal_ctags
}

gtags(){
    pip install pygments --user
    echo 'let $GTAGSLABEL = "native-pygments"' >> $current_root_dir/init/init-config-dependence.vim
    mkdir -p .third_module/gtags && cd .third_module/gtags
    wget "http://tamacom.com/global/global-6.6.3.tar.gz"
    tar -xzf global-6.6.3.tar.gz && mkdir -p build
    cd global-6.6.3 && ./configure --prefix=`pwd`"/../build"
    make
    make install
    cd $current_root_dir
    echo "export PATH=~/.vim/.third_module/gtags/build/bin:\$PATH" >> env.sh
    echo 'let $GTAGSCONF = '\"$current_root_dir/.third_module/gtags/build/share/gtags/gtags.conf\" >> $current_root_dir/init/init-config-dependence.vim
    touch /tmp/vim-config-log/gtags
}


install_helper(){
    if [ ! -f /tmp/vim-config-log/$1 ]
    then
        $1
    fi
    echo $1 install successfully
}

install_helper universal_ctags
install_helper gtags
