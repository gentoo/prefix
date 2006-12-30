# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/supybot/supybot-0.83.2.ebuild,v 1.4 2006/09/25 21:09:35 the_paya Exp $

EAPI="prefix"

inherit distutils eutils

MY_P=${P/supybot/Supybot}
MY_P=${MY_P/_rc/rc}

DESCRIPTION="Python based extensible IRC infobot and channel bot"
HOMEPAGE="http://supybot.sf.net/"
SRC_URI="mirror://sourceforge/supybot/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="sqlite"

DEPEND=">=dev-lang/python-2.3
	>=dev-python/twisted-1.2.0
	sqlite? ( <dev-python/pysqlite-1.1 )"

S=${WORKDIR}/${MY_P}

PYTHON_MODNAME="supybot"
DOCS="ACKS BUGS DEVS README RELNOTES TODO"

src_install() {
	distutils_src_install
	doman docs/man/*
	dodoc docs/*
}

pkg_postinst() {
	einfo "Use supybot-wizard to create a configuration file"
	use sqlite || \
		einfo "Some plugins may require emerge with USE=\"sqlite\" to work."
}
