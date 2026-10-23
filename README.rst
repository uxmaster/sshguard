========
SSHGuard (fork)
========
**sshguard** protects hosts from brute-force attacks against SSH and other
services. It aggregates system logs and blocks repeat offenders using one of
several firewall backends.

**This is my fork of the original SSHGuard**, packaged for
`Devuan <https://www.devuan.org/>`_.

Public Git mirrors of my Mercurial repo:

- `uxmaster-sshguard on GitLab <https://gitlab.com/uxmaster/sshguard>`_
- `uxmaster-sshguard on GitHub <https://github.com/uxmaster/sshguard>`_


Upstream
==========

- Website: https://www.sshguard.net/
- Bitbucket: https://bitbucket.org/sshguard/sshguard/


My changes
==========

I've added attack signatures for my app server in `Bun <https://bun.sh/>`_::

    [addr] 40[014]{1} [/]?{WORD}.*

So it catches lines like::

    [6.6.6.3] 401 Session
    [6.6.6.0] 401 /login wtf@example.com
    [2001:db8::a11:beef:7ac1] 404 /reset/:token

See `<src/parser/tests.txt>`_ for more examples of log lines describing
attacks (those with ``999 ...``) and normal events (resulting in ``*``).

I've also added attack signatures for `coturn <https://github.com/coturn/coturn>`_.
Each matching Coturn log line scores 1 point: SSL shutdowns, socket buffer
errors with an empty user over TCP or TLS/TCP, and ``reason: general`` closures
with an empty user. Matching lines from the same session each add a point.
Session IDs are checked as part of the log format, without storing or
correlating them.
With verbose logging enabled, the Coturn fork includes the request IP in
existing ``INFO`` error records. SSHGuard scores 1 point only for final
``message`` and ``CONNECTION_BIND`` records for error 400 with
``User name is too long``, ``wrong username``, or ``Nonce is too long``.
Intermediate method records
are ignored to avoid counting the same rejected request twice. The fork
reports these format failures in the existing verbose request log, without
echoing the rejected username in a separate ``ERROR`` record. These records
detect malformed requests inside an open connection, without a per-session
score limit. Ordinary 401 challenges,
``Wrong nonce``, ``Stale nonce``, and allocation credential mismatches are
not matched by these rules. Other request floods still require their own
server-side detection.

For all the changes, consult `<debian/changelog>`_.


Installation
============
See `<INSTALL.rst>`_ for detailed instructions.

Briefly:

Download the source code from this repo first. Then extract it somewhere
and go into the extracted directory (the one which contains README.rst).

Install build dependencies (assuming `Devuan <https://www.devuan.org/>`_ or derivatives)::

    sudo apt install build-essential debhelper devscripts byacc flex python3-docutils expect

From version 2.4.3-2 of sshguard the required version of ``byacc`` is
``1:2.0.20220114-1`` or later which is provided by Devuan 5 Daedalus.

Then build a binary ``deb`` package::

    debuild -i -us -uc -b

Install the package::

    sudo dpkg -i `ls -tr ../uxmaster-sshguard_*.deb | tail -1`


Usage
=====
It should start out of the box with SysV init or runit-init. With runit-run
under SysV init, switching SSHGuard to runit supervision is an explicit
administrator choice::

    service sshguard stop
    update-service --add /etc/sv/sshguard

Under runit, the dedicated logger writes to ``/var/log/runit/sshguard``.

The runit service creates the ``sshguard`` chains and connects them at the
start of IPv4 and IPv6 ``INPUT`` when it starts. Its ``finish`` script removes
the jumps and flushes and deletes the chains, including after a daemon crash.
Blocked addresses are blocked for all incoming protocols and ports; configure
trusted addresses in the whitelist. After replacing the firewall rules with
``iptables-restore``/``ip6tables-restore``, restart SSHGuard to restore its jumps.
With SysV init, configure the firewall as described in ``sshguard-setup(7)``.

``debian/test-runit-iptables`` checks IPv4/IPv6 packet blocking and the runit
scripts in an isolated user/network namespace on Linux, with daemon execution
stubbed. It needs iptables, iproute2, Python 3 and permission to create these
namespaces, and does not change the host firewall. The Debian package build
runs it, or skips it when these prerequisites are unavailable.

You can always tweak
``/etc/sshguard/sshguard.conf`` to your needs (see
`<examples/sshguard.conf.sample>`_ for examples).

To whitelist some hosts add them to ``/etc/sshguard/whitelist``.

You can find the setup
instructions in `sshguard-setup(7) <doc/sshguard-setup.7.rst>`_.
See `sshguard(8) <doc/sshguard.8.rst>`_ for additional options.


Troubleshooting
===============
See the "Troubleshooting" section in `sshguard-setup(7)
<doc/sshguard-setup.7.rst>`_.


Contributing
============
See `<CONTRIBUTING.rst>`_.


License
=======
**sshguard** is available under the terms of the `OpenBSD license
<http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/share/misc/license.template?rev=HEAD>`_,
which is based on the ISC License. See `<COPYING>`_ for details.


Authors
=======
* Michele Mazzucchi <mij@bitchx.it>,
* T.J. Jones <tjjones03@gmail.com>,
* Kevin Zheng <kevinz5000@gmail.com>
* `dr Jacek Stypuła <https://jacekstypula.pl/phd>`_ (fork maintainer)
