# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/grep/grep-2.5.3.ebuild,v 1.2 2008/09/19 21:28:39 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DEB_VER="${PV}~dfsg-6"
DESCRIPTION="GNU regular expression matcher"
HOMEPAGE="http://www.gnu.org/software/grep/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2
	mirror://debian/pool/main/g/grep/grep_${DEB_VER}.diff.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls pcre static"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	pcre? ( dev-libs/libpcre )
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}"/grep_${DEB_VER}.diff
	EPATCH_FORCE="yes" \
	EPATCH_SUFFIX="patch" \
	EPATCH_MULTI_MSG="Applying Debian patchset (${DEB_VER}) ..." \
	epatch ${P}~dfsg/debian/patches/

	use static && append-ldflags -static
}

src_compile() {
	econf \
		--bindir="${EPREFIX}"/bin \
		$(use_enable nls) \
		$(use_enable pcre perl-regexp) \
		|| die "econf failed"

	use static || sed -i 's:-lpcre:-Wl,-Bstatic -lpcre -Wl,-Bdynamic:g' src/Makefile

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
