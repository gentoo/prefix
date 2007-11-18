#!@GENTOO_PORTAGE_EPREFIX@/bin/bash
# Copyright (c) 2006-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Contributed by Roy Marples (uberlord@gentoo.org)

# If we have a service specific script, run this now
if [ -x @GENTOO_PORTAGE_EPREFIX@/etc/openvpn/"${SVCNAME}"-down.sh ] ; then
	@GENTOO_PORTAGE_EPREFIX@/etc/openvpn/"${SVCNAME}"-down.sh "$@"
fi

# Restore resolv.conf to how it was
if [ "${PEER_DNS}" != "no" ]; then
	if [ -x @GENTOO_PORTAGE_EPREFIX@/sbin/resolvconf ] ; then
		@GENTOO_PORTAGE_EPREFIX@/sbin/resolvconf -d "${dev}"
	elif [ -e @GENTOO_PORTAGE_EPREFIX@/etc/resolv.conf-"${dev}".sv ] ; then
		# Important that we copy instead of move incase resolv.conf is
		# a symlink and not an actual file
		cp @GENTOO_PORTAGE_EPREFIX@/etc/resolv.conf-"${dev}".sv @GENTOO_PORTAGE_EPREFIX@/etc/resolv.conf
		rm -f @GENTOO_PORTAGE_EPREFIX@/etc/resolv.conf-"${dev}".sv
	fi
fi

# Re-enter the init script to start any dependant services
if @GENTOO_PORTAGE_EPREFIX@/etc/init.d/"${SVCNAME}" --quiet status ; then
	export IN_BACKGROUND=true
	@GENTOO_PORTAGE_EPREFIX@/etc/init.d/"${SVCNAME}" --quiet stop
fi

exit 0

# vim: ts=4 :
