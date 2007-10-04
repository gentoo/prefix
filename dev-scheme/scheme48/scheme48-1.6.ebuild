# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/scheme48/scheme48-1.6.ebuild,v 1.1 2007/07/28 20:06:56 araujo Exp $

EAPI="prefix"

inherit elisp-common multilib eutils flag-o-matic autotools

DESCRIPTION="Scheme48 is an implementation of the Scheme Programming Language."
HOMEPAGE="http://www.s48.org/"
SRC_URI="http://www.s48.org/${PV}/${P}.tgz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE="doc emacs"

DEPEND="emacs? ( virtual/emacs )"
RDEPEND="${DEPEND}"
SITEFILE=50scheme48-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i "s:\`pwd\`:/usr/$(get_libdir)/scheme48:" Makefile.in
	sed -i "s:lib=\$(LIB):lib=/usr/$(get_libdir)/scheme48:" Makefile.in
	# Set the correct values for the paths show by the man pages
	sed -i "s:=\$(bindir)=:=/usr/bin/=:" Makefile.in
	sed -i "s:=\$(LIB)=:=/usr/$(get_libdir)/scheme48=:" Makefile.in
	# From Bug #127105
	sed -i 's:`(cd $(srcdir) && echo $$PWD)`/scheme:'"/usr/$(get_libdir)/scheme48/:" Makefile.in
	sed -i "s:'\$(LIB)':'/usr/$(get_libdir)/\$(RUNNABLE)':" Makefile.in
	epatch "${FILESDIR}/scheme48-1.5-as-needed.patch"
	epatch "${FILESDIR}/${P}-prefix.patch"
	eprefixify Makefile.in
	eautoreconf
}

src_compile() {
	use amd64 && append-flags "-m32"
	econf || die "econf failed"
	emake || die "emake failed"
	if use emacs; then
		elisp-compile ${S}/emacs/cmuscheme48.el
	fi
}

src_install() {
	make prefix=${ED}/usr \
		mandir=${ED}/usr/share/man/man1 \
		install || die "make failed"
	if use emacs; then
		elisp-install ${PN} emacs/cmuscheme48.el emacs/*.elc
		elisp-site-file-install ${FILESDIR}/${SITEFILE}
	fi
	dodoc README INSTALL
	if use doc; then
		dodoc doc/manual.ps doc/manual.pdf doc/*.txt
		dohtml -r doc/html/*
		docinto src
		dodoc doc/src/*
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
