# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/buildbot/buildbot-0.8.0.ebuild,v 1.7 2010/07/24 14:52:04 maekke Exp $

EAPI="3"
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"
DISTUTILS_SRC_TEST="trial"
DISTUTILS_DISABLE_TEST_DEPENDENCY="1"

inherit distutils eutils

MY_PV="${PV/_p/p}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="A Python system to automate the compile/test cycle to validate code changes"
HOMEPAGE="http://buildbot.net/ http://pypi.python.org/pypi/buildbot"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris"
IUSE="doc irc mail manhole test"

# sqlite3 module of Python 2.5 is not supported.
RDEPEND="dev-python/jinja
	|| ( dev-python/pysqlite:2 >=dev-lang/python-2.6[sqlite] )
	>=dev-python/twisted-2.0.1
	dev-python/twisted-web
	dev-python/twisted-mail
	irc? ( dev-python/twisted-words )
	mail? ( dev-python/twisted-mail )
	manhole? ( dev-python/twisted-conch )"
DEPEND="${DEPEND}
	doc? ( dev-python/epydoc )
	test? ( dev-python/twisted-mail
			dev-python/twisted-web
			dev-python/twisted-words )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewuser buildbot
	python_pkg_setup
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH="." "$(PYTHON -f)" docs/epyrun -o docs/reference || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install
	doinfo docs/buildbot.info
	dohtml -r docs/images

	insinto /usr/share/doc/${PF}
	doins -r contrib
	doins -r docs/examples

	if use doc; then
		doins -r docs/reference || die "doins failed"
	fi

	newconfd "${FILESDIR}/buildslave.confd" buildslave || die "newconfd failed"
	newinitd "${FILESDIR}/buildbot.initd-r1" buildslave || die "newinitd failed"
	newconfd "${FILESDIR}/buildmaster.confd" buildmaster || die "newconfd failed"
	newinitd "${FILESDIR}/buildbot.initd-r1" buildmaster || die "newinitd failed"

	# Make it print the right names when you start/stop the script.
	sed -e "s/@buildbot@/buildslave/" -i "${ED}etc/init.d/buildslave" || die "sed buildslave failed"
	sed -e "s/@buildbot@/buildmaster/" -i "${ED}etc/init.d/buildmaster" || die "sed buildmaster failed"
}

pkg_postinst() {
	distutils_pkg_postinst

	elog 'The "buildbot" user and the "buildmaster" and "buildslave" init'
	elog "scripts were added to support starting buildbot through gentoo's"
	elog "init system.  To use this set up your build master or build slave"
	elog "following the buildbot documentation, make sure the resulting"
	elog 'directories are owned by the "buildbot" user and point'
	elog "${EROOT}etc/conf.d/buildmaster or ${EROOT}etc/conf.d/buildslave"
	elog "at the right location.  The scripts can run as a different user"
	elog "if desired.  If you need to run more than one master or slave"
	elog "just copy the scripts."
	elog ""
	elog "Upstream recommends the following when upgrading:"
	elog "Each time you install a new version of Buildbot, you should run the new"
	elog "'buildbot upgrade-master' command on each of your pre-existing buildmasters."
	elog "This will add files and fix (or at least detect) incompatibilities between"
	elog "your old config and the new code."
}
