# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/clisp/clisp-2.43-r1.ebuild,v 1.5 2008/05/21 15:59:59 dev-zero Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs multilib

DESCRIPTION="A portable, bytecode-compiled implementation of Common Lisp"
HOMEPAGE="http://clisp.sourceforge.net/"
SRC_URI="mirror://sourceforge/clisp/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""
IUSE="X new-clx fastcgi gdbm gtk pcre postgres readline svm zlib"

RDEPEND="dev-lisp/gentoo-init
		 >=dev-libs/libsigsegv-2.4
		 virtual/tetex
		 fastcgi? ( dev-libs/fcgi )
		 gdbm? ( sys-libs/gdbm )
		 gtk? ( >=x11-libs/gtk+-2.10 >=gnome-base/libglade-2.6 )
		 postgres? ( >=virtual/postgresql-server-8.0 )
		 readline? ( sys-libs/readline )
		 pcre? ( dev-libs/libpcre )
		 svm? ( sci-libs/libsvm )
		 zlib? ( sys-libs/zlib )
		 X? ( new-clx? ( x11-libs/libXpm ) )"
#   * GNU gettext
#      + Not needed on systems with glibc 2.2 or newer, but recommended on all
#        other systems: needed if you want clisp with native language support.
#	sys-devel/gettext

DEPEND="${RDEPEND} X? ( new-clx? ( x11-misc/imake x11-proto/xextproto ) )"

PROVIDE="virtual/commonlisp"

enable_modules() {
	[[ $# = 0 ]] && die "${FUNCNAME[0]} must receive at least one argument"
	for m in "$@" ; do
		einfo "enabling module $m"
		myconf="${myconf} --with-module=${m}"
	done
}

BUILDDIR="builddir"

src_compile() {
	CC="$(tc-getCC)"

	# built-in features
	local myconf="--with-dynamic-ffi"
	use readline || myconf="${myconf} --with-noreadline"

	# default modules
	enable_modules wildcard rawsock i18n
	# optional modules
	use elibc_glibc && enable_modules bindings/glibc
	if use X; then
		if use new-clx; then
			enable_modules clx/new-clx
		else
			enable_modules clx/mit-clx
		fi
	fi
	if use postgres; then
		enable_modules postgresql
		CC="${CC} -I $(pg_config --includedir)"
	fi
	use fastcgi && enable_modules fastcgi
	use gdbm && enable_modules gdbm
	use gtk && enable_modules gtk2
	use pcre && enable_modules pcre
	use svm && enable_modules libsvm
	use zlib && enable_modules zlib

	# configure chokes on --infodir option
	./configure --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) \
		${myconf} ${BUILDDIR} || die "./configure failed"
	cd ${BUILDDIR}
	./makemake ${myconf} > Makefile
#	emake config.lisp
#	sed -i 's,"vi","nano",g' config.lisp
	# parallel build fails
	emake -j1 || die "emake failed"
}

src_install() {
	pushd ${BUILDDIR}
	make DESTDIR="${D}" prefix="${EPREFIX}"/usr install-bin || die
	doman clisp.1
	dodoc SUMMARY README* NEWS MAGIC.add ANNOUNCE clisp.dvi clisp.html
	chmod a+x "${ED}"/usr/$(get_libdir)/clisp-${PV}/clisp-link
	popd
	dohtml doc/impnotes.{css,html} ${BUILDDIR}/clisp.html doc/clisp.png
	dodoc ${BUILDDIR}/clisp.ps doc/{editors,CLOS-guide,LISP-tutorial}.txt
}
