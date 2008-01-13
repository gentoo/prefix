# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/argouml/argouml-0.19.6.ebuild,v 1.4 2007/01/19 15:08:39 masterdriverz Exp $

EAPI="prefix"

inherit java-pkg

DESCRIPTION="modelling tool that helps you do your design using UML"
HOMEPAGE="http://argouml.tigris.org"
SRC_URI="http://argouml-downloads.tigris.org/nonav/${P}/ArgoUML-${PV}.tar.gz
	http://argouml-downloads.tigris.org/nonav/${P}/ArgoUML-${PV}-modules.tar.gz
	doc? ( http://argouml-downloads.tigris.org/nonav/${P}/argomanual-${PV}.pdf
	http://argouml-downloads.tigris.org/nonav/${P}/quickguide-${PV}.pdf
	http://argouml-downloads.tigris.org/nonav/${P}/cookbook-${PV}.pdf )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

RDEPEND=">=virtual/jre-1.3"

S=${WORKDIR}

src_compile() { :; }

src_install() {
	dodir /opt/${PN}/lib/
	cp -pPR . ${ED}/opt/${PN}/lib/ || die
	chmod -R 755 ${ED}/opt/${PN}
	touch ${ED}/opt/${PN}/lib/argouml.log
	chmod a+w ${ED}/opt/${PN}/lib/argouml.log

	echo "#!${EPREFIX}/bin/sh" > ${PN}
	echo "cd \"${EPREFIX}\"/opt/${PN}/lib" >> ${PN}
	echo 'java -jar argouml.jar' >> ${PN}
	into /opt
	dobin ${PN}

	dodoc README.txt

	if use doc ; then
		insinto /usr/share/doc/${P}
		doins ${DISTDIR}/argomanual-${PV}.pdf
		doins ${DISTDIR}/quickguide-${PV}.pdf
		doins ${DISTDIR}/cookbook-${PV}.pdf
	fi
}
