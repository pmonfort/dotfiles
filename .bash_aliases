################################################################################
#                                                                              #
#                                    Aliases                                   #
#                                                                              #
################################################################################

# generic

if [[ "$OSTYPE" =~ "linux" ]]; then
  alias ls='ls --color=auto -h'
else
  alias ls='ls -Gh'
fi

alias ll='ls -l'
alias la='ls -la'
alias lt='ls -lt' # order by last modified date

alias ..='cd ..'
alias path='echo $PATH | tr ":" "\n"'

# programs
alias egrep='grep -Ern --color=auto'
alias c='clear'
alias hist='history | grep $1'

