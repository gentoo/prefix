# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/itext/itext-2.1.3-r1.ebuild,v 1.1 2008/07/15 06:30:11 wltjr Exp $

EAPI=1
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java library that generate documents in the Portable Document Format (PDF) and/or HTML."
HOMEPAGE="http://www.lowagie.com/iText/"
DISTFILE="${PN/it/iT}-src-${PV}.tar.gz"
ASIANJAR="iTextAsian.jar"
ASIANCMAPSJAR="iTextAsianCmaps.jar"
SRC_URI="mirror://sourceforge/itext/${DISTFILE}
	cjk? ( mirror://sourceforge/itext/${ASIANJAR}
		mirror://sourceforge/itext/${ASIANCMAPSJAR} )"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="cjk rtf rups"

BCV="1.38"

COMMON_DEPEND=">=dev-java/bcmail-${BCV}
	>=dev-java/bcprov-${BCV}
	rups? ( dev-java/dom4j:1 )"
DEPEND="|| ( =virtual/jdk-1.6* =virtual/jdk-1.5* !doc? ( !rups? ( =virtual/jdk-1.4* ) ) )
	 ${COMMON_DEPEND}"
RDEPEND="!doc? ( !rups? ( >=virtual/jre-1.4 ) )
	doc? ( !rups? ( >=virtual/jre-1.5 ) )
	!doc? ( rups? ( >=virtual/jre-1.5 ) )
	doc? ( rups? ( >=virtual/jre-1.5 ) )
	${COMMON_DEPEND}"

S="${WORKDIR}/src"

src_unpack() {
	cd "${WORKDIR}"
	unpack ${DISTFILE}
	cd "${S}"

	if use cjk; then
		cp "${DISTDIR}/${ASIANJAR}" "${DISTDIR}/${ASIANCMAPSJAR}" "${WORKDIR}" \
			|| die "Could not copy asian fonts"
	fi

	sed -i -e 's|<link href="http://java.sun.com/j2se/1.4/docs/api/" />||' \
		-e 's|<link href="http://www.bouncycastle.org/docs/docs1.4/" />||' \
		"${S}/ant/site.xml"

	java-ant_bsfix_files ant/*.xml || die "failed to rewrite build xml files"

	mkdir -p "${WORKDIR}/lib" || die "Failed to create ${WORKDIR}/lib"
	cd "${WORKDIR}/lib" || die "Could not cd ${WORKDIR}/lib"
	java-pkg_jar-from bcmail bcmail.jar "bcmail-jdk14-${BCV/./}.jar"
	java-pkg_jar-from bcprov bcprov.jar "bcprov-jdk14-${BCV/./}.jar"
	use rups && java-pkg_jar-from dom4j-1 dom4j.jar "dom4j-1.6.1.jar"
}

src_compile() {
	eant jar $(use_doc javadoc) \
		$(use rtf && echo "jar.rtf") \
		$(use rups && echo "jar.rups")
}

src_install() {
	cd "${WORKDIR}"
	java-pkg_dojar lib/iText.jar
	use rtf && java-pkg_dojar lib/iText-rtf.jar
	use rups && java-pkg_dojar lib/iText-rups.jar
	if use cjk; then
		java-pkg_dojar "${ASIANJAR}"
		java-pkg_dojar "${ASIANCMAPSJAR}"
	fi

	use source && java-pkg_dosrc src/core/com src/rups/com
	use doc && java-pkg_dojavadoc build/docs
}
