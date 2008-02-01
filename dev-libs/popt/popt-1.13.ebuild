# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.13.ebuild,v 1.1 2008/01/07 06:00:49 dirtyepic Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://rpm5.org/"
SRC_URI="http://rpm5.org/files/popt/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.12-scrub-lame-gettext.patch

	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${P}-no-wchar-hack.patch

	if [[ ${CHOST} == *-interix* ]]; then 
		# if there is
		# *) an iconv implementation in libc without extra -liconv,
		# *) this libc is not glibc (with GNU libiconv),
		# *) an installed libiconv in prefix (would not be with glibc),
		# *) *no installed gettext*,
		# then this check breaks the compile for popt (at least on interix).
		# also see #206781.
		epatch "${FILESDIR}"/${P}-no-acfunc-iconv.patch
		touch aclocal.m4
		touch configure # avoid eautoreconf
	else
		# this seems to not work on interix (without gettext, it dies telling
		# that gettext is required)...
		epatch "${FILESDIR}"/${P}-iconv.patch # solves USE=-nls compilation
		# for systems that don't have gettext installed yet we need to use the
		# included m4's (e.g. during bootstrapping)
		AT_M4DIR=m4 eautoreconf
	fi
}

src_compile() {
	econf \
		--without-included-gettext \
		$(use_enable nls) \
		|| die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc CHANGES README
}
