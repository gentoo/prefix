# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/supybot/supybot-0.83.3.ebuild,v 1.1 2007/12/04 09:24:25 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.3
inherit distutils

MY_P=${P/supybot/Supybot}
MY_P=${MY_P/_rc/rc}

DESCRIPTION="Python based extensible IRC infobot and channel bot"
HOMEPAGE="http://supybot.sf.net/"
SRC_URI="mirror://sourceforge/supybot/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86"
IUSE="sqlite"

DEPEND=">=dev-python/twisted-1.2.0
	sqlite? ( <dev-python/pysqlite-1.1 )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

DOCS="ACKS RELNOTES docs/*"

src_install() {
	distutils_src_install
	doman docs/man/*
}

pkg_postinst() {
	distutils_pkg_postinst
	elog "Use supybot-wizard to create a configuration file"
	use sqlite || \
		elog "Some plugins may require emerge with USE=\"sqlite\" to work."
}
