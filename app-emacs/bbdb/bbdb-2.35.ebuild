# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/bbdb/bbdb-2.35.ebuild,v 1.6 2007/05/20 21:36:10 armin76 Exp $

EAPI="prefix"

inherit elisp

DESCRIPTION="The Insidious Big Brother Database"
HOMEPAGE="http://bbdb.sourceforge.net/"
SRC_URI="http://bbdb.sourceforge.net/${P}.tar.gz
	http://www.mit.edu/afs/athena/contrib/emacs-contrib/Fin/point-at.el
	http://www.mit.edu/afs/athena/contrib/emacs-contrib/Fin/dates.el"

LICENSE="GPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="tetex"

DEPEND=""
RDEPEND="${DEPEND}
	tetex? ( virtual/tetex )"

SITEFILE=50bbdb-gentoo.el

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	sed -i -e '0,/^--- bbdb-mail-folders.el ---$/d;/^--- end ---$/,$d' \
		bits/bbdb-mail-folders.el || die "sed failed"
	sed -i -e '/^;/,$!d' bits/bbdb-sort-mailrc.el || die "sed failed"
	cp ${DISTDIR}/{dates,point-at}.el bits
}

src_compile() {
	econf || die "econf failed"
	emake -j1 || die "emake failed"

	cat >${T}/lp.el <<-EOF
		(add-to-list 'load-path "${S}/bits")
		(add-to-list 'load-path "${S}/lisp")
	EOF
	emacs -batch -no-site-file -l ${T}/lp.el \
		-f batch-byte-compile bits/*.el || die "make bits failed"
}

src_install() {
	elisp-install ${PN} lisp/*.el{,c} || die
	elisp-install ${PN}/bits bits/*.el{,c} || die
	elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
	doinfo texinfo/*.info*
	dodoc ChangeLog INSTALL README bits/*.txt
	newdoc bits/README README.bits
	if use tetex; then
		insinto /usr/share/texmf/tex/bbdb
		doins tex/*.tex
	fi
}

pkg_postinst() {
	elisp-site-regen
	use tetex && texconfig rehash

	echo
	elog "If you use encryption or signing, you may specify the encryption"
	elog "method by customising variable \"bbdb/pgp-method\". For details,"
	elog "see the documentation of this variable. Depending on the Emacs"
	elog "version, installation of additional packages like app-emacs/gnus"
	elog "or app-emacs/mailcrypt may be required."
}

pkg_postrm() {
	elisp-site-regen
	use tetex && texconfig rehash
}
