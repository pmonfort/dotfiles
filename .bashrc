# RVM ruby version system
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
# [[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion

export RUBY_GC_MALLOC_LIMIT=60000000
export RUBY_FREE_MIN=200000

#if [[ "$OSTYPE" =~ "linux" ]]; then
    # export LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4.1.0
#fi

if [[ "$OSTYPE" =~ "darwin" ]]; then
    . /usr/local/git/contrib/completion/git-completion.bash
    . /usr/local/git/contrib/completion/git-prompt.sh
fi

if [[ -n "$PS1" ]]; then

    # Global path for cd (no matter which directory you're in right now)
    # export CDPATH=.:~:~/code

    # Keep 3000 lines of history
    export HISTFILESIZE=3000

    # Ignore from history repeat commands, and some other unimportant ones
    export HISTIGNORE="&:[bf]g:c:exit"

    # don't put duplicate lines in the history. See bash(1) for more options
    export HISTCONTROL=ignoredups

    # Ruby development made easier
    export RUBYOPT="-r rubygems Ilib Itest Ispec"

    # Use vim to browse man pages. One can use Ctrl-[ and Ctrl-t
    # to browse and return from referenced man pages. ZZ or q to quit.
    # NOTE: initially within vim, one can goto the man page for the
    #       word under the cursor by using [section_number]K.
    export MANPAGER='bash -c "vim -MRn -c \"set ft=man nomod nolist nospell nonu\" \
        -c \"nm q :qa!<CR>\" -c \"nm <end> G\" -c \"nm <home> gg\"</dev/tty <(col -b)"'

    export EDITOR=vim

    shopt -s checkwinsize

    # make less more friendly for non-text input files, see lesspipe(1)
    [ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

    # set current git branch in a variable
    # if [ "$(type -t __git_ps1)" = "function" ]; then
    #     git_branch=$(__git_ps1)
    # fi

    [[ "$OSTYPE" =~ "linux" ]] && eval "`dircolors -b`"

    if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
    fi

    if [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi

    [[ "$OSTYPE" =~ "linux" ]] && xhost +LOCAL:

    # export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.6/dist-packages
    # export CATALINA_HOME=/var/lib/tomcat6
    export HOSTNAME=`/bin/hostname`
    # dh_make variables
    if [[ "$OSTYPE" =~ "linux" ]]; then
        export DEBFULLNAME="Pablo Monfort"
        export DEBEMAIL=pmonfort@gmail.com
    fi

    # export PATH="$PATH:~/bin"

    # External Scripts #

    # Uncomment if you use hitch
    hitch() {
        command hitch "$@"
        if [[ -s "$HOME/.hitch_export_authors" ]]; then
            . "$HOME/.hitch_export_authors";
        fi
    };

    # if [[ $(type -t hitch) == "function" ]]; then hitch; fi
    alias unhitch='hitch -u'

    ################################################################################
    #                                                                              #
    #                                   Functions                                  #
    #                                                                              #
    ################################################################################

    lexport() {
      if [[ ! -f "./.env" ]]; then
        echo ".env file does NOT exists ..."
      else
        export $(cat "./.env" | grep -v "^#" | grep -v "^\s*$");
      fi
    }

    lexport_by_dir() {
        local dir='.env'
        local file='default'
        if [[ -n $1 && -f "$dir/$1" ]]; then
            file="$1"
        fi
        if [[ ! -f "$dir/$file" ]]; then
          echo "$dir/$file does NOT exists ..."
        else
          export $(cat "$dir/$file" | grep -v "^#" | grep -v "^\s*$");
        fi
    }

    # cd into matching gem directory
    cdgem() {
        local gempath=$(gem env gemdir)/gems
        if [[ $1 == "" ]]; then
            cd $gempath
            return
        fi

        local gem=$(ls $gempath | grep -i $1 | sort | tail -1)
        if [[ $gem != "" ]]; then
            cd $gempath/$gem
        fi
    }
    _cdgem() {
        COMPREPLY=($(compgen -W '$(ls `gem env gemdir`/gems)' -- ${COMP_WORDS[COMP_CWORD]}))
        return 0;
    }
    complete -o default -o nospace -F _cdgem cdgem;

    # Encode the string into "%xx"
    urlencode() {
        ruby -e 'puts ARGV[0].split(/%/).map{|c|"%c"%c.to_i(16)} * ""' $1
    }

    # Decode a urlencoded string ("%xx")
    urldecode() {
        ruby -r cgi -e 'puts CGI.unescape ARGV[0]' $1
    }

    b64encode() {
        ruby -e 'puts ARGV[0].unpack("m")[0]'
    }

    b64decode() {
        ruby -e 'puts ARGV[0].pack("m").gsub(/\s/, "")'
    }

    load_snapshot() {
        local dumpname=${1:-~/dump.sql.gz}
        local config=$(rfind config/database.yml) || { echo "ERROR: could not find 'config/database.yml'" >&2; return 1; }
        local database=$(ruby -ryaml -e "puts YAML.load_file('$config').fetch('development', {}).fetch('database')")

        [[ -e $dumpname ]] || { echo "ERROR: file '$dumpname' does not exist" >&2; return 1; }

        dropdb "$database" && rake db:create && gzip -d < "$dumpname" | psql "$database"
    }

    save_snapshot() {
        local dumpname=${1:-~/dump.sql.gz}
        local config=$(rfind config/database.yml) || { echo "ERROR: could not find 'config/database.yml'" >&2; return 1; }
        local database=$(ruby -ryaml -e "puts YAML.load_file('$config').fetch('development', {}).fetch('database')")

        if [[ -e $dumpname ]]; then
            read -p "file '$dumpname' exists, overwrite? " -n 1
            echo
            [[ $REPLY = [Yy] ]] || return 0
        fi

        pg_dump "$database" | gzip > "$dumpname"
    }

    ################################################################################
    #                                                                              #
    #                                     Prompt                                   #
    #                                                                              #
    ################################################################################

    # Prompt in two lines:
    #   [username] Date - Time <full path to pwd> (git: <git branch>)
    #   ▸

    # The various escape codes that we can use to color our prompt.
            RED="\[\033[0;31m\]"
          GREEN="\[\033[0;32m\]"
         PURPLE="\[\033[0;35m\]"
     LIGHT_GRAY="\[\033[0;37m\]"
           GRAY="\[\033[1;30m\]"
      LIGHT_RED="\[\033[1;31m\]"
    LIGHT_GREEN="\[\033[1;32m\]"
         YELLOW="\[\033[1;33m\]"
           BLUE="\[\033[1;34m\]"
           CYAN="\[\033[1;36m\]"
          WHITE="\[\033[1;37m\]"
     COLOR_NONE="\[\e[0m\]"

    DEFAULT_PS1="${GRAY}[ ${LIGHT_RED}\u ${GRAY}] ${YELLOW}\d - \T ${LIGHT_GREEN}\w${BLUE} \$(__git_ps1 '(git: %s)') ${WHITE}\n▸${COLOR_NONE} "

    if [ $VIRTUAL_ENV_NAME ]; then
      export PS1="${GRAY}[${CYAN} ${VIRTUAL_ENV_NAME} ${GRAY}]${DEFAULT_PS1}"
    else
      export PS1=$DEFAULT_PS1
    fi
fi

# NOTES
#######################################################
# To temporarily bypass an alias, we preceed the command with a \ 
# EG:  the ls command is aliased, but to use the normal ls command you would
# type \ls

### Added by the Heroku Toolbelt
if [[ -d  /usr/local/heroku/bin ]]; then
  export PATH="/usr/local/heroku/bin:$PATH"
fi

delete_py_cache() {
  find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
}

# Load rbenv automatically by appending
# the following to ~/.bash_profile:

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
