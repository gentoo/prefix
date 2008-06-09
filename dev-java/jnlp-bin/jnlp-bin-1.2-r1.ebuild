# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jnlp-bin/jnlp-bin-1.2-r1.ebuild,v 1.5 2008/06/07 10:53:43 serkan Exp $

EAPI="prefix"

inherit java-pkg-2

DESCRIPTION="Java Network Launching Protocol (JNLP)"

HOMEPAGE="http://java.sun.com/products/javawebstart/download-jnlp.html"
SRC_URI="javaws-1_2-dev.zip"
LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.3"
RESTRICT="fetch"

S=${WORKDIR}

DOWNLOAD_URL="https://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_Developer-Site/en_US/-/USD/ViewProductDetail-Start?ProductRef=7026-jaws_dev_pack-1.2-oth-JPR@CDS-CDS_Developer"

pkg_nofetch() {
	einfo "Please download ${A} and place it in ${DISTDIR}"
	einfo "${DOWNLOAD_URL}"
}

src_install() {
	java-pkg_dojar *.jar
	java-pkg_dohtml -r .
}
