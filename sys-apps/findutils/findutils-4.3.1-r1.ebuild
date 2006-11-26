# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/findutils/findutils-4.3.1-r1.ebuild,v 1.3 2006/11/16 17:45:04 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib

SELINUX_PATCH="findutils-4.3.1-selinux.diff"

DESCRIPTION="GNU utilities for finding files"
HOMEPAGE="http://www.gnu.org/software/findutils/findutils.html"
# SRC_URI="mirror://gnu/${PN}/${P}.tar.gz mirror://gentoo/${P}.tar.gz"
SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="nls selinux static"

RDEPEND="selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix segfaults where regex was the last parameter
	epatch "${FILESDIR}/${P}-sv-bug-17490.patch"

	# Don't build or install locate because it conflicts with slocate,
	# which is a secure version of locate.  See bug 18729
	sed -i '/^SUBDIRS/s/locate//' Makefile.in

	# Patches for selinux
	use selinux && epatch "${FILESDIR}/${SELINUX_PATCH}"

	if ! has userpriv ${FEATURES} ; then
		sed -i '/access.exp/d' find/testsuite/Makefile.in
		rm -f find/testsuite/find.gnu/access.{exp,xo}
	fi
}

src_compile() {
	use static && append-ldflags -static

	local myconf
	[[ ${USERLAND} != "GNU" ]] && [[ ${EPREFIX/\//} == "" ]] && \
		myconf=" --program-prefix=g"

	if echo "#include <regex.h>" | $(tc-getCPP) > /dev/null ; then
		myconf="${myconf} --without-included-regex"
	fi

	econf \
		$(use_enable nls) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/find \
		${myconf} \
		|| die "configure failed"
	emake AR="$(tc-getAR)" || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc NEWS README TODO ChangeLog
}
