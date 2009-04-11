# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/grep/grep-2.5.3-r1.ebuild,v 1.5 2009/04/09 16:09:35 loki_val Exp $

inherit flag-o-matic eutils

DEB_VER="${PV}~dfsg-6"
DESCRIPTION="GNU regular expression matcher"
HOMEPAGE="http://www.gnu.org/software/grep/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2
	mirror://debian/pool/main/g/grep/grep_${DEB_VER}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls pcre static"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	pcre? ( <=dev-libs/libpcre-7.8 )
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}"/grep_${DEB_VER}.diff
	EPATCH_FORCE="yes" \
	EPATCH_SUFFIX="patch" \
	EPATCH_MULTI_MSG="Applying Debian patchset (${DEB_VER}) ..." \
	# fix for older patch
	sed -i -e '/^#/d' "${P}~dfsg"/debian/patches/64-egf-speedup.patch || die
	# bug #251427
	EPATCH_EXCLUDE=65-dfa-optional.patch \
	epatch ${P}~dfsg/debian/patches/
	epatch "${FILESDIR}"/${P}-yesno-test-fix.patch
	epatch "${FILESDIR}"/${P}-po-builddir-fix.patch
	epatch "${FILESDIR}"/${P}-nls.patch
	use static && append-ldflags -static

	epatch "${FILESDIR}"/${PN}-2.5.1a-mint.patch
}

src_compile() {
	econf \
		--bindir="${EPREFIX}"/bin \
		$(use_enable nls) \
		$(use_enable pcre perl-regexp) \
		$(use_with !elibc_glibc included-regex) \
		${myconf} \
		|| die "econf failed"

	if [[ $(ld --version 2>&1 | head -n1) == *GNU* ]] ; then
	use static || sed -i 's:-lpcre:-Wl,-Bstatic -lpcre -Wl,-Bdynamic:g' src/Makefile
	fi

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
