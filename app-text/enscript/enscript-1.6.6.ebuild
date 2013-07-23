# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/enscript/enscript-1.6.6.ebuild,v 1.1 2012/09/26 14:27:26 jer Exp $

EAPI="2"

inherit eutils

DESCRIPTION="powerful text-to-postscript converter"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/enscript/enscript.html"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris"
SLOT="0"
LICENSE="GPL-3"
IUSE="nls ruby"

DEPEND="
	sys-devel/flex
	sys-devel/bison
	nls? ( sys-devel/gettext )
"
RDEPEND="nls? ( virtual/libintl )"

src_prepare() {
	epatch "${FILESDIR}"/enscript-1.6.4-ebuild.st.patch
	epatch "${FILESDIR}"/enscript-1.6.5.2-php.st.patch
	use ruby && epatch "${FILESDIR}"/enscript-1.6.2-ruby.patch
	epatch "${FILESDIR}"/enscript-1.6.4-fsf-gcc-darwin.patch
	sed -i src/tests/passthrough.test -e 's|tail +2|tail -n +2|g' || die
}

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog NEWS README* THANKS TODO || die "dodoc failed"

	insinto /usr/share/enscript/hl
	doins "${FILESDIR}"/ebuild.st || die "doins ebuild.st failed"

	if use ruby ; then
		insinto /usr/share/enscript/hl
		doins "${FILESDIR}"/ruby.st || die "doins ruby.st failed"
	fi
}

pkg_postinst() {
	elog "Now, customize /etc/enscript.cfg."
}
