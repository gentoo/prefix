# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.1.2-r1.ebuild,v 1.1 2007/10/14 07:45:00 ali_bush Exp $

EAPI="prefix"

inherit distutils eutils

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}
	>=dev-java/java-config-wrapper-0.13"

PYTHON_MODNAME="java_config_2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PF}.patch"
	epatch "${FILESDIR}"/${PN}-2.1.2-prefix.patch

	cp "${FILESDIR}"/jdk-defaults-solaris.conf \
		"${S}"/config/jdk-defaults-x86-solaris.conf
	cp "${FILESDIR}"/jdk-defaults-solaris.conf \
		"${S}"/config/jdk-defaults-sparc-solaris.conf
	cp "${FILESDIR}"/jdk-defaults-macos.conf \
		"${S}"/config/jdk-defaults-x86-macos.conf
	cp "${FILESDIR}"/jdk-defaults-solaris.conf \
		"${S}"/config/jdk-defaults-ppc-macos.conf

	eprefixify \
		config/20java-config setup.py \
		src/{depend-java-query,gjl,java-config-2,launcher.bash,run-java-tool} \
		src/eselect/java-{nsplugin,vm}.eselect \
		src/profile.d/java-config-2.{,c}sh \
		src/java_config_2/{EnvironmentManager.py,VM.py,VersionManager.py}

	# fix for newer portages
	find . -name "*.py" -print0 | xargs -0 sed -i -e 's/portage_dep/portage.dep/g'
}

src_install() {
	distutils_src_install

	insinto /usr/share/java-config-2/config/
	newins config/jdk-defaults-${ARCH}.conf jdk-defaults.conf || die "arch config not found"
}

pkg_postrm() {
	distutils_python_version
	distutils_pkg_postrm
}

pkg_postinst() {
	distutils_pkg_postinst

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
