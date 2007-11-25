# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/auctex/auctex-11.84-r3.ebuild,v 1.2 2007/11/24 21:11:52 ulm Exp $

EAPI="prefix"

inherit elisp eutils latex-package

DESCRIPTION="An extensible package that supports writing and formatting TeX files"
HOMEPAGE="http://www.gnu.org/software/auctex/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2 FDL-1.2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="preview-latex"

DEPEND="virtual/tetex
	preview-latex? ( !dev-tex/preview-latex
		app-text/dvipng
		virtual/ghostscript )"

# Don't install in the main tree, as this causes file collisions
# with app-text/tetex, see bug #155944
TEXMF="/usr/share/texmf-site"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# skip XEmacs detection. this is a workaround for emacs23
	epatch "${FILESDIR}/${P}-configure.diff"
	# allow compilation of Japanese TeX files, fixed in upstream's CVS
	# not needed for next release (>=11.85)
	epatch "${FILESDIR}/${P}-japanes.patch"
}

src_compile() {
	econf --disable-build-dir-test \
		--with-auto-dir="${EPREFIX}/var/lib/auctex" \
		--with-lispdir="${ESITELISP}/${PN}" \
		--with-packagelispdir="${ESITELISP}/${PN}" \
		--with-packagedatadir="${EPREFIX}/usr/share/emacs/etc/${PN}" \
		--with-texmf-dir="${EPREFIX}${TEXMF}" \
		$(use_enable preview-latex preview) || die "econf failed"
	emake || die "emake failed"
	cd doc; emake tex-ref.pdf || die "creation of tex-ref.pdf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el" || die
	if use preview-latex; then
		elisp-site-file-install "${FILESDIR}/60${PN}-gentoo.el" || die
	fi
	keepdir /var/lib/auctex
	dodoc ChangeLog CHANGES README RELEASE TODO FAQ INSTALL* doc/tex-ref.pdf
}

pkg_postinst() {
	# rebuild TeX-inputfiles-database
	use preview-latex && latex-package_pkg_postinst
	elisp-site-regen
}

pkg_postrm(){
	use preview-latex && latex-package_pkg_postrm
	elisp-site-regen
}
