# prompt style and colors based on Steve Losh's Prose theme:
# https://github.com/sjl/oh-my-zsh/blob/master/themes/prose.zsh-theme
#
# vcs_info modifications from Bart Trojanowski's zsh prompt:
# http://www.jukie.net/bart/blog/pimping-out-zsh-prompt
#
# git untracked files modification from Brian Carper:
# https://briancarper.net/blog/570/git-info-in-your-zsh-prompt

export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('%F{blue}`basename $VIRTUAL_ENV`%f') '
}
PR_GIT_UPDATE=1

setopt prompt_subst

autoload -U add-zsh-hook
#autoload -Uz vcs_info

#use extended color palette if available
if [[ $terminfo[colors] -ge 256 ]]; then
    turquoise="%F{81}"
    orange="%F{166}"
    purple="%F{135}"
    hotpink="%F{161}"
    limegreen="%F{118}"
    nodejs="%F{106}"
    angular="%F{160}"
    react="%F{81}"
    nix="%F{68}"
else
    turquoise="%F{cyan}"
    orange="%F{yellow}"
    purple="%F{magenta}"
    hotpink="%F{red}"
    limegreen="%F{green}"
    nodejs="%F{green}"
    angular="%F{red}"
    react="%F{blue}"
    nix="%F{blue}"
fi

reset_color="%f"

# Show node.js version if available
function node_js_info {
    [ ! -f package.json ] && exit
    if command -v node &> /dev/null; then
      NODE_VERSION=$(node --version | tr -d "v")
      echo "${nodejs} $NODE_VERSION${reset_color}"
    fi
}

# Show Angular version if available
function angular_info {
    # check requirements (jq to extract version)
    command -v jq &> /dev/null || exit
    
    ANGULAR_FILE=node_modules/@angular/core/package.json

    [ ! -f package.json -o ! -f $ANGULAR_FILE ] && exit

    ANGULAR_VERSION=$(jq .version $ANGULAR_FILE | tr -d '"')

    echo "${angular} $ANGULAR_VERSION${reset_color}"
}

# Show React version if available
function react_info {
    # check requirements (jq to extract version)
    command -v jq &> /dev/null || exit

    REACT_FILE=node_modules/react/package.json

    [ ! -f package.json -o ! -f $REACT_FILE ] && exit

    REACT_VERSION=$(jq .version $REACT_FILE | tr -d '"')

    echo "${react} $REACT_VERSION${reset_color}"
}

# Show Nix shell information if available
function nix_shell_prompt {
  if [[ -n "$IN_NIX_SHELL" ]]; then
    echo "${nix}( nix, $IN_NIX_SHELL)${reset_color} "
  fi
}

# enable VCS systems you use
# zstyle ':vcs_info:*' enable git svn
# zstyle ':vcs_info:*' enable svn

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
# zstyle ':vcs_info:*:prompt:*' check-for-changes true
# zstyle ':vcs_info:*:prompt:*' check-for-changes false

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stagedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
PR_RST="%f"
FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
FMT_ACTION="(%{$limegreen%}%a${PR_RST})"
FMT_UNSTAGED="%{$orange%}●"
FMT_STAGED="%{$limegreen%}●"

# zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
# zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
# zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
# zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
# zstyle ':vcs_info:*:prompt:*' nvcsformats   ""


function steeef_preexec {
    case "$2" in
        *git*)
            PR_GIT_UPDATE=1
            ;;
        *hub*)
            PR_GIT_UPDATE=1
            ;;
        *svn*)
            PR_GIT_UPDATE=1
            ;;
    esac
}
# add-zsh-hook preexec steeef_preexec

function steeef_chpwd {
    PR_GIT_UPDATE=1
}
# add-zsh-hook chpwd steeef_chpwd

function steeef_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]] ; then
        # check for untracked files or updated submodules, since vcs_info doesn't
        if git ls-files --other --exclude-standard 2> /dev/null | grep -q "."; then
            PR_GIT_UPDATE=1
            FMT_BRANCH="(%{$turquoise%}%b%u%c%{$hotpink%}●${PR_RST})"
        else
            FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
        fi
        zstyle ':vcs_info:*:prompt:*' formats "${FMT_BRANCH} "

        vcs_info 'prompt'
        PR_GIT_UPDATE=
    fi
}
# add-zsh-hook precmd steeef_precmd

PROMPT=$'
%{$purple%}%n${PR_RST} at %{$orange%}%m${PR_RST} in %{$limegreen%}%~${PR_RST} $(nix_shell_prompt) $(node_js_info) $(react_info) $(angular_info) $vcs_info_msg_0_$(virtualenv_info)
$ '
