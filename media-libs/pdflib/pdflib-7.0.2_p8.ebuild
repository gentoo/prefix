# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/pdflib/pdflib-7.0.2_p8.ebuild,v 1.12 2010/05/28 18:05:21 arfrever Exp $

EAPI=1

# RUBY_OPTIONAL="yes"
inherit autotools libtool versionator flag-o-matic toolchain-funcs multilib perl-module java-pkg-opt-2 python # ruby

MY_PN="${PN/pdf/PDF}-Lite"
MY_P="${MY_PN}-${PV/_/}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A library for generating PDF on the fly."
HOMEPAGE="http://www.pdflib.com/"
SRC_URI="http://www.pdflib.com/binaries/${PN/pdf/PDF}/$(delete_all_version_separators ${PV/_*/})/${MY_P}.tar.gz"
LICENSE="PDFLite"
SLOT="5"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="+cxx doc java perl python tcl" # ruby

COMMON_DEP="tcl? ( >=dev-lang/tcl-8.2 )
	    perl? ( >=dev-lang/perl-5.1 )
	    python? ( >=dev-lang/python-2.2 )"
	    # ruby? ( virtual/ruby )

DEPEND="${COMMON_DEP}
	java? ( >=virtual/jdk-1.4 )"

RDEPEND="
	${COMMON_DEP}
	java? ( >=virtual/jre-1.4 )"

pkg_setup() {
	use java && java-pkg-opt-2_pkg_setup
	use perl && perl-module_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-7.0.2-darwin.patch

	epatch "${FILESDIR}"/${P}-gcc-4.3.patch

	# fix broken configure option for ruby bindings.
	# do NOT call eautoreconf here, it breaks configure horribly.
	epatch "${FILESDIR}"/${P}-ruby-configure.patch
	eautoconf
	elibtoolize
}

src_compile() {
	local myconf

	# Bug #87004
	filter-flags -mcpu=* -mtune=*

	# silence QA warnings, feel free to fix properly
	[[ ${CHOST} == *-linux-* ]] && append-ldflags -Wl,-z,noexecstack
	append-flags -fno-strict-aliasing

	# fix crosscompile for C++ bindings
	use cxx && tc-export CXX

	local myconf
	use cxx || myconf="${myconf} --with-cxx=no"

	use java \
		&& myconf="${myconf} --with-java=${JAVA_HOME}" \
		|| myconf="${myconf} --with-java=no"

	use perl || myconf="${myconf} --with-perl=no"

	if use python ; then
		myconf="${myconf} --with-py=${EPREFIX}/usr --with-pyincl=${EPREFIX}$(python_get_includedir)"
	else
		myconf="${myconf} --with-py=no"
	fi

	# Necessary for multilib on amd64. Please keep this in future releases.
	# BUG #81197
	# Danny van Dyk <kugelfang@gentoo.org> 2005/02/14
	if use tcl ; then
		TCLVER="$(echo 'puts [info tclversion]' | $(type -P tclsh))"
		myconf="${myconf} --with-tclpkg=${EPREFIX}/usr/$(get_libdir)/tcl${TCLVER}/"
	else
		myconf="${myconf} --with-tcl=no"
	fi

	# ruby bindings disabled for now, configure uses hardcoded list of paths
	# for includes that do not cover all supported arches on Gentoo
	# use ruby \
	#	&& myconf="${myconf} --with-ruby=${RUBY}"
	#	|| myconf="${myconf} --with-ruby=no"

	econf --with-ruby=no ${myconf}

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
		dodir $(python_get_libdir)/lib-dynload
	fi
	if use perl ; then
		perlinfo
		dodir ${SITE_ARCH#${EPREFIX}}
	fi

	# and no, emake still does not work for install
	einstall || die "einstall failed"

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
}

pkg_postinst() {
	true
}
