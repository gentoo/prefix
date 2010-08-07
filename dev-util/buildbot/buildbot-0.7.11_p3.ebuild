# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/buildbot/buildbot-0.7.11_p3.ebuild,v 1.10 2010/07/06 19:18:12 arfrever Exp $

EAPI="3"
PYTHON_DEPEND="2"

MY_PV="${PV/_p/p}"
MY_P="${PN}-${MY_PV}"

inherit distutils eutils

DESCRIPTION="A Python system to automate the compile/test cycle to validate code changes"
HOMEPAGE="http://buildbot.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris"
IUSE="doc irc mail manhole test"

CDEPEND=">=dev-python/twisted-2.0.1"
RDEPEND="${CDEPEND}
	mail? ( dev-python/twisted-mail )
	manhole? ( dev-python/twisted-conch )
	irc? ( dev-python/twisted-words )
	dev-python/twisted-web
	dev-python/twisted-mail"
DEPEND="${CDEPEND}
	test? ( dev-python/twisted-mail
			dev-python/twisted-web
			dev-python/twisted-words )
	doc? ( =dev-python/epydoc-2* )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewuser buildbot
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.7.5-root-skip-tests.patch"
}

src_compile() {
	distutils_src_compile
	if use doc; then
		PYTHONPATH=. "${python}" docs/epyrun -o docs/reference || \
			die "epyrun failed"
	fi
}

src_test() {
	local trialopts
	if ! has_version ">=dev-python/twisted-2.2"; then
		trialopts=-R
	fi
	PYTHONPATH=. trial ${trialopts} buildbot || die "tests failed!"
}

src_install() {
	distutils_src_install
	doinfo docs/buildbot.info
	dohtml -r docs/images

	insinto /usr/share/doc/${PF}
	doins -r contrib
	doins -r docs/examples

	use doc && doins -r docs/reference

	newconfd "${FILESDIR}/buildslave.confd" buildslave
	newinitd "${FILESDIR}/buildbot.initd-r1" buildslave
	newconfd "${FILESDIR}/buildmaster.confd" buildmaster
	newinitd "${FILESDIR}/buildbot.initd-r1" buildmaster

	# Make it print the right names when you start/stop the script.
	sed -i -e 's/@buildbot@/buildslave/' \
		"${ED}/etc/init.d/buildslave" || die "buildslave sed failed"
	sed -i -e 's/@buildbot@/buildmaster/' \
		"${ED}/etc/init.d/buildmaster" || die "buildmaster sed failed"
}

pkg_postinst() {
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
