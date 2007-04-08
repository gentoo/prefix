# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cscope/cscope-15.6-r1.ebuild,v 1.11 2007/02/14 11:48:56 eroyf Exp $

EAPI="prefix"

inherit elisp-common eutils

DESCRIPTION="Interactively examine a C program"
HOMEPAGE="http://cscope.sourceforge.net/"
SRC_URI="mirror://sourceforge/cscope/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="emacs"

RDEPEND=">=sys-libs/ncurses-5.2"
DEPEND="${RDEPEND}
	sys-devel/flex
	sys-devel/bison
	>=sys-devel/autoconf-2.60
	emacs? ( virtual/emacs )"

SITEFILE=50xcscope-gentoo.el

src_unpack() {
	unpack ${A}

	# warn users of insecure web frontend, see bug #158831
	cd ${S}
	epatch "${FILESDIR}/${PN}-158831-warning_webscope.patch"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	STRIP="no"

	econf --with-ncurses="${EPREFIX}"/usr || die
	make clean || die
	emake || die

	if use emacs ; then
		cd "${S}"/contrib/xcscope || die
		elisp-compile *.el || die
	fi
}

src_install() {
	einstall || die
	dodoc NEWS AUTHORS TODO ChangeLog INSTALL README* || die

	if use emacs ; then
		cd ${S}/contrib/xcscope || die
		elisp-install xcscope *.el *.elc || die
		elisp-site-file-install ${FILESDIR}/${SITEFILE} xcscope || die
		dobin cscope-indexer || die
	fi
	cp -r ${S}/contrib/webcscope ${ED}/usr/share/doc/${PF}/ || die
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
