# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.0.33-r1.ebuild,v 1.9 2007/11/27 14:36:21 betelgeuse Exp $

EAPI="prefix"

inherit distutils eutils

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}
	app-admin/eselect
	>=dev-java/java-config-wrapper-0.13"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PF}.patch"
	epatch "${FILESDIR}/${P}-prefix.patch"
	eprefixify \
		config/20java-config setup.py \
		src/{depend-java-query,gjl,java-config-2,launcher.bash,run-java-tool} \
		src/eselect/java-{nsplugin,vm}.eselect \
		src/profile.d/java-config-2.{,c}sh \
		src/java_config/{EnvironmentManager.py,VM.py,VersionManager.py}
}

src_install() {
	distutils_src_install

	insinto /usr/share/java-config-2/config/
	# TODO: add config files for ppc-macos, x86-macos and remove ${/-macos} hack
	newins config/jdk-defaults-${ARCH/-macos}.conf jdk-defaults.conf || die "arch config not found"
}

pkg_postrm() {
	python_mod_cleanup /usr/share/java-config-2/pym/java_config
}

pkg_postinst() {
	python_mod_optimize /usr/share/java-config-2/pym/java_config

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
