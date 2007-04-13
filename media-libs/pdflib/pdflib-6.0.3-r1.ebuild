# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/pdflib/pdflib-6.0.3-r1.ebuild,v 1.2 2007/03/16 22:45:29 chtekk Exp $

EAPI="prefix"

# eutils must be inherited since get_libdir() is only
# globally available on baselayout-1.11 (still on ~arch)
inherit base eutils java-pkg-opt-2 flag-o-matic

MY_PN="${PN/pdf/PDF}-Lite"
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A library for generating PDF on the fly."
HOMEPAGE="http://www.pdflib.com/"
SRC_URI="http://www.pdflib.com/products/pdflib/download/${PV//./}src/${MY_P}.tar.gz"
LICENSE="Aladdin"
SLOT="5"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc tcl perl python java"

COMMON_DEP="
	>=sys-apps/sed-4
	tcl? ( >=dev-lang/tcl-8.2 )
	perl? ( >=dev-lang/perl-5.1 )
	python? ( >=dev-lang/python-2.2 )"

DEPEND="
	${COMMON_DEP}
	java? ( >=virtual/jdk-1.4 )"

RDEPEND="
	${COMMON_DEP}
	java? ( >=virtual/jre-1.4 )"

PATCHES="${FILESDIR}/fix-java-compile.patch"

src_compile() {
	local myconf

	# Bug #87004
	filter-flags -mcpu=*
	filter-flags -mtune=*

	PYVER="$(${EPREFIX}/usr/bin/python -V 2>&1 | cut -d ' ' -f 2 | cut -d '.' -f 1,2)"
	# Necessary for multilib on amd64. Please keep this in future releases.
	# BUG #81197
	# Danny van Dyk <kugelfang@gentoo.org> 2005/02/14
	TCLVER="$(echo 'puts [info tclversion]' | $(type -P tclsh))"
	use tcl \
		&& myconf="--with-tclpkg=${EPREFIX}/usr/$(get_libdir)/tcl${TCLVER}/" \
		|| myconf="--with-tcl=no"
	use perl || myconf="${myconf} --with-perl=no"
	use python \
		&& myconf="${myconf} --with-py=${EPREFIX}/usr --with-pyincl=${EPREFIX}/usr/include/python${PYVER}" \
		|| myconf="${myconf} --with-py=no"
	use java \
		&& myconf="${myconf} --with-java=${JAVA_HOME}" \
		|| myconf="${myconf} --with-java=no"

	econf \
		--enable-cxx \
		${myconf} || die

	JAVACFLAGS="$(java-pkg_javac-args)" emake || die "emake failed"
	if use java && use doc; then
		cd ./bind/pdflib/java || die
		emake javadoc || die "Failed to generate javadoc"
	fi
}

src_install() {
	sed -i \
		-e "s:^\(LANG_LIBDIR\).*= \(.*\):\1\t = ${D}/\2:" \
		"${S}/bind/pdflib/perl/Makefile" \
			|| die "sed bind/pdflib/perl/Makefile failed"

	sed -i \
		-e "s:^\(LANG_LIBDIR\).*= \(.*\):\1\t = ${D}/\2:" \
		"${S}/bind/pdflib/python/Makefile" \
			|| die "sed bind/pdflib/python/Makefile failed"

	sed -i \
		-e "s:^\(LANG_LIBDIR\).*= \(.*\):\1\t = ${D}/\2:" \
		"${S}/bind/pdflib/tcl/Makefile" \
			|| die "sed bind/pdflib/tcl/Makefile failed"

	# ok, this should create the correct lib dirs for perl and python.
	# yes, i know it is messy, but as i see it, a ebuild should be generic
	# ... ie. you should be able to just use cp to update it
	if use perl && [ -x "${EPREFIX}"/usr/bin/perl ] ; then
		local perlmajver="`${EPREFIX}/usr/bin/perl -v |grep 'This is perl' \
			|cut -d ' ' -f 4 |cut -d '.' -f 1`"
		local perlver="`${EPREFIX}/usr/bin/perl -v |grep 'This is perl' \
			|cut -d ' ' -f 4`"
		local perlarch="`/usr/bin/perl -v |grep 'This is perl' \
			|cut -d ' ' -f 7`"
		dodir /usr/$(get_libdir)/perl${perlmajver/v/}/site_perl/${perlver/v/}/${perlarch}
	fi
	if use python && [ -x "${EPREFIX}"/usr/bin/python ] ; then
		dodir /usr/$(get_libdir)/python${PYVER}/lib-dynload
	fi
	#next line required for proper install
	dodir /usr/bin
	einstall || die

	dodoc readme.txt doc/*
	docinto pdflib
	dodoc doc/pdflib/*

	# seemant: seems like the makefiles for pdflib generate the .jar file
	# anyway
	use java && java-pkg_dojar bind/pdflib/java/pdflib.jar
	if use java && use doc; then
		java-pkg_dojavadoc ./bind/pdflib/java/javadoc
	fi
}
