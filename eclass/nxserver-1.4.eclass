# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/nxserver-1.4.eclass,v 1.13 2007/04/13 16:56:42 voyageur Exp $
#
# DEPRECATED
# eclass for handling the different nxserver binaries available
# from nomachine's website
#
# now handles freenx as well

inherit rpm eutils


HOMEPAGE="http://www.nomachine.com/"
IUSE=""
LICENSE="nomachine"
SLOT="0"
RESTRICT="nomirror strip"

SRC_URI="nxserver-${MY_PV}.i386.rpm"
DEPEND=">=sys-apps/shadow-4.0.3-r6
	>=net-misc/openssh-3.6.1_p2
	=net-misc/nxssh-1.4*
	=net-misc/nxproxy-1.4*
	=net-misc/nxclient-1.4*
	=net-misc/nx-x11-1.4*"

RDEPEND=">=media-libs/jpeg-6b-r3
	>=sys-libs/glibc-2.3.2-r1
	>=sys-libs/zlib-1.1.4-r1
	>=net-misc/openssh-3.6.1_p2
	>=dev-lang/perl-5.8.0-r12"

S="${WORKDIR}"

DESCRIPTION="an X11/RDP/VNC proxy server especially well suited to low bandwidth links such as wireless, WANS, and worse"

EXPORT_FUNCTIONS pkg_setup src_compile src_install pkg_postinst

nxserver-1.4_pkg_setup() {
	einfo "Adding user 'nx' for the NX server"
	enewuser nx -1 -1 /usr/NX/home/nx
}

nxserver-1.4_src_compile() {
	return;
}

nxserver-1.4_src_install() {
	einfo "Installing"
	find usr/NX/lib -type l -exec rm {} \;

	# NX changed the name of the passwords sample file in 1.3.0

	for x in passwd.sample passwords.sample ; do
		if [ -f usr/NX/etc/$x ]; then
			mv usr/NX/etc/$x usr/NX/etc/`basename $x .sample`
		fi
	done

	# remove binaries installed by other packages
	for x in nxagent nxdesktop nxpasswd nxviewer ; do
		if [ -f usr/NX/bin/$x ]; then
			rm -f usr/NX/bin/$x
		fi
	done

	# remove libraries installed by other packages
	for x in usr/NX/lib/*.so.* ; do
		if [ -f $x ]; then
			rm -f $x
		fi
	done

	tar -cf - * | ( cd ${D} ; tar -xf - )

	dodir /usr/NX/var
	keepdir /usr/NX/var/sessions

	doenvd ${FILESDIR}/1.3.0/50nxserver
}

nxserver-1.4_pkg_postinst() {

	# arg - the 'nx' user's home directory keeps moving
	#
	# release		user		homedir
	# 1.2.2			nx			/usr/NX/home/nx
	# 1.3.0			nx			/usr/NX/home
	# 1.3.2			nx			/usr/NX/home/nx
	# 1.4.0			nx			/usr/NX/home/nx

	l_szPasswd=passwd

	if [ -f /usr/NX/etc/passwd -a -f /usr/NX/etc/passwords ]; then
		mv /usr/NX/etc/passwd /usr/NX/etc/passwords
	fi
	if [ -f /usr/NX/etc/passwords ]; then
		l_szPasswd=passwords
	fi

	# end of upgrade support

	# now that nxserver has been installed, we can change the shell
	# of the nx user to be the correct one

	echo "Setting nx's homedir to /usr/NX/bin/nxserver"
	chsh -s /usr/NX/bin/nxserver nx

	# we do this to move the home directory of older installs

	einfo "Setting home directory of user 'nx' to /usr/NX/home/nx"
	usermod -d /usr/NX/home/nx nx

	einfo "Changing permissions for files under /usr/NX"
	chown nx:root /usr/NX/etc/$l_szPasswd
	chmod 0600 /usr/NX/etc/$l_szPasswd
	chown -R nx:root /usr/NX
	chmod u+x /usr/NX/var/db/*
	chmod 755 /usr/NX/etc

	einfo "Generating SSH keys for the 'nx' user"
	if [ ! -f /usr/NX/etc/users.id_dsa ]; then
		ssh-keygen -q -t dsa -N '' -f /usr/NX/etc/users.id_dsa
	fi
	chown nx:root /usr/NX/etc/users.id_dsa

	cp -f /usr/NX/home/nx/.ssh/server.id_dsa.pub.key /usr/NX/home/nx/.ssh/authorized_keys2
	chown nx:root /usr/NX/home/nx/.ssh/authorized_keys2
	chmod 0600 /usr/NX/home/nx/.ssh/authorized_keys2

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
		ewarn "The key.txt file must be chmod'd 0400 and must owned by"
		ewarn "by the 'nx' user."
	fi

	if [ ! -f /usr/NX/etc/node.conf ] ; then
		ewarn
		ewarn "To complete the installation, you must create a file called"
		ewarn "'/usr/NX/etc/node.conf'.  An example configuration file can"
		ewarn "be found in /usr/NX/etc"
	fi

	# regen the ld.so cache, because Portage sometimes doesn't
	ldconfig -v > /dev/null 2>&1
}
