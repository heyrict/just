#compdef just

autoload -U is-at-least

_just() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    local common=(
'--color=[Print colorful output]: :(auto always never)' \
'-f+[Use <JUSTFILE> as justfile.]' \
'--justfile=[Use <JUSTFILE> as justfile.]' \
'*--set[Override <VARIABLE> with <VALUE>]: :_just_variables' \
'--shell=[Invoke <SHELL> to run recipes]' \
'*--shell-arg=[Invoke shell with <SHELL-ARG> as an argument]' \
'-d+[Use <WORKING-DIRECTORY> as working directory. --justfile must also be set]' \
'--working-directory=[Use <WORKING-DIRECTORY> as working directory. --justfile must also be set]' \
'--completions=[Print shell completion script for <SHELL>]: :(zsh bash fish powershell elvish)' \
'-s+[Show information about <RECIPE>]: :_just_commands' \
'--show=[Show information about <RECIPE>]: :_just_commands' \
'(-q --quiet)--dry-run[Print what just would do without doing it]' \
'--highlight[Highlight echoed recipe lines in bold]' \
'--no-highlight[Don'\''t highlight echoed recipe lines in bold]' \
'(--dry-run)-q[Suppress all output]' \
'(--dry-run)--quiet[Suppress all output]' \
'--clear-shell-args[Clear shell arguments]' \
'*-v[Use verbose output]' \
'*--verbose[Use verbose output]' \
'--dump[Print entire justfile]' \
'-e[Edit justfile with editor given by $VISUAL or $EDITOR, falling back to `vim`]' \
'--edit[Edit justfile with editor given by $VISUAL or $EDITOR, falling back to `vim`]' \
'--evaluate[Print evaluated variables]' \
'--init[Initialize new justfile in project root]' \
'-l[List available recipes and their arguments]' \
'--list[List available recipes and their arguments]' \
'--summary[List names of available recipes]' \
'--variables[List names of variables]' \
'-h[Print help information]' \
'--help[Print help information]' \
'-V[Print version information]' \
'--version[Print version information]' \
)

    _arguments "${_arguments_options[@]}" $common \
        '1: :_just_commands' \
        '*: :->args' \
        && ret=0

    case $state in
        args)
            curcontext="${curcontext%:*}-${words[2]}:"

            local lastarg=${words[${#words}]}

            local cmds; cmds=(
                ${(s: :)$(_call_program commands just --summary)}
            )

            # Find first recipe name
            integer skip=0
            for ((i = 2; i < $#words; i++ )) do
                if [[ ${cmds[(I)${words[i]}]} -gt 0 ]]; then
                    recipe=${words[i]}
                    break
                fi
            done

            if [[ ${lastarg} = */* ]]; then
                # Arguments contain slash would be recognised as a file
                _arguments -s -S $common '*:: :_files'
            elif [[ $lastarg = *=* ]]; then
                # Arguments contain equal would be recognised as a variable
                _message "value"
            elif [[ $recipe ]]; then
                # Show usage message
                _message "`just --show $recipe`"
                # Or complete with other commands
                #_arguments -s -S $common '*:: :_just_commands'
            else
                _arguments -s -S $common '*:: :_just_commands'
            fi
        ;;
    esac

    return ret
}

(( $+functions[_just_commands] )) ||
_just_commands() {
    [[ $PREFIX = -* ]] && return 1
    integer ret=1
    local variables; variables=(
        ${(s: :)$(_call_program commands just --variables)}
    )
    local commands; commands=(
        ${${${(M)"${(f)$(_call_program commands just --list)}":#    *}/ ##/}/ ##/:Args: }
    )

    if compset -P '*='; then
        case "${${words[-1]%=*}#*=}" in
            *) _message 'value' && ret=0 ;;
        esac
    else
        _describe -t variables 'variables' variables -qS "=" && ret=0
        _describe -t commands 'just commands' commands "$@"
    fi

}

(( $+functions[_just_variables] )) ||
_just_variables() {
    [[ $PREFIX = -* ]] && return 1
    integer ret=1
    local variables; variables=(
        ${(s: :)$(_call_program commands just --variables)}
    )

    if compset -P '*='; then
        case "${${words[-1]%=*}#*=}" in
            *) _message 'value' && ret=0 ;;
        esac
    else
        _describe -t variables 'variables' variables && ret=0
    fi

    return ret
}

_just "$@"
