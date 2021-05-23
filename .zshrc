if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

################################################################################
#                                                                              #
#                                     Prompt                                   #
#                                                                              #
################################################################################

# Prompt in two lines:
#   [username] Date - Time <full path to pwd> (git: <git branch>)
#   ▸

# The various escape codes that we can use to color our prompt.
RED="160"
GREEN="34"
GRAY="8"
YELLOW="226"
BLUE="69"
WHITE="white"

NEWLINE=$'\n'



# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Git autocompletion
autoload -Uz compinit && compinit

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats ' (%b)'

# Set up the prompt (with git branch name)
setopt PROMPT_SUBST
PROMPT='%B%F{8}[%f%F{160}%n%f%F{8}]%f %F{${YELLOW}}%W-%*%f%F{${GREEN}} %~%f%F{$BLUE}${vcs_info_msg_0_}%f${NEWLINE}%F{${WHITE}}▸%f%b '

export PATH="$PATH:/usr/local/bin:/Users/fort/.rbenv/shims"
export PATH="/usr/local/opt/elasticsearch@6/bin:$PATH"
export PATH="/usr/local/opt/openjdk/bin:$PATH"


eval "$(rbenv init -)"
