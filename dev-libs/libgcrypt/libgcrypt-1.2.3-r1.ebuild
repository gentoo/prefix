# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.2.3-r1.ebuild,v 1.6 2007/01/12 20:48:36 alonbl Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="general purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.gz
	mirror://gentoo/${PN}-1.2.1-patches.tar.gz
	!bindist? ( idea? ( http://www.kfwebs.com/${P}-idea.diff.bz2 ) )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="nls bindist idea"

RDEPEND="nls? ( virtual/libintl )
	dev-libs/libgpg-error"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	epunt_cxx

	# fix for miss detection of 32 bit ppc
	cd "${S}"
	epatch "${WORKDIR}/${PN}-1.2.1-ppc64-fix.patch"
	epatch "${FILESDIR}/${P}-strict-aliasing.patch"

	if use idea; then
		if use bindist; then
			einfo "Skipping IDEA support to comply with binary distribution (bug #148907)."
		else
			ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html"
			epatch "${WORKDIR}/${P}-idea.diff"
		fi
	fi

	eautoreconf
}

src_compile() {
	local myconf

	use ppc64 && myconf="${myconf} --disable-asm"

	econf $(use_enable nls) --disable-dependency-tracking --with-pic \
		--enable-noexecstack ${myconf} || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog NEWS README* THANKS TODO VERSION

	dosym libgcrypt$(get_libname 11) /usr/lib/libgcrypt$(get_libname 7)
}

pkg_postinst() {
	if use !bindist && use idea; then
		einfo "-----------------------------------------------------------------------------------"
		einfo "IDEA"
		ewarn "you have compiled ${PN} with support for the IDEA algorithm, this code"
		ewarn "is distributed under the GPL in countries where it is permitted to do so"
		ewarn "by law."
		einfo
		einfo "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html for more information."
		einfo
		ewarn "If you are in a country where the IDEA algorithm is patented, you are permitted"
		ewarn "to use it at no cost for 'non revenue generating data transfer between private"
		ewarn "individuals'."
		einfo
		einfo "Countries where the patent applies are listed here"
		einfo "http://www.mediacrypt.com/_contents/10_idea/101030_ea_pi.asp"
		einfo
		einfo "Further information and other licenses are availble from http://www.mediacrypt.com/"
		einfo "-----------------------------------------------------------------------------------"
	fi
}
