export EDITOR='vim'
export TERM='xterm-256color'
export PS1="\u@\h:\[\e[36m\]\w\[\e[0m\]\$ "
export PREFIX='/usr'
export VALGRIND_LIB='/usr/lib/valgrind'
export LD_LIBRARY_PATH="/data/phonelibs:$LD_LIBRARY_PATH"

export QT_QPA_EGLFS_HIDECURSOR=1
export QT_QPA_EVDEV_TOUCHSCREEN_PARAMETERS=/dev/input/event1:rotate=270
export QT_QPA_FONTDIR=/usr/share/fonts
export QT_QPA_EGLFS_PHYSICAL_WIDTH=151
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=74

# add these symlinks if you want
export PYTHONPATH="/data/pythonpath:/data/pythonpath/pyextra"
export GIT_SSH_COMMAND="ssh -i /data/gitkey"
export LANG="en_US.UTF-8"

export VIMINIT='source $MYVIMRC'
export MYVIMRC="/data/data/com.termux/files/home/.vimrc"

# Disable history writing
export PYTHONSTARTUP="/data/data/com.termux/files/home/.pythonrc"
