# .bashrc

# Source global definitions
# Enable programmable completion features for ubuntu.
if [ -f /etc/profile.d/bash_completion.sh ]; then
    source /etc/profile.d/bash_completion.sh
fi

# Set default editor
export VISUAL=vim
EDITOR=vim
export EDITOR

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[38;5;221m'
export LESS_TERMCAP_md=$'\E[38;5;221m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;35m'

# Load composure first, so we support function metadata
. "${HOME}/custom_bashrc/modules/composure.sh"
# support 'plumbing' metadata
cite _about _param _example _group _author _version

# Source bashrc assets
. "${HOME}/custom_bashrc/theme_settings.sh"
. "${HOME}/custom_bashrc/bashrc_assets/_bash_colour_functions.sh"
. "${HOME}/custom_bashrc/bashrc_assets/_bash_helper_functions.sh"
. "${HOME}/custom_bashrc/bashrc_assets/_bash_colour_defs.sh"
. "${HOME}/custom_bashrc/bashrc_assets/_bash_git_functions.sh"
. "${HOME}/custom_bashrc/bashrc_assets/_bash_aliases.sh"

# source aliases
. "${HOME}/custom_bashrc/aliases/docker_aliases.sh"
. "${HOME}/custom_bashrc/aliases/docker-compose_aliases.sh"
. "${HOME}/custom_bashrc/aliases/git_aliases.sh"
. "${HOME}/custom_bashrc/aliases/apt_aliases.sh"
. "${HOME}/custom_bashrc/aliases/curl_aliases.sh"

# source completions
. "${HOME}/custom_bashrc/completions/docker_completion.sh"
. "${HOME}/custom_bashrc/completions/docker-compose_completion.sh"
. "${HOME}/custom_bashrc/completions/awscli_completion.sh"
. "${HOME}/custom_bashrc/completions/export_completion.sh"
. "${HOME}/custom_bashrc/completions/git_completion.sh"
. "${HOME}/custom_bashrc/completions/ssh_completion.sh"
. "${HOME}/custom_bashrc/completions/terraform_completion.sh"

# source bash modules
. "${HOME}/custom_bashrc/modules/aws_module.sh"
. "${HOME}/custom_bashrc/modules/base_module.sh"
. "${HOME}/custom_bashrc/modules/docker_module.sh"
. "${HOME}/custom_bashrc/modules/docker-compose_module.sh"
. "${HOME}/custom_bashrc/modules/git_module.sh"
. "${HOME}/custom_bashrc/modules/explain_module.sh"
. "${HOME}/custom_bashrc/modules/history_module.sh"
. "${HOME}/custom_bashrc/modules/ssh_module.sh"

# User specific aliases and functions
# https://superuser.com/questions/288714/bash-autocomplete-like-zsh
bind 'set show-all-if-ambiguous on'
bind 'set colored-completion-prefix on'
#bind 'TAB:menu-complete'

FULL_PROMPT="$SET_FULL_PROMPT" # set in theme_settings.sh
if [ "$FULL_PROMPT" == "yes" ]; then

    function prompt_command() {
        ###################################################
        ### identify success/fail status of last command
        ### DO NOT MOVE THIS VARIABLE: must be first!
        local last_status="$?"
        ###################################################
        ###################################################
        ### Setup if else for different color themes
        PATH_COL_VAR="${SET_PATHCOL_VAR}"
        PATH_COL="${SET_PATHCOL}"
        THEME_VAR="${SET_THEME_VAR}"
        BARCOL="${SET_BARCOL}"
        TXTCOL="${SET_TXTCOL}"

        ###################################################
        ### Turn the prompt symbol red if the user is root
        ### root stuff
        if [[ $(id -u) -eq 0 ]]; then
            ### root color
            BARCOL="${MORANGE}"
            TXTCOL="${RED}"
            local ENDBIT="#"
        else
            local ENDBIT="$"
        fi # root bit

        ###################################################
        ### Display virtual environment notification  if applicable
        ## disable the default virtualenv prompt change
        export VIRTUAL_ENV_DISABLE_PROMPT=1

        VIRTENV=$(virtualenv_info)

        ### Display ssh variable notification in prompt if applicable
        SSH_SESSION=$(ssh_info)

        ### Display AWS profile if applicable
        CURR_AWS_PROFILE=$(aws_info)

        # Display tty no in prompt
        local TTY_VAR=`tty 2> /dev/null | awk -F/ '{nlast = NF 0;print $nlast$NF": "}'`

        ###################################################
        ### set color coded error string for prompt depending on success of last command
        if [[ $last_status == 0 ]]; then
            ERRPROMPT="\[\033[1;1;32m\]${ENDBIT} "
        else
            ERRPROMPT='\[\033[1;1;31m\]X '
        fi

        ###################################################
        ### set titlebar
        local TITLEBAR=`pwdtail`
        echo -ne '\033]2;'${TTY_VAR}${TITLEBAR}'\007'

## move out of indented tabs to avoid formatting horror (still in function)
PS1="${debian_chroot:+($debian_chroot)}\n\
${BARCOL}┌──\
${TXTCOL}[\u]\
${BARCOL}─\
${TXTCOL}[\H]\
$(parse_git)\
${VIRTENV}${SSH_SESSION}${CURR_AWS_PROFILE}
${BARCOL}│${DKGRAY}${TTY_VAR}${PATH_COL}> \w \
\n${BARCOL}└──\
${TXTCOL}`date +"%H:%M"`\
${BARCOL}─\
${ERRPROMPT}${TERGREEN}"
}

else
    function prompt_command() {
        ###################################################
        ### identify success/fail status of last command
        ### DO NOT MOVE THIS VARIABLE: must be first!
        local last_status="$?"
        ################################################

        PATH_COL_VAR="${SET_PATHCOL_VAR}"
        PATH_COL="${SET_PATHCOL}"
        THEME_VAR="${SET_THEME_VAR}"
        BARCOL="${SET_BARCOL}"
        TXTCOL="${SET_TXTCOL}"

        ###################################################
        ### Turn the prompt symbol red if the user is root
        ### root stuff
        if [[ $(id -u) -eq 0 ]]; then
            ### root color
            BARCOL="${MORANGE}"
            TXTCOL="${RED}"
            local ENDBIT="#"
        else
            local ENDBIT="$"
        fi # root bit

        ###################################################
        ### Display virtual environment notification  if applicable
        ## disable the default virtualenv prompt change
        export VIRTUAL_ENV_DISABLE_PROMPT=1

        VIRTENV=$(virtualenv_min_info)

        ### Display AWS profile if applicable
        CURR_AWS_PROFILE=$(aws_info)        

        ### get parent directory
        FULL_PATH=$(pwd)
        LAST2_DIR=${FULL_PATH#"${FULL_PATH%/*/*}/"}

        #DRIVE_PATH=$(df . | tail -1 | awk '{print $1}')
        #DRIVE_ID=${DRIVE_PATH#"${DRIVE_PATH%/*}/"}
        ### set color coded error string for prompt depending on success of last command
        if [[ $last_status == 0 ]]; then
            ERRPROMPT="\[\033[1;1;32m\]${ENDBIT} "
        else
            ERRPROMPT='\[\033[1;1;31m\]X '
        fi

## move out of indented tabs to avoid formatting horror (still in function)
PS1="${debian_chroot:+($debian_chroot)}\n\
${BARCOL}\
${TXTCOL}(\u@\H)\
${BARCOL}─${GRAY}(${GRAY}${LAST2_DIR})\
$(parse_git_minimal)\
${BARCOL}\
${RED}${CURR_AWS_PROFILE}${VIRTENV}\[\033[1;1;32m\]\n\
${GRAY} `date +"%H:%M"` ${ERRPROMPT} ${TERGREEN}"
}

fi

# history guide: https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend

PROMPT_COMMAND="prompt_command"
