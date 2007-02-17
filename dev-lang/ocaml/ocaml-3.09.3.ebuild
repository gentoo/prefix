# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ocaml/ocaml-3.09.3.ebuild,v 1.7 2007/02/06 08:26:45 genone Exp $

EAPI="prefix"

inherit flag-o-matic eutils multilib

DESCRIPTION="fast modern type-inferring functional programming language descended from the ML (Meta Language) family"
HOMEPAGE="http://www.ocaml.org/"

SRC_URI="http://caml.inria.fr/distrib/ocaml-3.09/${P}.tar.bz2"

LICENSE="QPL-1.0 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="tk latex"

DEPEND="virtual/libc
	tk? ( >=dev-lang/tk-3.3.3 )"

pkg_setup() {
	ewarn
	ewarn "Building ocaml with unsafe CFLAGS can have unexpected results"
	ewarn "Please retry building with safer CFLAGS before reporting bugs"
	ewarn "Likewise, building with a hardened gcc is not possible."
	ewarn
}

src_compile() {
	filter-flags "-fstack-protector"
	replace-flags "-O?" -O2

	local myconf
	use tk || myconf="-no-tk"

	# Fix for kernel_arch != system_ach (bug #135641)
	myconf="${myconf} -host ${CHOST}"

	# Fix for bug #46703
	export LC_ALL=C

	./configure -prefix "${EPREFIX}"/usr \
		-bindir "${EPREFIX}"/usr/bin \
		-libdir "${EPREFIX}"/usr/$(get_libdir)/ocaml \
		-mandir "${EPREFIX}"/usr/share/man \
		--with-pthread ${myconf} || die

	sed -i -e "s/\(BYTECCCOMPOPTS=.*\)/\1 ${CFLAGS}/" config/Makefile
	sed -i -e "s/\(NATIVECCCOMPOPTS=.*\)/\1 ${CFLAGS}/" config/Makefile

	make world || die

	# Native code generation unsupported on some archs
	if ! use ppc64 ; then
		make opt || die
		make opt.opt || die
	fi
}

src_test() {
	make bootstrap
}

src_install() {
	make BINDIR=${ED}/usr/bin \
		LIBDIR=${ED}/usr/$(get_libdir)/ocaml \
		MANDIR=${ED}/usr/share/man \
		install || die

	# compiler libs
	dodir /usr/lib/ocaml/compiler-libs
	insinto /usr/lib/ocaml/compiler-libs
	doins {utils,typing,parsing}/*.{mli,cmi,cmo,cmx,o}

	# headers
	dodir /usr/include
	dosym /usr/lib/ocaml/caml /usr/include/

	# silly, silly makefiles
	dosed "s:${ED}::g" /usr/$(get_libdir)/ocaml/ld.conf

	# documentation
	dodoc Changes INSTALL LICENSE README Upgrading
}

pkg_postinst() {
	if use latex; then
		echo "TEXINPUTS=${EPREFIX}/usr/$(get_libdir)/ocaml/ocamldoc:" > "${EPREFIX}"/etc/env.d/99ocamldoc
	fi

	echo
	elog "OCaml is not binary compatible from version to version,"
	elog "so you (may) need to rebuild all packages depending on it that"
	elog "are actually installed on your system."
	elog "To do so, you can run: "
	elog "sh ${FILESDIR}/ocaml-rebuild.sh [-h | emerge options]"
	elog "Which will call emerge on all old packages with the given options"
	echo
}
