# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/cron.eclass,v 1.10 2006/10/31 17:20:38 wschlich Exp $

# Original Author: Aaron Walker <ka0ttic@gentoo.org>
#
# Purpose: The main motivation for this eclass was to simplify
# the jungle known as src_install() in cron ebuilds. Using these
# functions also ensures that permissions are *always* reset,
# preventing the accidental installation of files with wrong perms.
#
# NOTE on defaults: the default settings in the below functions were
# chosen based on the most common setting among cron ebuilds.
#
# Please assign any bugs regarding this eclass to cron-bugs@gentoo.org.

inherit eutils flag-o-matic

EXPORT_FUNCTIONS pkg_postinst

SLOT="0"

DEPEND=">=sys-apps/sed-4.0.5"

RDEPEND="!virtual/cron
	virtual/mta
	>=sys-process/cronbase-0.3.2"

PROVIDE="virtual/cron"

# docrondir [ dir ] [ perms ]
#
# Creates crontab directory
#
#	Both arguments are optional.  Everything after 'dir' is considered
#   the permissions (same format as insopts).
#
# ex: docrondir /some/dir -m 0770 -o root -g cron
#     docrondir /some/dir (uses default perms)
#     docrondir -m0700 (uses default dir)

docrondir() {
	# defaults
	local perms="-m0750 -o root -g cron" dir="/var/spool/cron/crontabs"

	if [[ -n $1 ]] ; then
		case "$1" in
			*/*)
				dir=$1
				shift
				[[ -n $1 ]] && perms="$@"
				;;
			*)
				perms="$@"
				;;
		esac
	fi

	diropts ${perms}
	keepdir ${dir}

	# reset perms to default
	diropts -m0755
}

# docron [ exe ] [ perms ]
#
# Install cron executable
#
#    Both arguments are optional.
#
# ex: docron -m 0700 -o root -g root ('exe' defaults to "cron")
#     docron crond -m 0110

docron() {
	local cron="cron" perms="-m 0750 -o root -g wheel"

	if [[ -n $1 ]] ; then
		case "$1" in
			-*)
				perms="$@"
				;;
			 *)
				cron=$1
				shift
				[[ -n $1 ]] && perms="$@"
				;;
		esac
	fi

	exeopts ${perms}
	exeinto /usr/sbin
	doexe ${cron} || die "failed to install ${cron}"

	# reset perms to default
	exeopts -m0755
}

# docrontab [ exe ] [ perms ]
#
# Install crontab executable
#
#   Uses same semantics as docron.

docrontab() {
	local crontab="crontab" perms="-m 4750 -o root -g cron"

	if [[ -n $1 ]] ; then
		case "$1" in
			-*)
				perms="$@"
				;;
			 *)
				crontab=$1
				shift
				[[ -n $1 ]] && perms="$@"
				;;
		esac
	fi

	exeopts ${perms}
	exeinto /usr/bin
	doexe ${crontab} || die "failed to install ${crontab}"

	# reset perms to default
	exeopts -m0755

	# users expect /usr/bin/crontab to exist...
	if [[ "${crontab##*/}" != "crontab" ]] ; then
		dosym ${crontab##*/} /usr/bin/crontab || \
			die "failed to create /usr/bin/crontab symlink"
	fi
}

cron_pkg_postinst() {
	echo
	# vixie is the only daemon that has a true system crontab
	if [[ "${PN}" != "vixie-cron" ]] ; then
		einfo "To activate /etc/cron.{hourly|daily|weekly|monthly} please run:"
		einfo " crontab /etc/crontab"
		einfo
		einfo "!!! That will replace root's current crontab !!!"
		einfo
	fi

	einfo "You may wish to read the Gentoo Linux Cron Guide, which can be"
	einfo "found online at:"
	einfo "    http://www.gentoo.org/doc/en/cron-guide.xml"
	echo
}
