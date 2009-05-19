# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/expect/expect-5.44.1.ebuild,v 1.4 2009/05/16 13:11:21 flameeyes Exp $

WANT_AUTOCONF="2.5"
inherit autotools eutils

DESCRIPTION="tool for automating interactive applications"
HOMEPAGE="http://expect.nist.gov/"
SRC_URI="http://expect.nist.gov/src/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE="X doc"

# We need dejagnu for src_test, but dejagnu needs expect
# to compile/run, so we cant add dejagnu to DEPEND :/
DEPEND=">=dev-lang/tcl-8.2
	>=dev-lang/tk-8.2"
RDEPEND="${DEPEND}"

RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix install_name on darwin
	[[ ${CHOST} == *-darwin* ]] && \
		epatch "${FILESDIR}"/${PN}-5.43.0-darwin.patch

	sed -i "s#/usr/local/bin#${EPREFIX}/usr/bin#" expect.man
	sed -i "s#/usr/local/bin#${EPREFIX}/usr/bin#" expectk.man
	#stops any example scripts being installed by default
	sed -i \
		-e '/^install:/s/install-libraries //' \
		-e 's/^SCRIPTS_MANPAGES = /_&/' \
		Makefile.in

	#they forgot to include expect.m4 (now it's in expect cvs)
	cp "${FILESDIR}/expect.m4" .
	#configure broken for testsuite
	sed -i -e 's/^AC_CONFIG_SUBDIRS(testsuite)$//' configure.in
	#fixes "TCL_REG_BOSONLY undeclared" error due to a change in tcl8.5
	sed -i -e 's/^#include "tcl.h"/#include "tclInt.h"/' exp_inter.c
	#slacky destdir support in Makefile
	epatch "${FILESDIR}/${P}-destdir.patch"

	epatch "${FILESDIR}/${P}-gfbsd.patch"

	eautoconf
}

src_compile() {
	local myconf
	local tclv
	local tkv
	# Find the version of tcl/tk that has headers installed.
	# This will be the most recently merged, not necessarily the highest
	# version number.
	tclv=$(grep TCL_VER ${EPREFIX}/usr/include/tcl.h | sed 's/^.*"\(.*\)".*/\1/')
	#tkv isn't really needed, included for symmetry and the future
	#tkv=$(grep	 TK_VER /usr/include/tk.h  | sed 's/^.*"\(.*\)".*/\1/')

	#configure needs to find the files tclConfig.sh and tclInt.h
	myconf="--with-tcl=${EPREFIX}/usr/$(get_libdir) --with-tclinclude=${EPREFIX}/usr/$(get_libdir)/tcl${tclv}/include/generic"

	if use X ; then
		#--with-x is enabled by default
		#configure needs to find the file tkConfig.sh and tk.h
		#tk.h is in /usr/lib so don't need to explicitly set --with-tkinclude
		myconf="$myconf --with-tk=${EPREFIX}/usr/$(get_libdir)"
	else
		#configure knows that tk depends on X so just disable X
		myconf="$myconf --without-x"
	fi

	econf $myconf --enable-shared || die "econf failed"
	emake || die "emake failed"
}

src_test() {
	# we need dejagnu to do tests ... but dejagnu needs
	# expect ... so don't do tests unless we have dejagnu
	type -p runtest || return 0
	make check || die "make check failed"
}

src_install() {
	dodir /usr/$(get_libdir)
	make install DESTDIR="${D}" || die "make install failed"

	dodoc ChangeLog FAQ HISTORY NEWS README

	local static_lib="lib${NON_MICRO_V/-/}.a"
	rm "${ED}"/usr/$(get_libdir)/${NON_MICRO_V/-/}/${static_lib}

	#install examples if 'doc' is set
	if use doc ; then
		docinto examples
		local scripts=$(make -qp | \
						sed -e 's/^SCRIPTS = //' -et -ed | head -n1)
		exeinto /usr/share/doc/${PF}/examples
		doexe ${scripts}
		local scripts_manpages=$(make -qp | \
			   sed -e 's/^_SCRIPTS_MANPAGES = //' -et -ed | head -n1)
		for m in ${scripts_manpages}; do
			dodoc example/${m}.man
		done
		dodoc example/README
	fi
}
