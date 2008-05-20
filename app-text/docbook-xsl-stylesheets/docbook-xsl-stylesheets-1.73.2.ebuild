# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-xsl-stylesheets/docbook-xsl-stylesheets-1.73.2.ebuild,v 1.8 2008/02/29 10:14:28 coldwind Exp $

EAPI="prefix"

DESCRIPTION="XSL Stylesheets for Docbook"
HOMEPAGE="http://wiki.docbook.org/topic/DocBookXslStylesheets"
SRC_URI="mirror://sourceforge/docbook/docbook-xsl-${PV}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-libs/libxml2
	>=app-text/build-docbook-catalog-1.1"

S=${WORKDIR}/docbook-xsl-${PV}

src_install() {
	# Create the installation directory
	DEST="/usr/share/sgml/docbook/xsl-stylesheets"
	insinto ${DEST}

	local i
	for sheet in $(find . -maxdepth 1 -mindepth 1 -type d); do
		i=$(basename $sheet)
		cd "${S}"/${i}
		for doc in ChangeLog README; do
			if [ -e "$doc" ]; then
				mv ${doc} ${doc}.${i}
				dodoc ${doc}.${i}
				rm ${doc}.${i}
			fi
		done

		doins -r "${S}"/${i}
	done

	# Install misc. docs
	# The changelog is now zipped, and copied as the RELEASE-NOTES, so we
	# don't need to install it
	cd "${S}"
	dodoc AUTHORS BUGS NEWS README RELEASE-NOTES.txt TODO
	doins VERSION
}

pkg_postinst() {
	build-docbook-catalog
}

pkg_postrm() {
	build-docbook-catalog
}
