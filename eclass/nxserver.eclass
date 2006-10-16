# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/nxserver.eclass,v 1.20 2006/10/14 20:27:21 swegener Exp $
#
# eclass for handling the different nxserver binaries available
# from nomachine's website

inherit rpm


HOMEPAGE="http://www.nomachine.com/"
IUSE=""
LICENSE="nomachine"
SLOT="0"
KEYWORDS="x86 -ppc -sparc -alpha -mips"
RESTRICT="nomirror strip"

SRC_URI="nxserver-${MY_PV}.i386.rpm"
RDEPEND=">=media-libs/jpeg-6b-r3
	>=sys-libs/glibc-2.3.2-r1
	>=sys-libs/zlib-1.1.4-r1
	virtual/x11
	>=net-misc/openssh-3.6.1_p2
	>=dev-lang/perl-5.8.0-r12"

DEPEND=">=sys-apps/shadow-4.0.3-r6
	>=net-misc/openssh-3.6.1_p2"

S="${WORKDIR}"

DESCRIPTION="an X11/RDP/VNC proxy server especially well suited to low bandwidth links such as wireless, WANS, and worse"

EXPORT_FUNCTIONS pkg_nofetch src_compile src_install pkg_postinst

nxserver_pkg_nofetch () {
	eerror "This package requires you to purchase NX Server from:"
	eerror
	eerror "    http://www.nomachine.com/download.php"
	eerror
	eerror "Please purchase the *$1* edition of NX Server packaged for"
	eerror "RedHat 9.0 and put the RPM file nxserver-1.2.2-72.i386.rpm"
	eerror "into $DISTDIR/"
	eerror
	eerror "This ebuild will also work with the evaluation version of"
	eerror "the *$1* edition of NX Server packaged for RedHat 9.0"

	die "Automatic download not supported"
}

nxserver_src_compile() {
	return;
}

nxserver_src_install() {
	einfo "Installing"
	find usr/NX/lib -type l -exec rm {} \;

	# NX changed the name of the passwords sample file in 1.3.0

	for x in passwd.sample passwords.sample ; do
		if [ -f usr/NX/etc/$x ]; then
			mv usr/NX/etc/$x usr/NX/etc/`basename $x .sample`
		fi
	done

	tar -cf - * | ( cd ${D} ; tar -xf - )

	dodir /usr/NX/var
	dodir /usr/NX/var/sessions
	touch ${D}/usr/NX/var/sessions/NOT_EMPTY

	insinto /etc/env.d
	doins ${FILESDIR}/${PV}/50nxserver
}

nxserver_pkg_postinst() {

	# this is support for users upgrading from NX 1.2.2 to 1.3.0

	l_szPasswd=passwd

	if [ -f /usr/NX/etc/passwd -a -f /usr/NX/etc/passwords ]; then
		mv /usr/NX/etc/passwd /usr/NX/etc/passwords
	fi
	if [ -f /usr/NX/etc/passwords ]; then
		l_szPasswd=passwords
	fi

	l_szHome=nxhome
	if [ -d /usr/NX/home ]; then
		l_szHome=home
	fi

	if [ -d /usr/NX/nxhome -a -d /usr/NX/home ]; then
		einfo "Moving home directory of user 'nx' to /usr/NX/home"
		usermod -d /usr/NX/home nx
	fi

	# end of upgrade support

	einfo "Adding user 'nx' for the NX server"
	enewuser nx -1 /usr/NX/bin/nxserver /usr/NX/$l_szHome

	einfo "Changing permissions for files under /usr/NX"
	chown nx:root /usr/NX/etc/$l_szPasswd
	chmod 0600 /usr/NX/etc/$l_szPasswd
	chown -R nx:root /usr/NX/$l_szHome
	chown -R nx:root /usr/NX/var

	einfo "Generating SSH keys for the 'nx' user"
	if [ ! -f /usr/NX/etc/users.id_dsa ]; then
		ssh-keygen -q -t dsa -N '' -f /usr/NX/etc/users.id_dsa
	fi
	chown nx:root /usr/NX/etc/users.id_dsa
	cp -f /usr/NX/$l_szHome/.ssh/server.id_dsa.pub.key /usr/NX/$l_szHome/.ssh/authorized_keys2

	if [ ! -f /usr/NX/var/broadcast.txt ]; then
		einfo "Creating NX user registration database"
		touch /usr/NX/var/broadcast.txt
		chown nx:root /usr/NX/var/broadcast.txt

		ewarn "None of your system users are registered to use the NX Server."
		ewarn "To authorise a user, run:"
		ewarn "'/usr/NX/bin/nxserver --useradd <username>'"
	fi

	if [ ! -f /usr/NX/etc/key.txt ] ; then
		ewarn
		ewarn "You need to place your NX key.txt file into /usr/NX/etc/"
		ewarn "If you don't have one already, you can get an evaluation"
		ewarn "key, or purchase a full license, from www.nomachine.com"
		ewarn
	fi

	if [ ! -f /usr/NX/etc/node.conf ] ; then
		ewarn
		ewarn "To complete the installation, you must create a file called"
		ewarn "'/usr/NX/etc/node.conf'.  An example configuration file can"
		ewarn "be found in /usr/NX/etc"
		ewarn
	fi
}
