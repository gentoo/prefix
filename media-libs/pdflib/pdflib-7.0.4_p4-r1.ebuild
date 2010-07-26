# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/pdflib/pdflib-7.0.4_p4-r1.ebuild,v 1.1 2010/04/02 20:40:17 mabi Exp $

EAPI="1"

PYTHON_DEPEND="*"
RUBY_OPTIONAL="yes"
inherit autotools libtool versionator flag-o-matic toolchain-funcs multilib perl-module java-pkg-opt-2 python ruby

MY_PN="${PN/pdf/PDF}-Lite"
MY_P="${MY_PN}-${PV/_/}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A library for generating PDF on the fly."
HOMEPAGE="http://www.pdflib.com/"
SRC_URI="http://www.pdflib.com/binaries/${PN/pdf/PDF}/$(delete_all_version_separators ${PV/_*/})/${MY_P}.tar.gz"
LICENSE="PDFLite"
SLOT="5"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="+cxx doc java perl python ruby tcl"

COMMON_DEP="tcl? ( >=dev-lang/tcl-8.2 )
	    perl? ( >=dev-lang/perl-5.1 )
	    python? ( >=dev-lang/python-2.2 )
	    ruby? ( dev-lang/ruby )"

DEPEND="${COMMON_DEP}
	java? ( >=virtual/jdk-1.4 )"

RDEPEND="
	${COMMON_DEP}
	java? ( >=virtual/jre-1.4 )"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	use perl && perl-module_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-7.0.2-darwin.patch

	epatch "${FILESDIR}/${PN}-noexec-stack.patch"
	epatch "${FILESDIR}/${PN}-python-libdir.patch"
	epatch "${FILESDIR}/${PN}-perl-vendor-dir.patch"
	sed -ie 's/-module/-module -avoid-version -shared/' config/mkbind.inc.in

	# eautoreconf breaks the build
	eautoconf
	elibtoolize
}

src_compile() {
	local myconf

	# Bug #87004
	filter-flags -mcpu=* -mtune=*

	# silence QA warnings, feel free to fix properly
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
	use ruby \
		&& myconf="${myconf} --with-ruby=${RUBY}" \
		|| myconf="${myconf} --with-ruby=no"

	# totally screws configure:
	# econf "--enable-static=no ${myconf}"
	econf ${myconf}

	if use java; then
		emake || die "emake failed"
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

	# this should create the correct lib dir for perl (bug #298019)
	if use perl ; then
		perlinfo
		fixlocalpod
	fi

	# and no, emake still does not work for install
	einstall || die "einstall failed"

	dodoc readme.txt doc/*
	docinto pdflib
	dodoc doc/pdflib/*

	if use java ; then
		java-pkg_dojar bind/pdflib/java/pdflib.jar
		java-pkg_regso "${ED}/usr/$(get_libdir)/libpdf_java.so"
		use doc && java-pkg_dojavadoc ./bind/pdflib/java/javadoc
	fi

	# Lot of hakku for ruby
	if use ruby ; then
		local RUBYLIBDIR=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitelibdir"]')
		insinto ${RUBYLIBDIR}
		insopts -m 0755
		doins ./bind/pdflib/ruby/*.rb
		RUBYLIBDIR=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitearchdir"]')
		dodir ${RUBYLIBDIR}
		mv "${ED}/usr/$(get_libdir)"/PDFlib.* "${ED}/${RUBYLIBDIR}"/
		cp ./bind/pdflib/ruby/pdflib_ruby.lo "${ED}/${RUBYLIBDIR}"/pdflib_ruby.so
		chmod 0755 "${ED}/${RUBYLIBDIR}"/*.so*
	fi

}

pkg_preinst () {
	perl-module_pkg_preinst
	has_version "<${CATEGORY}/${PN}-7.0.3"
	previous_less_than_7_0_3=$?
}

pkg_postinst() {
	if [[ $previous_less_than_7_0_3 = 0 ]] ; then
		ewarn "Please run revdep-rebuild now! All packages linked with"
		ewarn "previous versions of PDFLib will no longer work unless you do."
	fi
}
