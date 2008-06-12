# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/antlr/antlr-2.7.7.ebuild,v 1.12 2008/04/05 09:56:54 betelgeuse Exp $

EAPI="prefix 1"

inherit base java-pkg-2 mono distutils multilib

DESCRIPTION="A parser generator for C++, C#, Java, and Python"
HOMEPAGE="http://www.antlr.org/"
SRC_URI="http://www.antlr.org/download/${P}.tar.gz"

LICENSE="ANTLR"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc debug examples mono +cxx +java python script source"

# TODO do we actually need jdk at runtime?
RDEPEND=">=virtual/jdk-1.3
	mono? ( dev-lang/mono )
	python? ( dev-lang/python )"
DEPEND="${RDEPEND}
	script? ( !dev-util/pccts )
	source? ( app-arch/zip )"

PATCHES=( "${FILESDIR}/2.7.7-gcc-4.3.patch" )

src_unpack() {
	base_src_unpack
}

src_compile() {
	# don't ask why, but this is needed for stuff to get built properly
	# across the various JDKs
	JAVACFLAGS="+ ${JAVACFLAGS}"

	# mcs for https://bugs.gentoo.org/show_bug.cgi?id=172104
	CSHARPC="mcs" econf $(use_enable java) \
		$(use_enable python) \
		$(use_enable mono csharp) \
		$(use_enable debug) \
		$(use_enable examples) \
		$(use_enable cxx) \
		--enable-verbose || die "configure failed"

	emake || die "compile failed"

	sed -e "s|@prefix@|${EPREFIX}/usr/|" \
		-e 's|@exec_prefix@|${prefix}|' \
		-e "s|@libdir@|\$\{exec_prefix\}/$(get_libdir)/antlr|" \
		-e 's|@libs@|-r:\$\{libdir\}/antlr.astframe.dll -r:\$\{libdir\}/antlr.runtime.dll|' \
		-e "s|@VERSION@|${PV}|" \
		"${FILESDIR}"/antlr.pc.in > "${S}"/antlr.pc
}

src_install() {
	exeinto /usr/bin
	doexe "${S}"/scripts/antlr-config

	if use cxx ; then
		cd "${S}"/lib/cpp
		einstall || die "failed to install C++ files"
	fi

	if use java ; then
		java-pkg_dojar "${S}"/antlr/antlr.jar

		use script && java-pkg_dolauncher antlr --main antlr.Tool

		use source && java-pkg_dosrc "${S}"/antlr
		use doc && java-pkg_dohtml -r doc/*
	fi

	if use mono ; then
		cd "${S}"/lib

		dodir /usr/$(get_libdir)/antlr/
		insinto /usr/$(get_libdir)/antlr/

		doins antlr.astframe.dll
		doins antlr.runtime.dll

		insinto /usr/$(get_libdir)/pkgconfig
		doins "${S}"/antlr.pc
	fi

	if use python ; then
		cd "${S}"/lib/python
		distutils_src_install
	fi

	if use examples ; then
		find "${S}"/examples -iname Makefile\* -exec rm \{\} \;

		dodir /usr/share/doc/${PF}/examples
		insinto /usr/share/doc/${PF}/examples

		use cxx && doins -r "${S}"/examples/cpp
		use java && doins -r "${S}"/examples/java
		use mono && doins -r "${S}"/examples/csharp
		use python && doins -r "${S}"/examples/python
	fi

	newdoc "${S}"/README.txt README || die
}
