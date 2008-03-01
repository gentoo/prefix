# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-scheme/scheme48/scheme48-1.8.ebuild,v 1.1 2008/02/29 16:40:33 hkbst Exp $

EAPI="prefix"

inherit elisp-common multilib eutils flag-o-matic autotools

DESCRIPTION="Scheme48 is an implementation of the Scheme Programming Language."
HOMEPAGE="http://www.s48.org/"
SRC_URI="http://www.s48.org/${PV}/${P}.tgz"

LICENSE="as-is"
SLOT="0"
#KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc emacs"

DEPEND="emacs? ( virtual/emacs )"
RDEPEND="${DEPEND}"
SITEFILE=50scheme48-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"

#	cp Makefile.in Makefile.in.old
#	sed "s:lib=\\\\\"\`pwd\`\\\\\":lib=\$(libdir):" -i Makefile.in
#	sed "/SHARE = /iecho \$(LIB)" -i Makefile.in
#	sed "/LIB = /a@echo \$(LIB)" -i Makefile.in
#	sed "/\t>\$\$script/a\tmkdir -p \$(DESTDIR)\$(bindir) \\" -i Makefile.in

	#improve parallel install
#	sed "s:echo \"#!/bin/sh\":mkdir -p \$(DESTDIR)\$(bindir); echo \"#!/bin/sh\":" -i Makefile.in

	sed "s:config_script=:config_script=\$(DESTDIR):" -i Makefile.in
#	sed "s:echo \"#!/bin/sh\":mkdir -p \$(dir $$script; echo \"#!/bin/sh\":" -i Makefile.in

	sed "s:\[-e \$(VM).a\];:\[ -e \$(VM).a \];:g" -i Makefile.in

#	sed "/for stub in env/amkdir -p \$(DESTDIR)\$(SHARE)/\$\$stub; \\\\" -i Makefile.in
#	diff -u Makefile.in.old Makefile.in

#	sed -i "s:\`pwd\`:/usr/$(get_libdir)/scheme48:" Makefile.in
#	sed -i "s:lib=\$(LIB):lib=/usr/$(get_libdir)/scheme48:" Makefile.in
	# Set the correct values for the paths show by the man pages
#	sed -i "s:=\$(bindir)=:=/usr/bin/=:" Makefile.in
#	sed -i "s:=\$(LIB)=:=/usr/$(get_libdir)/scheme48=:" Makefile.in
	# From Bug #127105
#	sed -i 's:`(cd $(srcdir) && echo $$PWD)`/scheme:'"/usr/$(get_libdir)/scheme48/:" Makefile.in
#	sed -i "s:'\$(LIB)':'/usr/$(get_libdir)/\$(RUNNABLE)':" Makefile.in
#	epatch "${FILESDIR}/scheme48-1.5-as-needed.patch"
#	epatch "${FILESDIR}/${PN}-1.6-prefix.patch"
#	eprefixify Makefile.in
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
	if use emacs; then
		elisp-compile "${S}"/emacs/cmuscheme48.el
	fi
}

src_install() {
	# weird parallel failures!
	emake -j1 DESTDIR="${D}" install || die

	if use emacs; then
		elisp-install ${PN} emacs/cmuscheme48.el emacs/*.elc
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
	fi

	dodoc README INSTALL
	if use doc; then
		dodoc doc/manual.ps doc/manual.pdf doc/*.txt
		dohtml -r doc/html/*
		docinto src
		dodoc doc/src/*
	fi

	#this symlink clashes with gambit
	rm "${ED}"/usr/bin/scheme-r5rs
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
