## Vim-Config
This is personal a vim-config repository


## Dependence
1. universal-ctags
2. gtags


## Install Guide

## git clone low speed

change `github.com` -> `github.com.cnpmjs.org` or `git.sdut.me`

### oh-my-zsh

```shell
# git clone -> .oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```


### YCM

```shell
./install.py --clangd-completer
# git submodule update --init
```

### ctags

```shell
git clone https://github.com/universal-ctags/ctags.git ./.third_module/ctags
./autogen.sh
./configure --prefix=~/lcoal
```

### neovim
```shell
./config/nvim/init.vim
pip3 install wheel --user
python3 setup.py bdist_wheel
pip3 install pynvim --user
# handle esc problem ...
```


### semshi
```shell
python3 setup.py bdist_wheel
# vim :UpdateRemotePlugins
```


### python3
mean of `python3 setup.py bdist_xxx`


### nvidia-driver
[tutorial](https://juejin.cn/post/6844903904077938701)
