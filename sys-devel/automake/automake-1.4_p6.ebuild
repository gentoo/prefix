# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.4_p6.ebuild,v 1.21 2006/03/30 13:41:44 flameeyes Exp $

EAPI="prefix"

inherit eutils

MY_P="${P/_/-}"
DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://sources.redhat.com/automake/"
SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="${PV:0:3}"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl
	sys-devel/automake-wrapper
	>=sys-devel/autoconf-2.59-r6
	sys-devel/gnuconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/automake-1.4-nls-nuisances.patch #121151
	epatch "${FILESDIR}"/automake-1.4-libtoolize.patch
	epatch "${FILESDIR}"/automake-1.4-subdirs-89656.patch
	epatch "${FILESDIR}"/automake-1.4-ansi2knr-stdlib.patch
	sed -i 's:error\.test::' tests/Makefile.in #79529
	sed -i \
		-e "/^@setfilename/s|automake|automake${SLOT}|" \
		-e "s|automake: (automake)|automake v${SLOT}: (automake${SLOT})|" \
		-e "s|aclocal: (automake)|aclocal v${SLOT}: (automake${SLOT})|" \
		automake.texi || die "sed failed"
	export WANT_AUTOCONF=2.5
}

src_install() {
	make install DESTDIR="${D}" \
		pkgdatadir=${EPREFIX}/usr/share/automake-${SLOT} \
		m4datadir=${EPREFIX}/usr/share/aclocal-${SLOT} \
		|| die
	rm -f "${ED}"/usr/bin/{aclocal,automake}
	dosym automake-${SLOT} /usr/share/automake

	dodoc NEWS README THANKS TODO AUTHORS ChangeLog
	doinfo *.info

	# remove all config.guess and config.sub files replacing them
	# w/a symlink to a specific gnuconfig version
	for x in guess sub ; do
		dosym ../gnuconfig/config.${x} /usr/share/${PN}-${SLOT}/config.${x}
	done
}

pkg_postinst() {
	einfo "Please note that the 'WANT_AUTOMAKE_1_4=1' syntax has changed to:"
	einfo "  WANT_AUTOMAKE=1.4"
}
