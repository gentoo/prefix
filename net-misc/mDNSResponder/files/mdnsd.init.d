#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/mDNSResponder/files/mdnsd.init.d,v 1.2 2005/08/27 16:46:45 greg_g Exp $

opts="${opts} reload dump"

depend() {
	after net
}

start() {
	ebegin "Starting mdnsd"
	start-stop-daemon --start --quiet --pidfile /var/run/mdnsd.pid \
		--exec /usr/sbin/mdnsd

	eend $? "Failed to start mdnsd"
}

stop() {
	ebegin "Stopping mdnsd"
	start-stop-daemon --stop --quiet --pidfile /var/run/mdnsd.pid
	eend $? "Failed to stop mdnsd"
}

reload() {
	ebegin "Reloading mdnsd"
	kill -HUP `cat /var/run/mdnsd.pid` >&/dev/null
	eend $? "Failed to reload mdnsd"
}

dump() {
	ebegin "Dump mdnsd state to logs"
	kill -USR1 `cat /var/run/mdnsd.pid` >&/dev/null
	eend $? "Failed to dump mdnsd state"
}
