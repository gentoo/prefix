# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/ecb/ecb-2.40.ebuild,v 1.1 2009/05/17 08:21:57 ulm Exp $

inherit elisp eutils

DESCRIPTION="Source code browser for Emacs"
HOMEPAGE="http://ecb.sourceforge.net/"
SRC_URI="mirror://sourceforge/ecb/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="java"

DEPEND=">=app-emacs/cedet-1.0_pre6
	java? ( app-emacs/jde )"
RDEPEND="${DEPEND}"

SITEFILE="71${PN}-gentoo.el"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-2.32-gentoo.patch"
	sed -i -e "s:@PF@:${PF}:" ecb-help.el || die "sed failed"
}

src_compile() {
	local loadpath=""
	if use java; then
		loadpath="${ESITELISP}/elib ${ESITELISP}/jde ${ESITELISP}/jde/lisp"
	fi

	emake CEDET="${ESITELISP}/cedet" LOADPATH="${loadpath}" \
		|| die "emake failed"
}

src_install() {
	elisp_src_install

	insinto "${SITEETC}/${PN}"
	doins -r ecb-images || die

	doinfo info-help/ecb.info* || die
	dohtml html-help/*.html || die
	dodoc NEWS README RELEASE_NOTES || die
}

pkg_postinst() {
	elisp-site-regen
	elog "ECB is now autoloaded in site-gentoo.el. Add the line"
	elog "  (require 'ecb)"
	elog "to your ~/.emacs file to enable all features on Emacs startup."
}
