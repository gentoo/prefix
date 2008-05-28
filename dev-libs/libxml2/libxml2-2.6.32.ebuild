# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxml2/libxml2-2.6.32.ebuild,v 1.1 2008/05/27 15:35:19 remi Exp $

EAPI="prefix"

inherit libtool flag-o-matic eutils

DESCRIPTION="Version 2 of the library to manipulate XML files"
HOMEPAGE="http://www.xmlsoft.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bootstrap build debug doc examples ipv6 python readline test"

XSTS_HOME="http://www.w3.org/XML/2004/xml-schema-test-suite"
XSTS_NAME_1="xmlschema2002-01-16"
XSTS_NAME_2="xmlschema2006-11-06"
XSTS_TARBALL_1="xsts-2002-01-16.tar.gz"
XSTS_TARBALL_2="xsts-2006-11-06.tar.gz"

SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz
	test? (
		${XSTS_HOME}/${XSTS_NAME_1}/${XSTS_TARBALL_1}
		${XSTS_HOME}/${XSTS_NAME_2}/${XSTS_TARBALL_2} )"

RDEPEND="sys-libs/zlib
	python?   ( dev-lang/python )
	readline? ( sys-libs/readline )"

DEPEND="${RDEPEND}
	hppa? ( >=sys-devel/binutils-2.15.92.0.2 )"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	if use test; then
		cp "${DISTDIR}/${XSTS_TARBALL_1}" \
			"${DISTDIR}/${XSTS_TARBALL_2}" \
			"${S}"/xstc/ \
			|| die "Failed to install test tarballs"
	fi

	epatch "${FILESDIR}"/${PN}-2.6.29-catalog_path.patch

	eprefixify catalog.c runtest.c xmllint.c

	epunt_cxx
}

src_compile() {
	# USE zlib support breaks gnome2
	# (libgnomeprint for instance fails to compile with
	# fresh install, and existing) - <azarah@gentoo.org> (22 Dec 2002).

	# The meaning of the 'debug' USE flag does not apply to the --with-debug
	# switch (enabling the libxml2 debug module). See bug #100898.

	# --with-mem-debug causes unusual segmentation faults (bug #105120).

	local myconf="--with-zlib=${EPREFIX}/usr \
		$(use_with debug run-debug)  \
		$(use_with python)           \
		$(use_with readline)         \
		$(use_with readline history) \
		$(use_enable ipv6)"

	# Please do not remove, as else we get references to PORTAGE_TMPDIR
	# in /usr/lib/python?.?/site-packages/libxml2mod.la among things.
	elibtoolize

	# filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	econf $myconf || die "Configuration failed"

	# Patching the Makefiles to respect get_libdir
	# Fixes BUG #86766, please keep this.
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/26
	for x in $(find "${S}" -name "Makefile") ; do
		sed \
			-e "s|^\(PYTHON_SITE_PACKAGES\ =\ ${EPREFIX}\/usr\/\).*\(\/python.*\)|\1$(get_libdir)\2|g" \
			-i ${x} \
			|| die "sed failed"
	done

	emake || die "Compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog Copyright NEWS README* TODO*

	if ! use doc; then
		rm -rf "${ED}"/usr/share/gtk-doc
		rm -rf "${ED}"/usr/share/doc/${P}/html
	fi

	if ! use examples; then
		rm -rf "${ED}/usr/share/doc/${P}/examples"
		rm -rf "${ED}/usr/share/doc/${PN}-python-${PV}/examples"
	fi
}

pkg_postinst() {
	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [[ "${EROOT}" != "/" ]]
	then
		elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
		# need an XML catalog, so no-one writes to a non-existent one
		CATALOG="${EROOT}etc/xml/catalog"

		# we dont want to clobber an existing catalog though,
		# only ensure that one is there
		# <obz@gentoo.org>
		if [ ! -e ${CATALOG} ]; then
			[ -d "${EROOT}etc/xml" ] || mkdir -p "${EROOT}etc/xml"
			"${EPREFIX}"/usr/bin/xmlcatalog --create > ${CATALOG}
			einfo "Created XML catalog in ${CATALOG}"
		fi
	fi
}
