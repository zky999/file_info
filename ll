#!/usr/bin/env bash
_ll() {
	if [[ $# -ge 1 ]]; then
    	argv=($@)
    	if [[ "${argv[$#-1]}" != "${HOME}" ]]; then
			ls -alhF --color "$@"
		else
			ls --dereference-command-line-symlink-to-dir -alhF --color "$@"
		fi
	else
		ls -alhF --color "$@"
	fi
}

_l() {
    _ll -rt "$@"
}

bn="$(basename "$0")"
if [[ "$bn" == "ll" ]]; then
    _ll "$@"
elif [[ "$bn" == "l" ]] ; then
    _l "$@"
fi
