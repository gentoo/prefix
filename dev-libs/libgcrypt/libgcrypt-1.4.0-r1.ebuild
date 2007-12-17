# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.4.0-r1.ebuild,v 1.2 2007/12/15 16:38:36 alonbl Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="general purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	!bindist? ( idea? ( mirror://gentoo/${P}-idea.diff.bz2 ) )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="nls bindist idea"

RDEPEND="nls? ( virtual/libintl )
	>=dev-libs/libgpg-error-1.0"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use idea; then
		if use bindist; then
			elog "Skipping IDEA support to comply with binary distribution (bug #148907)."
		else
			ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html"
			epatch "${WORKDIR}/${P}-idea.diff"
			AT_M4DIR="m4" eautoreconf
		fi
	fi
}

src_compile() {
	# --disable-padlock-support for bug#201917
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--with-pic \
		--enable-noexecstack \
		$(use_enable nls) \
		|| die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog NEWS README* THANKS TODO VERSION
}

pkg_postinst() {
	if use !bindist && use idea; then
		ewarn "-----------------------------------------------------------------------------------"
		ewarn "IDEA"
		ewarn "you have compiled ${PN} with support for the IDEA algorithm, this code"
		ewarn "is distributed under the GPL in countries where it is permitted to do so"
		ewarn "by law."
		ewarn
		ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html for more information."
		ewarn
		ewarn "If you are in a country where the IDEA algorithm is patented, you are permitted"
		ewarn "to use it at no cost for 'non revenue generating data transfer between private"
		ewarn "individuals'."
		ewarn
		ewarn "Countries where the patent applies are listed here"
		ewarn "http://www.mediacrypt.com/_contents/10_idea/101030_ea_pi.asp"
		ewarn "-----------------------------------------------------------------------------------"
	fi
}
