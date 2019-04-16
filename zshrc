# autoload and kickoff
autoload -Uz compinit colors vcs_info
colors
compinit

# history support, time reporting, auto-cd
HISTFILE=~/.zhistory
HISTSIZE=5000
SAVEHIST=5000
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt AUTO_CD
setopt PROMPT_SUBST

# history substring search
if [[ -a "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# fish-like auto-suggestions
if [[ -a "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# extra autocompletions
if [[ -a "$HOME/.zsh/zsh-completions/zsh-completions.plugin.zsh" ]]; then
    fpath=($HOME/.zsh/zsh-completions/src $fpath)
fi

# zstyle declarations
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':vcs_info:*' enable git  # I only use git
zstyle ':vcs_info:*' stagedstr ' %F{green}●%f'  # Show a green dot for staged changes
zstyle ':vcs_info:*' unstagedstr ' %F{red}●%f'  # Show a red dot for unstaged changes
zstyle ':vcs_info:git:*' check-for-changes true  # Make sure updates are live-checked
zstyle ':vcs_info:git*' formats "%F{cyan}%b%f%u%c"  # Normal format string, with unstaged/staged dots
zstyle ':vcs_info:*' actionformats '%F{cyan}%b%f|%F{yellow}%a%f%u%c'  # Format string when special actions are happening

# asdf
source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash

# prompts
_vcs_info_wrapper() {
    vcs_info
    if [[ -n "$vcs_info_msg_0_" ]]; then
        echo "${vcs_info_msg_0_}"
    fi
}
_setup_ps1() {
  PS1="%(1j.%F{red}[%j]%f .)%F{blue}%~%f %(!.%F{red}#%f .)$ "
  RPROMPT=$'$(_vcs_info_wrapper)'
}
_setup_ps1

# env
export EDITOR=nvim
export PATH=~/bin:$PATH

# dev aliases
alias ll="ls -FlaGh"
alias resource="source ~/.zshrc"
alias mkdir="mkdir -p"
alias s="subl"

# git aliases
alias gco="git checkout"
alias gcl="git clone"
alias gc="git commit -v -S"
alias gs="git status"
alias ga="git add"
alias gd="git diff"
alias gll="git pull"
alias grc="git rebase --continue"

# git functions
function git-branch-name() {
    git rev-parse --abbrev-ref HEAD
}
function git-current-remote() {
    git config branch.$(git-branch-name).remote
}
function grevs() {
    git rev-list --count $1..
}
function gp() {
	if [[ $(git-current-remote | head -c1 | wc -c) -ne 0 ]]; then
    	git push $(git-current-remote) $(git-branch-name)
	else
    	git push --set-upstream origin $(git-branch-name)
	fi
}
function gll() {
    REMOTE=${1:-$(git-current-remote)}
    git pull $REMOTE $(git-branch-name)
}
function gfp() {
    git push -f origin $(git-branch-name)
}
function gfu() {
    BRANCH=$(git-branch-name)
    git fetch upstream $BRANCH && git merge upstream/$BRANCH
}
function gtg=() {
    git tag -s $1 && gp && gp --tags
}
function git-prune-branches() {
    REMOTE=$1
    git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep $REMOTE) | awk '{print $1}' | xargs git branch -d
}

# docker aliases
alias dc="docker-compose"
alias dcb="docker-compose build"
alias dcbp="docker-compose build --pull"
alias dcr="docker-compose run --rm"
alias dcu="docker-compose up"
