# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/pdflib/pdflib-7.0.2.ebuild,v 1.11 2008/06/14 17:49:57 zmedico Exp $

inherit java-pkg-opt-2 flag-o-matic libtool python perl-module multilib

MY_PN="${PN/pdf/PDF}-Lite"
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A library for generating PDF on the fly."
HOMEPAGE="http://www.pdflib.com/"
SRC_URI="http://www.pdflib.com/binaries/${PN/pdf/PDF}/${PV//./}/${MY_P}.tar.gz"
LICENSE="PDFLite"
SLOT="5"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc java perl python tcl"

COMMON_DEP="tcl? ( >=dev-lang/tcl-8.2 )
	    perl? ( >=dev-lang/perl-5.1 )
	    python? ( >=dev-lang/python-2.2 )"

DEPEND="${COMMON_DEP}
	java? ( >=virtual/jdk-1.4 )"

RDEPEND="
	${COMMON_DEP}
	java? ( >=virtual/jre-1.4 )"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	perl-module_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-darwin.patch

	elibtoolize
}

src_compile() {
	local myconf

	# Bug #87004
	filter-flags -mcpu=*
	filter-flags -mtune=*

	[[ ${CHOST} == *-linux-* ]] && append-ldflags -Wl,-z,noexecstack

	PYVER="$(${EPREFIX}/usr/bin/python -V 2>&1 | cut -d ' ' -f 2 | cut -d '.' -f 1,2)"
	# Necessary for multilib on amd64. Please keep this in future releases.
	# BUG #81197
	# Danny van Dyk <kugelfang@gentoo.org> 2005/02/14
	if use tcl ; then
		TCLVER="$(echo 'puts [info tclversion]' | $(type -P tclsh))"
		myconf="--with-tclpkg=${EPREFIX}/usr/$(get_libdir)/tcl${TCLVER}/"
	else
		myconf="--with-tcl=no"
	fi
	use perl || myconf="${myconf} --with-perl=no"
	if use python ; then
		python_version
		myconf="${myconf} --with-py=${EPREFIX}/usr --with-pyincl=${EPREFIX}/usr/include/python${PYVER}"
	else
		myconf="${myconf} --with-py=no"
	fi
	use java \
		&& myconf="${myconf} --with-java=${JAVA_HOME}" \
		|| myconf="${myconf} --with-java=no"

	econf --enable-cxx ${myconf}

	if use java; then
		JAVACFLAGS="$(java-pkg_javac-args)" emake || die "emake failed"
		if use doc; then
			cd ./bind/pdflib/java || die
			emake javadoc || die "Failed to generate javadoc"
		fi
	else
		emake || die "emake failed"
	fi
}

src_install() {
	for binding in perl python tcl ; do
		sed -i \
			-e "s:^\(LANG_LIBDIR\).*= \(.*\):\1\t = ${D}/\2:" \
			"${S}/bind/pdflib/${binding}/Makefile" \
				|| die "sed bind/pdflib/${binding}/Makefile failed"
	done

	# this should create the correct lib dirs for perl and python.
	if use python ; then
		python_version
		dodir /usr/$(get_libdir)/python${PYVER}/lib-dynload
	fi
	if use perl ; then
		perlinfo
		dodir ${SITE_ARCH}
	fi

	# next line required for proper install
	dodir /usr/bin
	einstall || die

	dodoc readme.txt doc/*
	docinto pdflib
	dodoc doc/pdflib/*

	# seemant: seems like the makefiles for pdflib generate the .jar file anyway
	use java && java-pkg_dojar bind/pdflib/java/pdflib.jar
	if use java && use doc; then
		java-pkg_dojavadoc ./bind/pdflib/java/javadoc
	fi
}

pkg_preinst () {
	perl-module_pkg_preinst
	has_version "<${CATEGORY}/${PN}-7.0.1"
	previous_less_than_7_0_1=$?
}

pkg_postinst() {
	if [[ $previous_less_than_7_0_1 = 0 ]] ; then
		ewarn "Please run revdep-rebuild now! All packages that linked with"
		ewarn "previous versions of PDFLib will no longer work unless you"
		ewarn "run it."
	fi
}
