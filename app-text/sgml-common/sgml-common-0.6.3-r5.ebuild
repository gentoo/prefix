# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/sgml-common/sgml-common-0.6.3-r5.ebuild,v 1.10 2006/11/14 10:22:13 leonardop Exp $

EAPI="prefix"

WANT_AUTOCONF="2.1"
WANT_AUTOMAKE="1.5"

inherit autotools eutils

DESCRIPTION="Base ISO character entities and utilities for SGML"
HOMEPAGE="http://www.iso.ch/cate/3524030.html"
SRC_URI="mirror://kde/devel/docbook/SOURCES/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack "${A}"

	# We use a hacked version of install-catalog that supports the ROOT
	# variable, and puts quotes around the CATALOG files.
	cp "${FILESDIR}/${P}-install-catalog.in" "${S}/bin/install-catalog.in"
	cd "${S}"
	eprefixify bin/install-catalog.in

	epatch "${FILESDIR}"/${P}-configure.in.patch

	eautoreconf
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}

pkg_postinst() {
	local installer="${EROOT}usr/bin/install-catalog"
	if [ ! -x "${installer}" ]; then
		eerror "install-catalog not found! Something went wrong!"
		die
	fi

	einfo "Installing Catalogs..."
	$installer --add \
		${EPREFIX}/etc/sgml/sgml-ent.cat \
		${EPREFIX}/usr/share/sgml/sgml-iso-entities-8879.1986/catalog
	$installer --add \
		${EPREFIX}/etc/sgml/sgml-docbook.cat \
		${EPREFIX}/etc/sgml/sgml-ent.cat

	local file
	for file in `find ${EROOT}etc/sgml/ -name "*.cat"` ${EROOT}etc/sgml/catalog
	do
		einfo "Fixing ${file}"
		awk '/"$/ { print $1 " " $2 }
			! /"$/ { print $1 " \"" $2 "\"" }' ${file} > ${file}.new
		mv ${file}.new ${file}
	done
}

pkg_prerm() {
	cp ${EROOT}usr/bin/install-catalog ${T}
}

pkg_postrm() {
	if [ ! -x  "${T}/install-catalog" ]; then
		return
	fi

	einfo "Removing Catalogs..."
	if [ -e "${EROOT}etc/sgml/sgml-ent.cat" ]; then
		${T}/install-catalog --remove \
			/etc/sgml/sgml-ent.cat \
			/usr/share/sgml/sgml-iso-entities-8879.1986/catalog
	fi

	if [ -e "${EROOT}etc/sgml/sgml-docbook.cat" ]; then
		${T}/install-catalog --remove \
			/etc/sgml/sgml-docbook.cat \
			/etc/sgml/sgml-ent.cat
	fi
}
