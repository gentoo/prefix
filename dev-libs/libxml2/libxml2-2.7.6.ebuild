# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxml2/libxml2-2.7.6.ebuild,v 1.2 2010/03/08 22:30:16 zmedico Exp $

EAPI="2"

inherit libtool flag-o-matic eutils python autotools prefix

DESCRIPTION="Version 2 of the library to manipulate XML files"
HOMEPAGE="http://www.xmlsoft.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc examples ipv6 python readline test"

XSTS_HOME="http://www.w3.org/XML/2004/xml-schema-test-suite"
XSTS_NAME_1="xmlschema2002-01-16"
XSTS_NAME_2="xmlschema2004-01-14"
XSTS_TARBALL_1="xsts-2002-01-16.tar.gz"
XSTS_TARBALL_2="xsts-2004-01-14.tar.gz"

SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz
	test? (
		${XSTS_HOME}/${XSTS_NAME_1}/${XSTS_TARBALL_1}
		${XSTS_HOME}/${XSTS_NAME_2}/${XSTS_TARBALL_2} )"

RDEPEND="sys-libs/zlib
	python? ( <dev-lang/python-3 )
	readline? ( sys-libs/readline )"

DEPEND="${RDEPEND}
	hppa? ( >=sys-devel/binutils-2.15.92.0.2 )"

src_unpack() {
	# ${A} isn't used to avoid unpacking of test tarballs into $WORKDIR,
	# as they are needed as tarballs in ${S}/xstc instead and not unpacked
	unpack ${P}.tar.gz
	cd "${S}"

	if use test; then
		cp "${DISTDIR}/${XSTS_TARBALL_1}" \
			"${DISTDIR}/${XSTS_TARBALL_2}" \
			"${S}"/xstc/ \
			|| die "Failed to install test tarballs"
	fi

	epatch "${FILESDIR}"/${PN}-2.7.1-catalog_path.patch
	epatch "${FILESDIR}"/${PN}-2.7.2-winnt.patch
	epatch "${FILESDIR}"/${PN}-2.7.4-ld-version-script-check.patch # needs eautoreconf

	eprefixify catalog.c xmlcatalog.c runtest.c xmllint.c

	eautoreconf # required for winnt
}

src_prepare() {
	epunt_cxx
}

src_configure() {
	# USE zlib support breaks gnome2
	# (libgnomeprint for instance fails to compile with
	# fresh install, and existing) - <azarah@gentoo.org> (22 Dec 2002).

	# The meaning of the 'debug' USE flag does not apply to the --with-debug
	# switch (enabling the libxml2 debug module). See bug #100898.

	# --with-mem-debug causes unusual segmentation faults (bug #105120).

	local myconf="--with-zlib=${EPREFIX}/usr \
		--with-html-subdir=${PF}/html \
		--docdir=${EPREFIX}/usr/share/doc/${PF} \
		$(use_with debug run-debug)  \
		$(use_with python)           \
		$(use_with readline)         \
		$(use_with readline history) \
		$(use_enable ipv6)"
	# avoid needing python when we don't need it at all (like during bootstrap)
	use python && \
		myconf="${myconf} PYTHON_SITE_PACKAGES=${EPREFIX}$(python_get_sitedir)"

	# Please do not remove, as else we get references to PORTAGE_TMPDIR
	# in /usr/lib/python?.?/site-packages/libxml2mod.la among things.
	elibtoolize

	# filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	econf $myconf
}

src_install() {
	emake DESTDIR="${D}" \
		EXAMPLES_DIR="${EPREFIX}"/usr/share/doc/${PF}/examples \
		docsdir="${EPREFIX}"/usr/share/doc/${PF}/python \
		exampledir=${EPREFIX}/usr/share/doc/${PF}/python/examples \
		install || die "Installation failed"

	rm -rf "${ED}"/usr/share/doc/${P}
	dodoc AUTHORS ChangeLog Copyright NEWS README* TODO* || die "dodoc failed"

	if ! use python; then
		rm -rf "${ED}"/usr/share/doc/${PF}/python
		rm -rf "${ED}"/usr/share/doc/${PN}-python-${PV}
	fi

	if ! use doc; then
		rm -rf "${ED}"/usr/share/gtk-doc
		rm -rf "${ED}"/usr/share/doc/${PF}/html
	fi

	if ! use examples; then
		rm -rf "${ED}/usr/share/doc/${PF}/examples"
		rm -rf "${ED}/usr/share/doc/${PF}/python/examples"
	fi
}

pkg_preinst() {
	#
	# on windows, xmllint is installed by interix libxml2 in parent prefix.
	# this is the version to use. the native winnt version does not support
	# symlinks, which makes repoman fail if the portage tree is linked in
	# from another location (which is my default).
	#
	if [[ ${CHOST} == *-winnt* ]]; then
		cd "${ED}"
		rm usr/bin/xmllint
		rm usr/bin/xmlcatalog
	fi
}

pkg_postinst() {
	if use python; then
		python_need_rebuild
		python_mod_optimize $(python_get_sitedir)
	fi

	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [ "${ROOT}" != "/" ]
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

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/python*/site-packages
}
