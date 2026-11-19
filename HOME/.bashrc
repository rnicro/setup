[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

alias reboot='loginctl reboot'
alias poweroff='loginctl poweroff'
