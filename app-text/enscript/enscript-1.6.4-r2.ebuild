# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/enscript/enscript-1.6.4-r2.ebuild,v 1.10 2008/03/04 03:07:51 jer Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="powerful text-to-postscript converter"
SRC_URI="http://www.iki.fi/mtr/genscript/${P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/enscript/enscript.html"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
SLOT="0"
LICENSE="GPL-2"
IUSE="nls"

DEPEND="sys-devel/flex
	sys-devel/bison
	nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/enscript-1.6.3-security.patch
	epatch "${FILESDIR}"/enscript-1.6.3-language.patch
	epatch "${FILESDIR}"/enscript-catmur.patch
	epatch "${FILESDIR}"/enscript-1.6.4-ebuild.st.patch
	epatch "${FILESDIR}"/enscript-1.6.4-fsf-gcc-darwin.patch
}

src_compile() {
	unset CC
	econf `use_enable nls` || die
	emake || die
}

src_install() {
	einstall || die
	dodoc AUTHORS ChangeLog FAQ.html NEWS README* THANKS TODO
	insinto /usr/share/enscript/hl
	doins "${FILESDIR}"/ebuild.st
}

pkg_postinst() {
	elog "Now, customize /etc/enscript.cfg."
}
