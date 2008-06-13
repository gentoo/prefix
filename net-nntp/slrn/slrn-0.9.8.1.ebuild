# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-nntp/slrn/slrn-0.9.8.1.ebuild,v 1.8 2007/03/11 17:57:59 swegener Exp $

EAPI="prefix"

inherit eutils

# Upstream patches from http://slrn.sourceforge.net/patches/
# ${FILESDIR}/${PV}/${P}-<name>.diff
SLRN_PATCHES="fetch lastchar2"

DESCRIPTION="s-lang Newsreader"
HOMEPAGE="http://slrn.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="ssl nls unicode uudeview"

RDEPEND="virtual/mta
	>=app-arch/sharutils-4.2.1
	=sys-libs/slang-1.4*
	ssl? ( >=dev-libs/openssl-0.9.6 )"
DEPEND="${RDEPEND}
	uudeview? ( dev-libs/uulib )
	nls? ( sys-devel/gettext )"

pkg_setup() {
	if use unicode && ! built_with_use sys-libs/slang unicode
	then
		eerror "For USE=\"unicode\" support you need to have your sys-libs/slang also compiled"
		eerror "with USE=\"unicode\" support."
		die "sys-libs/slang with USE=\"unicode\" support needed"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	for i in ${SLRN_PATCHES}
	do
		epatch "${FILESDIR}"/${PV}/${P}-${i}.diff
	done

	use unicode && epatch "${FILESDIR}"/${PV}-utf8.patch
}

src_compile() {
	local myconf
	if use ssl; then
		myconf="${myconf}--with-ssl-library=${EPREFIX}/usr/$(get_libdir)"
	fi

	econf \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-slrnpull \
		$(use_enable nls) \
		$(use_with ssl) \
		$(use_with uudeview) \
		"${myconf}" \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install () {
	make DESTDIR="${D}" install || die "make install failed"
}
