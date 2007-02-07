# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/aspell/aspell-0.60.4.ebuild,v 1.9 2006/11/30 19:03:31 kevquinn Exp $

EAPI="prefix"

# N.B. This is before inherit of autotools, as autotools.eclass adds the
# relevant dependencies to DEPEND.
WANT_AUTOMAKE="1.9"

inherit libtool eutils flag-o-matic autotools

DESCRIPTION="A spell checker replacement for ispell"
HOMEPAGE="http://aspell.net/"
SRC_URI="mirror://gnu/aspell/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="gpm nls"

RDEPEND=">=sys-libs/ncurses-5.2
	gpm? ( sys-libs/gpm )
	nls? ( virtual/libintl )"

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/aspell-0.60.3-templateinstantiations.patch
	epatch "${FILESDIR}"/aspell-0.60.4-gcc-4.1-fix.patch
	epatch "${FILESDIR}/${P}-nls.patch"

	eautomake
	elibtoolize --reverse-deps
}

src_compile() {
	use gpm && append-ldflags -lgpm
	filter-flags -fno-rtti
	filter-flags -fvisibility=hidden #77109
	filter-flags -maltivec -mabi=altivec
	use ppc && append-flags -mno-altivec

	econf \
		$(use_enable nls) \
		--disable-static \
		--sysconfdir=/etc/aspell \
		--enable-docdir=/usr/share/doc/${PF} || die

	emake || die
}

src_install() {
	dodoc README* TODO

	make DESTDIR="${D}" install || die
	mv "${ED}"/usr/share/doc/${PF}/man-html "${ED}"/usr/share/doc/${PF}/html
	mv "${ED}"/usr/share/doc/${PF}/man-text "${ED}"/usr/share/doc/${PF}/text

	# install ispell/aspell compatibility scripts
	exeinto /usr/bin
	newexe scripts/ispell ispell-aspell
	newexe scripts/spell spell-aspell

	cd examples
	make clean || die
	docinto examples
	dodoc ${S}/examples/*
}

pkg_postinst() {
	einfo "You will need to install a dictionary now.  Please choose an"
	einfo "aspell-<LANG> dictionary from the app-dicts category"
	einfo "After installing an aspell dictionary for your language(s),"
	einfo "You may use the aspell-import utility to import your personal"
	einfo "dictionaries from ispell, pspell and the older aspell"

	ewarn ""
	ewarn "Please re-emerge ALL your aspell-LANG dictionaries"
	ewarn ""
	ebeep 5
}
