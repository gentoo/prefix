#!/sbin/runscript
# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/mDNSResponder/files/dnsextd.init.d,v 1.1 2005/08/27 16:46:45 greg_g Exp $

opts="${opts} dump"

depend() {
	after named
}

start() {
	if [ -z "${DNSEXTD_ZONE}" -o -z "${DNSEXTD_NAMESERVER}" ]; then
		eerror "You need to setup DNSEXTD_ZONE and DNSEXTD_NAMESERVER in /etc/conf.d/dnsextd first"
		return 1
	fi

	ebegin "Starting dnsextd"
	start-stop-daemon --start --quiet --user named \
		--pid /var/run/dnsextd.pid --exec /usr/sbin/dnsextd \
		-- -z "${DNSEXTD_ZONE}" -s "${DNSEXTD_NAMESERVER}" ${DNSEXTD_ARGS}

	eend $? "Failed to start dnsextd"
}

stop() {
	ebegin "Stopping dnsextd"
	start-stop-daemon --stop --quiet --pid /var/run/dnsextd.pid
	eend $? "Failed to stop dnsextd"
}

dump() {
	ebegin "Dumping dnsextd lease table"
	kill -INFO `cat /var/run/dnsextd.pid` >&/dev/null
	eend $? "Failed to dump dnsextd lease table"
}
