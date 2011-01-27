# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/m4-1.4.15.ebuild,v 1.10 2011/01/09 17:37:52 armin76 Exp $

EAPI="3"

inherit eutils

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples"

# remember: cannot dep on autoconf since it needs us
DEPEND="app-arch/xz-utils"
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${P}-uclibc-sched_param-def.patch #336484
}

src_configure() {
	# Disable automagic dependency over libsigsegv; see bug #278026
	export ac_cv_libsigsegv=no

	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && myconf="--program-prefix=g"
	econf \
		$(use_enable nls) \
		--enable-changeword \
		${myconf}
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
}
