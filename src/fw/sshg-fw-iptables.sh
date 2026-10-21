#!/bin/sh
# sshg-fw-iptables
# This file is part of SSHGuard.

run_iptables() {
    cmd=iptables
    if [ "6" = "$2" ]; then
        cmd=ip6tables
    fi

    # Check if iptables supports the '-w' flag.
    if $cmd -w -V >/dev/null 2>&1; then
        $cmd -w $1
    else
        $cmd $1
    fi
}

fw_init() {
    for family in 4 6; do
        run_iptables "-n -L sshguard" "$family" >/dev/null 2>&1 ||
            run_iptables "-N sshguard" "$family" || return 1
        run_iptables "-C INPUT -j sshguard" "$family" >/dev/null 2>&1 ||
            run_iptables "-I INPUT -j sshguard" "$family" || return 1
    done
}

fw_block() {
    run_iptables "-I sshguard -s $1/$3 -j DROP" $2
}

fw_release() {
    run_iptables "-D sshguard -s $1/$3 -j DROP" $2
}

fw_flush() {
    run_iptables "-F sshguard" 4
    run_iptables "-F sshguard" 6
}

fw_fin() {
    run_iptables "-D INPUT -j sshguard" 4 >/dev/null 2>&1 || true
    run_iptables "-D INPUT -j sshguard" 6 >/dev/null 2>&1 || true
}
