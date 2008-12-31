# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/esearch/esearch-0.7.1-r6.ebuild,v 1.1 2008/12/31 05:11:19 fuzzyray Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Replacement for 'emerge --search' with search-index"
HOMEPAGE="http://david-peter.de/esearch.html"
SRC_URI="http://david-peter.de/downloads/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="linguas_it"

RDEPEND=">=dev-lang/python-2.2
	>=sys-apps/portage-2.0.50"

pkg_setup() {
	if ! built_with_use dev-lang/python readline ; then
		eerror "Python has to be build with 'readline' support!"
		eerror "To do so: USE=\"readline\" emerge python"
		eerror "Or, add \"readline\" to your USE string in"
		eerror "${EPREFIX}/etc/make.conf"
		die "Works only with python readline support"
	fi
}

src_compile() {
	epatch "${FILESDIR}/97462-esearch-metadata.patch" || die "Failed to patch sources!"
	epatch "${FILESDIR}/97969-ignore-missing-ebuilds.patch" || die "Failed to patch sources!"
	epatch "${FILESDIR}/120817-unset-emergedefaultopts.patch" || die "Failed to patch sources!"
	epatch "${FILESDIR}/132548-multiple-overlay.patch" || die "Failed to patch sources!"
	epatch "${FILESDIR}/231223-fix-deprecated.patch" || die "Failed to patch sources!"
	epatch "${FILESDIR}/253216-fix-ebuild-option.patch" || die "Failed to patch sources!"
	einfo "Fixing deprecated emerge syntax."
	sed -i -e 's:/usr/bin/emerge sync:/usr/bin/emerge --sync:g' esync.py

}

src_install() {
	dodir /usr/bin/ /usr/sbin/ || die "dodir failed"

	exeinto /usr/lib/esearch
	doexe eupdatedb.py esearch.py esync.py common.py || die "doexe failed"

	dosym /usr/lib/esearch/esearch.py /usr/bin/esearch || die "dosym failed"
	dosym /usr/lib/esearch/eupdatedb.py /usr/sbin/eupdatedb || die "dosym failed"
	dosym /usr/lib/esearch/esync.py /usr/sbin/esync || die "dosym failed"

	doman en/{esearch,eupdatedb,esync}.1 || die "doman failed"
	dodoc ChangeLog "${FILESDIR}/eupdatedb.cron" || die "dodoc failed"

	if use linguas_it ; then
		insinto /usr/share/man/it/man1
		doins it/{esearch,eupdatedb,esync}.1 || die "doins failed"
	fi
}
