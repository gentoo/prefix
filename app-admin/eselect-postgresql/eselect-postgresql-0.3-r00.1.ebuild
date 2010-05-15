# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-postgresql/eselect-postgresql-0.3.ebuild,v 1.11 2010/04/25 19:55:00 armin76 Exp $

inherit multilib eutils prefix

DESCRIPTION="Utility to change the default postgresql installation"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tbz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="app-admin/eselect
	!dev-db/libpq"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-prefix.patch"
	eprefixify postgresql.eselect binwrapper
}

src_install() {
	keepdir /etc/eselect/postgresql
	doenvd "${FILESDIR}/50postgresql-eselect"

	insinto /usr/share/eselect/modules
	doins postgresql.eselect
	sed -i \
		-e "s|/usr/lib/|/usr/$(get_libdir)/|g" \
		"${ED}/usr/share/eselect/modules/postgresql.eselect"

	exeinto /usr/$(get_libdir)/${PN}
	doexe "binwrapper"

	dodir /usr/bin
	dosym /usr/bin/eselect /usr/bin/postgresql-config
}

pkg_preinst() {
	local ff=""
	for f in "${EROOT}"/usr/include/{postgresql,libpq-fe.h,libpq,postgres_ext.h} ; do
		[[ -e "${f}" ]] || continue
		[[ -L "${f}" ]] && continue
		if [[ -d "${f}" ]] ; then
			if [[ -z "$(find \"${f}\" -not \( -type l -or -type d \))" ]] ; then
				rm -rf "${f}"
			else
				ff="$ff $f"
			fi
		else
			ff="$ff $f"
		fi
	done
	if [[ ! -z "$ff" ]] ; then
		eerror "You have leftovers from previous postgresql installations that"
		eerror "can't be dealt with automatically. The proper way to treat"
		eerror "files is:"
		eerror ""
		eerror "rm -rf ${ff}"
		eerror ""
		die "Please, remove the files manually"
	fi
}

pkg_postinst() {
	elog "This eselect module can be used to define which PostgreSQL version is being used"
	elog "to link against and which (major) version of PostgreSQL is being started by the init-system"
	elog "when an init.d file lists 'need postgresql' or 'use postgresql' in its dependencies."
	elog
	elog "For users of the 'postgresql' overlay:"
	elog "In case you have dev-db/postgresql-{base,server} installed but 'eselect postgresql list'"
	elog "doesn't anything, please re-install dev-db/postgresql-{base,server} since we had to move"
	elog "around some stuff. Sorry for the inconvenience."
	elog
	elog "Please make sure that you use the new postgresql ebuilds (dev-db/postgresql-{base,server})."
	elog "This eselect module won't list the old dev-db/{postgresql,libpq} installations as available"
	elog "libraries or services."
}
