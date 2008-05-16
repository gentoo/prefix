# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-util/confix/confix-2.1.0.ebuild,v 1.2 2008/05/13 16:13:08 mr_bones_ Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="Confix: A Build Tool on Top of GNU Automake"
HOMEPAGE="http://confix.sourceforge.net"
SRC_URI="mirror://sourceforge/confix/Confix-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~x86-interix ~x86-linux"

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}
	sys-devel/automake
	sys-devel/libtool
	sys-devel/autoconf-archive
	dev-util/confix-wrapper
"

S="${WORKDIR}/Confix-${PV}"
PYTHON_MODNAME="libconfix tests"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# find jni-include dirs on hpux.
	epatch "${FILESDIR}"/${PV}/jni-hpux.patch
	# hack to ignore duplicate files in rescan
	epatch "${FILESDIR}"/${PV}/CALL_RESCAN_HACK.patch
	# add .exe extension to TESTS
	epatch "${FILESDIR}"/${PV}/exeext.patch
	# use external autoconf archive
	epatch "${FILESDIR}"/${PV}/ext-ac-archive.patch

	# need to store repos in exact versioned share/confix-PV/repo
	sed -i -e "s,'confix2','confix-${PV}'," \
		libconfix/core/automake/repo_automake.py \
	|| die "cannot adjust repo dir"

	# adjust version-printing to have same version as share/confix-PV/repo,
	# to ease revdep-rebuild-alike scripts for rebuilding confix-packages.
	sed -i -e "/^CONFIX_VERSION[ 	]*=/s,.*,CONFIX_VERSION = '${PV}'," \
		libconfix/core/utils/const.py \
	|| die "cannot adjust confix version"
}
