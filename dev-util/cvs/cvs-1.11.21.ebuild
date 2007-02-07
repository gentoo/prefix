# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cvs/cvs-1.11.21.ebuild,v 1.1 2006/03/07 09:25:09 pylon Exp $

EAPI="prefix"

DESCRIPTION="Concurrent Versions System - source code revision control tools"
HOMEPAGE="http://www.cvshome.org/"
SRC_URI="mirror://gnu/non-gnu/cvs/source/stable/${PV}/${P}.tar.bz2
	doc? ( mirror://gnu/non-gnu/cvs/source/stable/${PV}/cederqvist-${PV}.html.tar.bz2
		mirror://gnu/non-gnu/cvs/source/stable/${PV}/cederqvist-${PV}.pdf
		mirror://gnu/non-gnu/cvs/source/stable/${PV}/cederqvist-${PV}.ps )"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="doc emacs"

DEPEND=">=sys-libs/zlib-1.1.4"

src_compile() {
	econf --with-tmpdir=/tmp || die
	emake || die "emake failed"
}

src_install() {
	einstall || die

	insinto /etc/xinetd.d
	newins ${FILESDIR}/cvspserver.xinetd.d cvspserver || die "newins failed"

	dodoc BUGS ChangeLog* DEVEL* FAQ HACKING \
		MINOR* NEWS PROJECTS README* TESTS TODO

	if use emacs; then
		insinto /usr/share/emacs/site-lisp
		doins cvs-format.el || die "doins failed"
	fi

	if use doc; then
		dodoc ${DISTDIR}/cederqvist-${PV}.pdf
		dodoc ${DISTDIR}/cederqvist-${PV}.ps
		tar xjf ${DISTDIR}/cederqvist-${PV}.html.tar.bz2
		dohtml -r cederqvist-${PV}.html/*
		cd ${D}/usr/share/doc/${PF}/html/
		ln -s cvs.html index.html
	fi
}

src_test() {
	einfo "FEATURES=\"maketest\" has been disabled for dev-util/cvs"
}
