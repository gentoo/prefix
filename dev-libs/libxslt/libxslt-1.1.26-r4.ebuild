# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxslt/libxslt-1.1.26-r4.ebuild,v 1.5 2012/09/23 17:30:21 armin76 Exp $

EAPI="4"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython *-pypy-*"

inherit autotools eutils python toolchain-funcs

DESCRIPTION="XSLT libraries and tools"
HOMEPAGE="http://www.xmlsoft.org/"
SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="crypt debug python static-libs"

DEPEND=">=dev-libs/libxml2-2.6.27:2
	crypt?  ( >=dev-libs/libgcrypt-1.1.42 )"
RDEPEND="${DEPEND}"

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi
	DOCS="AUTHORS ChangeLog FEATURES NEWS README TODO"
}

src_prepare() {
	epatch "${FILESDIR}"/libxslt.m4-${P}.patch \
		"${FILESDIR}"/${PN}-1.1.23-parallel-install.patch \
		"${FILESDIR}"/${P}-undefined.patch \
		"${FILESDIR}"/${P}-disable_static_modules.patch

	epatch "${FILESDIR}"/${P}-versionscript-solaris.patch

	# Python bindings are built/tested/installed manually.
	sed -e "s/@PYTHON_SUBDIR@//" -i Makefile.am || die "sed failed"

	# Fix generate-id() to not expose object addresses, bug #358615
	epatch "${FILESDIR}/${P}-id-generation.patch"

	# Fix off-by-one in xsltCompilePatternInternal, bug #402861
	epatch "${FILESDIR}/${P}-pattern-out-of-bounds-read.patch"

	# Namespace nodes require special treatment, bug #433603
	epatch "${FILESDIR}/${P}-node-type-"{1,2,3}.patch

	# Use-after-free errors, bug #433603
	epatch "${FILESDIR}/${P}-pattern-compile-crash.patch"
	epatch "${FILESDIR}/${P}-generate-id-crash.patch"

	# Build fix for freebsd, bug #420335
	epatch "${FILESDIR}/${P}-posix-comparison.patch"

	eautoreconf # also needed for new libtool on Interix
	epunt_cxx
	elibtoolize
}

src_configure() {
	# libgcrypt is missing pkg-config file, so fixing cross-compile
	# here. see bug 267503.
	if tc-is-cross-compiler; then
		export LIBGCRYPT_CONFIG="${SYSROOT}/usr/bin/libgcrypt-config"
	fi

	econf \
		--disable-dependency-tracking \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-html-subdir=html \
		$(use_with crypt crypto) \
		$(use_with python) \
		$(use_with debug) \
		$(use_with debug mem-debug) \
		$(use_enable static-libs static)
}

src_compile() {
	default

	if use python; then
		python_copy_sources python
		building() {
			emake PYTHON_INCLUDES="${EPREFIX}$(python_get_includedir)" \
				PYTHON_SITE_PACKAGES="${EPREFIX}$(python_get_sitedir)" \
				PYTHON_VERSION="$(python_get_version)"
		}
		python_execute_function -s --source-dir python building
	fi
}

src_test() {
	default

	if use python; then
		testing() {
			emake test
		}
		python_execute_function -s --source-dir python testing
	fi
}

src_install() {
	default

	if use python; then
		installation() {
			emake DESTDIR="${D}" \
				PYTHON_SITE_PACKAGES="${EPREFIX}$(python_get_sitedir)" \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi

	mv -vf "${ED}"/usr/share/doc/${PN}-python-${PV} \
		"${ED}"/usr/share/doc/${PF}/python

	if ! use static-libs; then
		# Remove useless .la files
		find "${ED}" -name '*.la' -exec rm -f {} + || die "la file removal failed"
	fi
}

pkg_postinst() {
	if use python; then
		python_mod_optimize libxslt.py
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup libxslt.py
	fi
}
