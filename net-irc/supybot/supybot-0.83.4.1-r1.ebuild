# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/supybot/supybot-0.83.4.1-r1.ebuild,v 1.1 2009/09/21 00:07:34 neurogeek Exp $

EAPI="2"
NEED_PYTHON=2.4

inherit distutils

MY_P=${P/supybot/Supybot}
MY_P=${MY_P/_rc/rc}

DESCRIPTION="Python based extensible IRC infobot and channel bot"
HOMEPAGE="http://supybot.sf.net/"
SRC_URI="mirror://sourceforge/supybot/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE="sqlite twisted"

DEPEND="twisted? ( >=dev-python/twisted-8.1.0[crypt]
				   >=dev-python/twisted-names-8.1.0 )
	sqlite? ( <dev-python/pysqlite-1.1 )
	!<net-irc/supybot-plugins-20060723-r1"

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
	use twisted && \
		elog "If you want to use Twisted as your supybot.driver, add it to your"
		elog "config file: supybot.drivers.module = Twisted."
		elog "You will need this for SSL connections"
	use twisted || \
		elog "To allow supybot to use Twisted as driver, re-emerge with"
		elog "USE=\"twisted\" flag. You will need this for SSL Connections"
}
