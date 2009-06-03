# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxslt/libxslt-1.1.24-r1.ebuild,v 1.3 2009/05/31 23:10:10 eva Exp $

inherit libtool eutils python autotools

DESCRIPTION="XSLT libraries and tools"
HOMEPAGE="http://www.xmlsoft.org/"
SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="crypt debug examples python"

RDEPEND=">=dev-libs/libxml2-2.6.27
	crypt?  ( >=dev-libs/libgcrypt-1.1.92 )
	python? ( dev-lang/python )"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# we still require the 1.1.8 patch for the .m4 file, to add
	# the CXXFLAGS defines <obz@gentoo.org>
	epatch "${FILESDIR}/libxslt.m4-${PN}-1.1.8.patch"

	# fix parallel install, bug #212784.
	epatch "${FILESDIR}/${PN}-1.1.23-parallel-install.patch"

	# Patch Makefile to fix bug #99382 so that html gets installed in ${PF}
	sed -i -e "s:libxslt-\$(VERSION):${PF}:" doc/Makefile.am

	# Fix broken <python-2.5 site-packages detection
	# see bug #86756 and bug #218643
	python_version
	sed -i "s:^\(AC_SUBST(PYTHON_SITE_PACKAGES)\):PYTHON_SITE_PACKAGES=\"${EPREFIX}/usr/$(get_libdir)/python${PYVER}/site-packages\"\n\1:" configure.in

	# Fix broken rc4 encrypt.  bug #232172
	epatch "${FILESDIR}/${P}-exslt_crypt.patch"

	eautoreconf # also needed for new libtool on Interix
	epunt_cxx
	elibtoolize
}

src_compile() {
	local myconf="$(use_with python) \
		$(use_with crypt crypto) \
		$(use_with debug)        \
		$(use_with debug mem-debug)"

	econf ${myconf}
	emake || die "Compilation failed"
}

src_install() {
	emake DESTDIR="${ED}" \
		DOCS_DIR=/usr/share/doc/${PF}/python \
		install || die "Installation failed"

	dodoc AUTHORS ChangeLog Copyright FEATURES NEWS README TODO || die "dodoc failed"
	rm -rf "${ED}/usr/share/doc/${PN}-python-${PV}"

	if ! use examples; then
		rm -rf "${ED}/usr/share/doc/${PF}/python/examples"
	fi
}
