# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.8.5-r4.ebuild,v 1.8 2010/03/13 19:31:12 armin76 Exp $

inherit eutils

DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://sources.redhat.com/automake/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="${PV:0:3}"
KEYWORDS="~ppc-aix ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
	sys-devel/automake-wrapper
	>=sys-devel/autoconf-2.59-r6
	sys-devel/gnuconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "/^@setfilename/s|automake|automake${SLOT}|" \
		-e "s|automake: (automake)|automake v${SLOT}: (automake${SLOT})|" \
		-e "s|aclocal: (automake)|aclocal v${SLOT}: (automake${SLOT})|" \
		doc/automake.texi || die "sed failed"
	epatch "${FILESDIR}"/${PN}-1.8.2-infopage-namechange.patch
	epatch "${FILESDIR}"/${P}-test-fixes.patch #159557
	epatch "${FILESDIR}"/${PN}-1.9.6-aclocal7-test-sleep.patch #197366
	epatch "${FILESDIR}"/${PN}-1.9.6-subst-test.patch #222225
	epatch "${FILESDIR}"/${PN}-1.10-ccnoco-ldflags.patch #203914
	epatch "${FILESDIR}"/${P}-CVE-2009-4029.patch #295357
	export WANT_AUTOCONF=2.5
}

src_install() {
	emake DESTDIR="${D}" install || die
	rm -f "${ED}"/usr/bin/{aclocal,automake}

	dodoc NEWS README THANKS TODO AUTHORS ChangeLog
	doinfo doc/*.info*

	# remove all config.guess and config.sub files replacing them
	# w/a symlink to a specific gnuconfig version
	local x=
	for x in guess sub ; do
		dosym ../gnuconfig/config.${x} /usr/share/${PN}-${SLOT}/config.${x}
	done
}
