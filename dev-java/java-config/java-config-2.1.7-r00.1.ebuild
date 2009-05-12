# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.1.7.ebuild,v 1.8 2009/03/18 15:01:39 ranger Exp $

inherit fdo-mime gnome2-utils distutils eutils prefix

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}
	>=dev-java/java-config-wrapper-0.15"

PYTHON_MODNAME="java_config_2"

src_unpack() {
	distutils_src_unpack
	epatch "${FILESDIR}"/${P}-prefix.patch

	eprefixify \
		config/20java-config setup.py \
		src/{depend-java-query,gjl,java-config-2,launcher.bash,run-java-tool} \
		src/eselect/java-{nsplugin,vm}.eselect \
		src/profile.d/java-config-2.{,c}sh \
		src/java_config_2/{EnvironmentManager.py,VM.py,VersionManager.py}
}

src_install() {
	distutils_src_install

	local a=${ARCH}
	case $a in
		x86-freebsd)  a=x86-fbsd;; # as long as we don't push patch upstream
		x64-freebsd)  a=x86-fbsd;; # as long as it isn't upstream
		sparc64-solaris) a=sparc-solaris;; # as long as it isn't upstream
		x64-solaris)  a=x86-solaris;; # as long as it isn't upstream
		ppc*-aix)     a=${a%-aix};; # as long as ppc*-linux defaults to ibm-jdk-bin
		*-linux)      a=${a%-linux};;
	esac

	insinto /usr/share/java-config-2/config/
	newins config/jdk-defaults-${a}.conf jdk-defaults.conf || die "arch config not found"
}

pkg_postrm() {
	distutils_python_version
	distutils_pkg_postrm
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
