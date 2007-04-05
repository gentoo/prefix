# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/nxserver_1.5.eclass,v 1.5 2007/03/26 20:24:24 genstef Exp $
#
# DEPRECATED
# eclass for handling the different nxserver binaries available
# from nomachine's website
#
# now handles freenx as well

inherit rpm eutils

HOMEPAGE="http://www.nomachine.com/"
IUSE="prebuilt cups"
LICENSE="nomachine"
SLOT="0"
RESTRICT="nomirror strip fetch"

SRC_URI="nxserver-${MY_PV}.i386.rpm"
DEPEND="
			x11-proto/xproto
			x11-proto/xf86vidmodeproto
			x11-proto/glproto
			x11-proto/videoproto
			x11-proto/xextproto
			x11-proto/fontsproto
			x11-libs/libX11
			x11-libs/libFS
			x11-libs/libXvMC
			media-libs/mesa
			x11-misc/xdialog
	sys-apps/shadow
	net-misc/openssh
	!prebuilt? (
		=net-misc/nxssh-1.5*
		=net-misc/nxproxy-1.5*
		=net-misc/nx-x11-1.5*
	)
	prebuilt? (
		!net-misc/nxssh
		!net-misc/nxproxy
		!net-misc/nx-x11
		!net-misc/nxcomp
	)"

RDEPEND="media-libs/jpeg
	sys-libs/zlib
	net-misc/openssh
	dev-lang/perl
	=net-misc/nxclient-1.5*"

S="${WORKDIR}"

DESCRIPTION="an X11/RDP/VNC proxy server especially well suited to low bandwidth links such as wireless, WANS, and worse"

EXPORT_FUNCTIONS pkg_setup src_install pkg_postinst pkg_nofetch

nxserver_1.5_pkg_nofetch() {
	eerror "Please download the $MY_EDITION edition of NXServer from:"
	eerror
	eerror "    $MY_DOWNLOAD"
	eerror
	eerror "and save it onto this machine as:"
	eerror
	eerror "  ${DISTDIR}/nxserver-${MY_EDITION}-${MY_PV}.i386.rpm"
	eerror
	eerror "** NOTE the change in filename! **"
}

nxserver_1.5_pkg_setup() {
	einfo "Adding user 'nx' for the NX server"
	enewuser nx -1 -1 /usr/NX/home/nx
}

nxserver_1.5_src_install() {
	einfo "Installing"

	# remove the pre-compiled binaries and libraries, if we are not
	# to use the !M prebuilt files
	if ! useq prebuilt ; then
		find usr/NX/lib -type l -exec rm {} \;

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
	fi

	tar -cf - * | ( cd ${D} ; tar -xf - )

	dodir /usr/NX/var
	keepdir /usr/NX/var/sessions

	insinto /etc/env.d
	doins ${FILESDIR}/1.3.0/50nxserver
}

nxserver_1.5_pkg_postinst() {

	NX_ROOT=/usr/NX

	# the 'nx' user's home directory, from release to release
	#
	# release		user		homedir
	# 1.2.2			nx			/usr/NX/home/nx
	# 1.3.0			nx			/usr/NX/home
	# 1.3.2			nx			/usr/NX/home/nx
	# 1.4.0			nx			/usr/NX/home/nx
	# 1.5.0			nx			/usr/NX/home/nx

	# we do this to move the home directory of older installs
	NX_HOME=${NX_ROOT}/home/nx
	einfo "Setting home directory of user 'nx' to ${NX_HOME}"
	usermod -d ${NX_HOME} nx

	# move the passwords file if necessary
	#
	# release		passwords file
	# 1.4.0			/usr/NX/etc/passwords
	# 1.5.0			/usr/NX/etc/passwords.db

	NX_OLD_PASSWORD_DB="${NX_ROOT}/etc/passwords"
	NX_PASSWORD_DB="${NX_ROOT}/etc/passwords.db"

	if [[ -f ${NX_OLD_PASSWORD_DB} ]]; then
		mv ${NX_OLD_PASSWORD_DB} ${NX_PASSWORD_DB} || die "Unable to move passwords file"
	else
		einfo "Creating an empty password database"
		touch ${NX_PASSWORD_DB}
	fi

	chmod 0600 ${NX_PASSWORD_DB}
	chown nx:root ${NX_PASSWORD_DB}

	# move/generate the keys if necessary
	#
	# release		keys file
	# 1.4.0			/usr/NX/etc/users.id_dsa
	# 1.5.0			/usr/NX/etc/node.localhost.id_dsa.pub

	NX_OLD_SERVER_SSHKEY="${NX_ROOT}/etc/users.id_dsa"
	NX_SERVER_SSHKEY="${NX_ROOT}/etc/node.localhost.id_dsa.pub"

	if [[ -f ${NX_OLD_SERVER_SSHKEY} ]]; then
		einfo "Re-using existing SSH key"
		mv ${NX_OLD_SERVER_SSHKEY} ${NX_SERVER_SSHKEY} || die "Unable to move SSH key"
	else
		einfo "Generating SSH key for the 'nx' user"
		ssh-keygen -q -t dsa -N '' -f ${NX_SERVER_SSHKEY}
	fi
	chmod 0600 ${NX_SERVER_SSHKEY}
	chown nx:root ${NX_SERVER_SSHKEY}

	# the user's database also moves around
	#
	# release		location
	# 1.4.0			/usr/NX/etc/users
	# 1.5.0			/usr/NX/etc/users.db

	NX_OLD_USERS_DB="${NX_ROOT}/etc/users"
	NX_USERS_DB="${NX_ROOT}/etc/users.db"

	if [[ -f ${NX_OLD_USERS_DB} ]] ; then
		einfo "Re-using existing users database"
		mv ${NX_OLD_USERS_DB} ${NX_USERS_DB} || die "Unable to move users database"
	else
		einfo "Creating an empty users database"
		touch ${NX_USERS_DB}
	fi

	chmod 0600 ${NX_USERS_DB}
	chown nx:root ${NX_USERS_DB}

	# the license key file moves too
	#
	# release		location
	# 1.4.0			/usr/NX/etc/key.txt
	# 1.5.0			/usr/NX/etc/server.lic

	NX_OLD_LICENSE_KEY="${NX_ROOT}/etc/key.txt"
	NX_LICENSE_KEY="${NX_ROOT}/etc/server.lic"

	if [[ -f ${NX_OLD_LICENSE_KEY} ]]; then
		einfo "Re-using existing license key"
		mv ${NX_OLD_LICENSE_KEY} ${NX_LICENSE_KEY} || die "Unable to move license key file"
		chmod 0400 ${NX_LICENSE_KEY}
		chown nx:root ${NX_LICENSE_KEY}
	fi

	# end of upgrade support

	# now that nxserver has been installed, we can change the shell
	# of the nx user to be the correct one

	echo "Setting nx's homedir to /usr/NX/bin/nxserver"
	chsh -s /usr/NX/bin/nxserver nx

	einfo "Changing permissions for files under /usr/NX"
	chown -R nx:root /usr/NX
	chmod u+x /usr/NX/var/db/*
	chmod 755 /usr/NX/etc

	# It seems to be default.id_dsa.pub in 1.5.0
	cp -pf /usr/NX/home/nx/.ssh/default.id_dsa.pub /usr/NX/home/nx/.ssh/authorized_keys2
	chown nx:root /usr/NX/home/nx/.ssh/authorized_keys2
	chmod 0600 /usr/NX/home/nx/.ssh/authorized_keys2

	# TODO:
	# what does the broadcast.txt file really do?
	if [ ! -f /usr/NX/var/broadcast.txt ]; then
		einfo "Creating NX user registration database"
		touch /usr/NX/var/broadcast.txt
		chown nx:root /usr/NX/var/broadcast.txt

		ewarn "None of your system users are registered to use the NX Server."
		ewarn "To authorise a user, run:"
		ewarn "'/usr/NX/bin/nxserver --useradd <username>'"
	fi

	if [[ ! -f ${NX_LICENSE_KEY} ]] ; then
		ewarn
		ewarn "You need to place your NX key.txt file into /usr/NX/etc/"
		ewarn "If you don't have one already, you can get an evaluation"
		ewarn "key, or purchase a full license, from www.nomachine.com"
		ewarn
		ewarn "The key.txt file must be chmod'd 0400 and must owned by"
		ewarn "by the 'nx' user."
	fi

	if [[ ! -f ${NX_ROOT}/etc/node.cfg ]] ; then
		ewarn
		ewarn "To complete the installation, you must create a file called"
		ewarn "'/usr/NX/etc/node.cfg'.  An example configuration file can"
		ewarn "be found in /usr/NX/etc"
	fi
}
