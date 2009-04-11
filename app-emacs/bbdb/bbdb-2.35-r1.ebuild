# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/bbdb/bbdb-2.35-r1.ebuild,v 1.5 2008/11/01 18:01:48 nixnut Exp $

inherit elisp

DESCRIPTION="The Insidious Big Brother Database"
HOMEPAGE="http://bbdb.sourceforge.net/"
SRC_URI="http://bbdb.sourceforge.net/${P}.tar.gz
	http://www.mit.edu/afs/athena/contrib/emacs-contrib/Fin/point-at.el
	http://www.mit.edu/afs/athena/contrib/emacs-contrib/Fin/dates.el"

LICENSE="GPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE="tex"

DEPEND=""
RDEPEND="tex? ( virtual/tex-base )"

SITEFILE=50${PN}-gentoo.el
TEXMF="/usr/share/texmf-site"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	sed -i -e '0,/^--- bbdb-mail-folders.el ---$/d;/^--- end ---$/,$d' \
		bits/bbdb-mail-folders.el || die "sed failed"
	sed -i -e '/^;/,$!d' bits/bbdb-sort-mailrc.el || die "sed failed"
	cp "${DISTDIR}"/{dates,point-at}.el bits || die "cp failed"
}

src_compile() {
	econf || die "econf failed"
	emake -j1 || die "emake failed"
	BYTECOMPFLAGS="-L bits -L lisp"	elisp-compile bits/*.el || die
}

src_install() {
	elisp-install ${PN} lisp/*.el{,c} || die
	elisp-install ${PN}/bits bits/*.el{,c} || die
	elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
	doinfo texinfo/*.info*
	dodoc ChangeLog INSTALL README bits/*.txt
	newdoc bits/README README.bits
	if use tex; then
		insinto "${TEXMF}"/tex/plain/bbdb
		doins tex/*.tex
	fi
}

pkg_postinst() {
	elisp-site-regen
	use tex && texconfig rehash

	elog "If you use encryption or signing, you may specify the encryption"
	elog "method by customising variable \"bbdb/pgp-method\". For details,"
	elog "see the documentation of this variable. Depending on the Emacs"
	elog "version, installation of additional packages like app-emacs/gnus"
	elog "or app-emacs/mailcrypt may be required."
}

pkg_postrm() {
	elisp-site-regen
	use tex && texconfig rehash
}
