# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ocaml/ocaml-3.09.3-r1.ebuild,v 1.13 2007/05/15 22:29:52 jer Exp $

EAPI="prefix"

inherit flag-o-matic eutils multilib pax-utils versionator toolchain-funcs

DESCRIPTION="fast modern type-inferring functional programming language descended from the ML (Meta Language) family"
HOMEPAGE="http://www.ocaml.org/"
SRC_URI="http://caml.inria.fr/distrib/ocaml-$( get_version_component_range 1-2 )/${P}.tar.bz2"

LICENSE="QPL-1.0 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="gdbm ncurses tk latex X"

DEPEND="tk? ( >=dev-lang/tk-3.3.3 )
	ncurses? ( sys-libs/ncurses )
	X? ( x11-libs/libX11 x11-proto/xproto )
	gdbm? ( sys-libs/gdbm )"

# ocaml deletes the *.opt files when running make bootstrap

QA_EXECSTACK="${EPREFIX}/usr/lib/ocaml/compiler-*"

pkg_setup() {
	# dev-lang/ocaml fails with -fPIC errors due to a "relocation R_X86_64_32S" on AMD64/hardened
	if use amd64 && gcc-specs-pie ; then
		echo
		eerror "${CATEGORY}/${PF} is currently broken on this platform with specfiles injecting -PIE."
		eerror "Please switch to your \"${CHOST}-$(gcc-fullversion)-hardenednopie\" specfile via gcc-config!"
		die "Current specfile (${CHOST}-$(gcc-fullversion)) not supported by ${PF}!"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix the EXEC_STACK in ocaml compiled binaries (#153382)
	epatch "${FILESDIR}"/${P}-exec-stack-fixes.patch

	# Quick and somewhat dirty fix for bug #110541
	epatch "${FILESDIR}"/${P}-execheap.patch

	# The configure script doesn't inherit previous defined variables, 
	# overwriting previous declarations of bytecccompopts, bytecclinkopts,
	# nativecccompopts and nativecclinkopts. Reported upstream as issue 0004267.
	epatch "${FILESDIR}"/${P}-configure.patch

	# The sed in the Makefile doesn't replace all occurences of @compiler@
	# in driver/ocamlcomp.sh.in. Reported upstream as issue 0004268.
	epatch "${FILESDIR}"/${P}-Makefile.patch


	# ocaml has automagics on libX11 and gdbm
	# http://caml.inria.fr/mantis/view.php?id=4278
	epatch "${FILESDIR}/${P}-automagic.patch"

	# Call ld with proper flags, different from gcc ones
	# This happens when calling ocamlc -pack
	# See comment in the patch
	epatch "${FILESDIR}/${P}-call_ld_with_proper_flags.patch"

	# Ocaml native code generation for hppa has a bug
	# See comments in the patch
	# http://bugs.gentoo.org/show_bug.cgi?id=178256
	use hppa && epatch "${FILESDIR}/${P}-hppa-optimize-for-size-ocamlp4.patch"

	# Change the configure script to add the CFLAGS to bytecccompopts, LDFLAGS
	# to bytecclinkopts.
	sed -i -e "s,bytecccompopts=\"\",bytecccompopts=\"\${CFLAGS}\"," \
		-e "s,bytecclinkopts=\"\",bytecclinkopts=\"\${LDFLAGS}\"," \
		"${S}"/configure
}

src_compile() {
	local myconf="--host ${CHOST}"

	# dev-lang/ocaml tends to break/give unexpected results with "unsafe" CFLAGS.
	strip-flags
	replace-flags "-O?" -O2

	use tk || myconf="${myconf} -no-tk"
	use ncurses || myconf="${myconf} -no-curses"
	use X || myconf="${myconf} -no-graph"
	use gdbm || myconf="${myconf} -no-dbm"

	# ocaml uses a home-brewn configure script, preventing it to use econf.
	./configure -prefix "${EPREFIX}"/usr \
		-bindir "${EPREFIX}"/usr/bin \
		-libdir "${EPREFIX}"/usr/$(get_libdir)/ocaml \
		-mandir "${EPREFIX}"/usr/share/man \
		--with-pthread ${myconf} || die "configure failed!"

	make world || die "make world failed!"

	# Native code generation is unsupported on some archs
	if ! use ppc64 ; then
		make opt || die "make opt failed!"
		make opt.opt || die "make opt.opt failed!"
	fi
}

src_install() {
	make BINDIR="${ED}"/usr/bin \
		LIBDIR="${ED}"/usr/$(get_libdir)/ocaml \
		MANDIR="${ED}"/usr/share/man \
		install || die "make install failed!"

	# Install the compiler libs
	dodir /usr/$(get_libdir)/ocaml/compiler-libs
	insinto /usr/$(get_libdir)/ocaml/compiler-libs
	doins {utils,typing,parsing}/*.{mli,cmi,cmo,cmx,o}

	# Symlink the headers to the right place
	dodir /usr/include
	dosym /usr/$(get_libdir)/ocaml/caml /usr/include/

	# Remove ${ED} from ld.conf, as the buildsystem isn't $(DESTDIR) aware
	dosed "s:${ED}::g" /usr/$(get_libdir)/ocaml/ld.conf

	dodoc Changes INSTALL LICENSE README Upgrading

	# Turn MPROTECT off for some of the ocaml binaries, since they are trying to
	# rewrite the segment (which will obviously fail on systems having
	# PAX_MPROTECT enabled).
	pax-mark -m "${ED}"/usr/bin/ocamldoc.opt "${ED}"/usr/bin/ocamldep.opt \
		"${ED}"/usr/bin/ocamllex.opt "${ED}"/usr/bin/camlp4r.opt \
		"${ED}"/usr/bin/camlp4o.opt

	# Create and envd entry for latex input files (this definitely belongs into
	# CONTENT and not in pkg_postinst.
	if use latex ; then
		echo "TEXINPUTS=${EPREFIX}/usr/$(get_libdir)/ocaml/ocamldoc:" > "${T}"/99ocamldoc
		doenvd "${T}"/99ocamldoc
	fi

	# Install ocaml-rebuild.sh script rather than keeping it in $PORTDIR
	dosbin "${FILESDIR}/ocaml-rebuild.sh"
}

pkg_postinst() {
	if use amd64 && gcc-specs-ssp ; then
		ewarn
		ewarn "Make sure, you switch back to the default specfile ${CHOST}-$(gcc-fullversion) via gcc-config!"
		ewarn
	fi

	echo
	elog "OCaml is not binary compatible from version to version, so you (may)"
	elog "need to rebuild all packages depending on it, that are actually"
	elog "installed on your system. To do so, you can run:"
	elog "/usr/sbin/ocaml-rebuild.sh [-h | emerge options]"
	elog "Which will call emerge on all old packages with the given options"
	echo
}
