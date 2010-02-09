# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/gitosis/gitosis-0.2_p20080825.ebuild,v 1.4 2010/02/08 08:59:41 pva Exp $

inherit eutils distutils

DESCRIPTION="gitosis -- software for hosting git repositories"
HOMEPAGE="http://eagain.net/gitweb/?p=gitosis.git;a=summary"
# This is a snapshot taken from the upstream gitweb.
MY_PV="20080825-73a032520493f6b4186185d4826d12edb5614135"
MY_PN="${PN}.git"
MY_P="${MY_PN}-${MY_PV}"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""
DEPEND_GIT=">=dev-util/git-1.5.5.4"
DEPEND="${DEPEND_GIT}
		>=dev-python/setuptools-0.6_rc5"
RDEPEND="${DEPEND}
		!dev-util/gitosis-gentoo"

S=${WORKDIR}/gitosis

DOCS="example.conf gitweb.conf lighttpd-gitweb.conf TODO.rst"

pkg_setup() {
	enewgroup git
	enewuser git -1 /bin/sh /var/spool/gitosis git
}

src_install() {
	distutils_src_install
	keepdir /var/spool/gitosis
	fowners git:git /var/spool/gitosis
}

# We should handle more of this, but it requires the input of an SSH public key
# from the user, and they may want to set up more configuration first.
#pkg_config() {
#}
