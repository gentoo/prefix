# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.1.6.ebuild,v 1.5 2008/05/12 22:21:10 betelgeuse Exp $

EAPI="prefix"

inherit fdo-mime gnome2-utils distutils eutils

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}
	>=dev-java/java-config-wrapper-0.15"

PYTHON_MODNAME="java_config_2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.1.6-prefix.patch

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

	local a=${ARCH}
	case $a in
		x86-freebsd)  a=x86-fbsd;; # as long as we don't push patch upstream
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
