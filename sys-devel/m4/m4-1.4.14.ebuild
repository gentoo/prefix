# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/m4-1.4.14.ebuild,v 1.1 2010/03/05 19:00:52 vapier Exp $

inherit eutils

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples"

# remember: cannot dep on autoconf since it needs us
DEPEND="|| ( app-arch/xz-utils app-arch/lzma-utils )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.4.12-interix.patch
#	epatch "${FILESDIR}"/${PN}-1.4.13-interix.patch
}

src_compile() {
	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && myconf="--program-prefix=g"
	econf \
		$(use_enable nls) \
		--enable-changeword \
		${myconf} \
		|| die
	emake || die
}

src_test() {
	[[ -d /none ]] && die "m4 tests will fail with /none/" #244396
	emake check || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	# autoconf-2.60 for instance, first checks gm4, then m4.  If we don't have
	# gm4, it might find gm4 from outside the prefix on for instance Darwin
	use prefix && dosym /usr/bin/m4 /usr/bin/gm4
	dodoc BACKLOG ChangeLog NEWS README* THANKS TODO
	if use examples ; then
		docinto examples
		dodoc examples/*
		rm -f "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi
	rm -f "${ED}"/usr/lib/charset.alias #172864
}
