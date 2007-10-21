# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/clisp/clisp-2.42.ebuild,v 1.3 2007/10/17 14:09:32 hkbst Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs multilib

DESCRIPTION="A portable, bytecode-compiled implementation of Common Lisp"
HOMEPAGE="http://clisp.sourceforge.net/"
SRC_URI="mirror://sourceforge/clisp/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""
IUSE="X new-clx fastcgi pcre postgres readline zlib"

RDEPEND=">=dev-libs/libsigsegv-2.4
	virtual/tetex
	fastcgi? ( dev-libs/fcgi )
	postgres? ( >=dev-db/postgresql-8.0 )
	readline? ( sys-libs/readline )
	pcre? ( dev-libs/libpcre )
	zlib? ( sys-libs/zlib )
	X? ( new-clx? ( x11-libs/libXpm ) )"
#   * GNU gettext
#      + Not needed on systems with glibc 2.2 or newer, but recommended on all
#        other systems: needed if you want clisp with native language support.
#	sys-devel/gettext

DEPEND="${RDEPEND} X? ( new-clx? ( x11-misc/imake x11-proto/xextproto ) )"

PROVIDE="virtual/commonlisp"

BUILDDIR="builddir"

src_compile() {
	CC="$(tc-getCC)"
	local myconf="--with-dynamic-ffi --with-module=wildcard --with-module=rawsock"
	use elibc_glibc && myconf="${myconf} --with-module=bindings/glibc"
	use readline || myconf="${myconf} --with-noreadline"
	if use X; then
		if use new-clx; then
			myconf="${myconf} --with-module=clx/new-clx"
		else
			myconf="${myconf} --with-module=clx/mit-clx"
		fi
	fi
	if use postgres; then
		myconf="${myconf} --with-module=postgresql"
		CC="${CC} -I $(pg_config --includedir)"
	fi
	use fastcgi && myconf="${myconf} --with-module=fastcgi"
	use pcre && myconf="${myconf} --with-module=pcre"
	use zlib && myconf="${myconf} --with-module=zlib"

	# configure chokes on --infodir option
	./configure --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) \
		${myconf} ${BUILDDIR} || die "./configure failed"
	cd ${BUILDDIR}
	./makemake ${myconf} >Makefile
	emake config.lisp
	sed -i 's,"vi","nano",g' config.lisp
	# parallel build fails
	emake -j1 || die "emake failed"
}

src_install() {
	pushd ${BUILDDIR}
	make DESTDIR="${D}" prefix="${EPREFIX}"/usr install-bin || die
	doman clisp.1
	dodoc SUMMARY README* NEWS MAGIC.add ANNOUNCE clisp.dvi clisp.html
	chmod a+x "${ED}"/usr/$(get_libdir)/clisp/clisp-link
	popd
	dohtml doc/impnotes.{css,html} ${BUILDDIR}/clisp.html doc/clisp.png
	dodoc ${BUILDDIR}/clisp.ps doc/{editors,CLOS-guide,LISP-tutorial}.txt
}
