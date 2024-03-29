# Change LibreSSL to OpenSSL
# http://tec-shi.com/mac/596/
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"

# Use GNU Command
# https://yu8mada.com/2018/07/25/install-gnu-commands-on-macos-with-homebrew/
export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/findutils/libexec/gnuman:$MANPATH"
export MANPATH="/usr/local/opt/gnu-tar/libexec/gnuman:$MANPATH"
export MANPATH="/usr/local/opt/grep/libexec/gnuman:$MANPATH"
export MANPATH="/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH"

# Use pyenv
# https://qiita.com/1000ch/items/93841f76ea52551b6a97
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Excule pyenv path
# https://qiita.com/yutoman027/items/ae11bf22bdbcd645c92a#7%E8%A7%A3%E6%B1%BA%E6%96%B9%E6%B3%95%E3%81%8C%E3%82%8F%E3%81%8B%E3%82%8B
alias brew='PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin brew'

# Show AWS Profile
# https://qiita.com/hirokoji/items/1ae81eec66fd9b3ff9f9
alias awsp=aws_profile_update
function aws_profile_update() {

   PROFILES=$(aws configure list-profiles)
   PROFILES_ARRAY=($(echo $PROFILES))
   SELECTED_PROFILE=$(echo $PROFILES | peco)

   [[ -n ${PROFILES_ARRAY[(re)${SELECTED_PROFILE}]} ]] && export AWS_PROFILE=${SELECTED_PROFILE}; echo 'Updated profile' || echo ''
}

# awscli completer
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html#cli-command-completion-enable
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws

# fzf settings
# https://petitviolet.hatenablog.com/entry/20190708/1562544000#fzf%E3%81%AE%E3%82%B0%E3%83%AD%E3%83%BC%E3%83%90%E3%83%AB%E8%A8%AD%E5%AE%9A
export FZF_DEFAULT_OPTS="--height 70% --no-sort --exact --cycle --multi --ansi --reverse --border --sync --bind=ctrl-t:toggle --bind=ctrl-k:kill-line --bind=?:toggle-preview --bind=down:preview-down --bind=up:preview-up"

# Search for ~/.ssh/config w/ fzf 
# https://qiita.com/kamykn/items/9a831862038efa4e9f8f
fssh() {
    local sshLoginHost
    sshLoginHost=`cat ~/.ssh/config | grep -i ^host | awk '{print $2}' | fzf`

    if [ "$sshLoginHost" = "" ]; then
        # ex) Ctrl-C.
        return 1
    fi

    badge ${sshLoginHost}
    ssh ${sshLoginHost}
}
alias fsshls='cat ~/.ssh/config | fgrep Host\ | awk '\''{print $2}'\'''

# Search for history w/ fzf
# https://tech-blog.sgr-ksmt.org/2016/12/10/smart_fzf_history/
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

# git checkout branchをfzfで選択
# https://www.rasukarusan.com/entry/2018/08/14/083000
alias co='git checkout $(git branch -a | tr -d " " |fzf --height 100% --prompt "CHECKOUT BRANCH>" --preview "git log --color=always {}" | head -n 1 | sed -e "s/^\*\s*//g" | perl -pe "s/remotes\/origin\///g")'

# # fd - cd to selected directory
# https://sourabhbajaj.com/mac-setup/iTerm/fzf.html
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fh - search in your command history and execute selected command
# https://sourabhbajaj.com/mac-setup/iTerm/fzf.html
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fgを使わずctrl+zで行ったり来たりする
# https://www.rasukarusan.com/entry/2018/08/14/083000
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# fshow - git commit browser
# https://qiita.com/kamykn/items/aa9920f07487559c0c7e#fshow
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Gmail Permalink Maker
# Usage: mkgp [Message-ID]
function mkgp {
    ruby -r cgi -e "puts 'https://mail.google.com/mail/u/0/?zx=2loke8hd7o7q#search/in%3Aanywhere+rfc822msgid%3A' + CGI.escape(\""$1"\")"
}

# item2 Badge
# https://www.rasukarusan.com/entry/2019/04/13/180443
function badge() {
    printf "\e]1337;SetBadgeFormat=%s\a"\
    $(echo -n "$1" | base64)
}

# cd & ls
# https://qiita.com/Kakuni/items/a8025e075926272f491d
function cd(){
    builtin cd $@ && ls;
}

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh setting
setopt append_history
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_no_store
setopt hist_reduce_blanks
setopt share_history
zstyle ':completion:*:default' menu select=2

# https://timesaving.hatenablog.com/entry/2020/12/05/210000
export HISTSIZE=100000
export SAVEHIST=100000

# https://analytics-note.xyz/mac/mac-lscolors/
export LSCOLORS=gxfxcxdxbxegedabagacad

# https://qiita.com/mikan3rd/items/d41a8ca26523f950ea9d
source ~/.zsh/git-prompt.sh
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
autoload -Uz compinit && compinit

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

setopt PROMPT_SUBST ; PS1='%F{green}%n@%m%f: %F{cyan}%~%f %F{yellow}$(__git_ps1 "(%s)")%f
%% '
