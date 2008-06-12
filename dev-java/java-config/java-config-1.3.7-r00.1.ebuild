# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-1.3.7.ebuild,v 1.9 2007/03/09 14:01:43 betelgeuse Exp $

EAPI="prefix"

inherit base distutils eutils

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="virtual/python
	dev-java/java-config-wrapper"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-prefix.patch"
	eprefixify \
		java-config \
		java_config/jc_envgen.py \
		java_config/jc_options.py \
		java_config/jc_util.py
}

src_install() {
	distutils_src_install
	newbin java-config java-config-1
	doman java-config.1

	doenvd 30java-finalclasspath
}

pkg_postinst() {
	elog "The way Java is handled on Gentoo has been recently updated."
	elog "If you have not done so already, you should follow the"
	elog "instructions available at:"
	elog "\thttp://www.gentoo.org/proj/en/java/java-upgrade.xml"
	elog
	elog "While we are moving towards the new Java system, we only allow"
	elog "1.3 or 1.4 JDKs to be used with java-config-1 to ensure"
	elog "backwards compatibility with the old system."
	elog "For more details about this, please see:"
	elog "\thttp://www.gentoo.org/proj/en/java/why-we-need-java-14.xml"
}
