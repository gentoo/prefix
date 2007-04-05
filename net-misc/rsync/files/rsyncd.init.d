#!@GENTOO_PORTAGE_EPREFIX@/sbin/runscript
# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rsync/files/rsyncd.init.d,v 1.5 2007/02/23 11:33:59 uberlord Exp $

depend() {
	use net
}

start() {
	ebegin "Starting rsyncd"
	start-stop-daemon --start --exec @GENTOO_PORTAGE_EPREFIX@/usr/bin/rsync \
		--pidfile @GENTOO_PORTAGE_EPREFIX@/var/run/rsyncd.pid \
		-- --daemon ${RSYNC_OPTS}
	eend $?
}

stop() {
	ebegin "Stopping rsyncd"
	start-stop-daemon --stop --exec @GENTOO_PORTAGE_EPREFIX@/usr/bin/rsync \
		--pidfile @GENTOO_PORTAGE_EPREFIX@/var/run/rsyncd.pid
	eend $?
}
