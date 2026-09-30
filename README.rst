========
SSHGuard (fork)
========
**sshguard** protects hosts from brute-force attacks against SSH and other
services. It aggregates system logs and blocks repeat offenders using one of
several firewall backends.

- Website: https://www.sshguard.net/
- Bitbucket: https://bitbucket.org/sshguard/sshguard/

**This is my fork of the original SSHGuard.**


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

If not, you can always tweak
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
