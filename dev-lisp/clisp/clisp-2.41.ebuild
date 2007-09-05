# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/clisp/clisp-2.41.ebuild,v 1.7 2007/09/04 19:43:41 opfer Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs

DESCRIPTION="A portable, bytecode-compiled implementation of Common Lisp"
HOMEPAGE="http://clisp.sourceforge.net/"
SRC_URI="mirror://sourceforge/clisp/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""
IUSE="X new-clx fastcgi pcre postgres readline zlib"

RDEPEND=">=dev-libs/libsigsegv-2.4
	sys-devel/gettext
	virtual/tetex
	fastcgi? ( dev-libs/fcgi )
	postgres? ( >=dev-db/postgresql-8.0 )
	readline? ( sys-libs/readline )
	pcre? ( dev-libs/libpcre )
	zlib? ( sys-libs/zlib )
	X? ( new-clx? ( x11-libs/libXpm ) )"

DEPEND="${RDEPEND}
	X? ( new-clx? ( x11-misc/imake x11-proto/xextproto ) )"

PROVIDE="virtual/commonlisp"

pkg_setup() {
	if use X; then
		if use new-clx; then
			elog "CLISP will be built with NEW-CLX support which is a C binding to Xorg libraries."
		else
			elog "CLISP will be built with MIT-CLX support."
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/2.41-fastcgi-Makefile-gentoo.patch
	epatch ${FILESDIR}/2.41-linux-headers.patch
}

src_compile() {
	CC="$(tc-getCC)"
	local myconf="--with-dynamic-ffi
		--with-module=wildcard
		--with-module=rawsock"
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
	einfo "Configuring with ${myconf}"
	./configure --prefix="${EPREFIX}"/usr ${myconf} build || die "./configure failed"
	cd build
	./makemake ${myconf} >Makefile
	emake -j1 config.lisp
	sed -i 's,"vi","nano",g' config.lisp
	sed -i 's,http://www.lisp.org/HyperSpec/,http://www.lispworks.com/reference/HyperSpec/,g' config.lisp
	emake -j1 || die
}

src_install() {
	pushd build
	make DESTDIR=${D} prefix="${EPREFIX}"/usr install-bin || die
	doman clisp.1
	dodoc SUMMARY README* NEWS MAGIC.add GNU-GPL COPYRIGHT \
		ANNOUNCE clisp.dvi clisp.html
	chmod a+x ${ED}/usr/lib/clisp/clisp-link
	popd
	dohtml doc/impnotes.{css,html}
	dohtml build/clisp.html
	dohtml doc/clisp.png
	dodoc build/clisp.ps
	dodoc doc/{editors,CLOS-guide,LISP-tutorial}.txt
}
