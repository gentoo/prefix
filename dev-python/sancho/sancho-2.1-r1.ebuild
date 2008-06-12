# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/sancho/sancho-2.1-r1.ebuild,v 1.6 2007/11/13 19:34:31 jer Exp $

EAPI="prefix"

inherit distutils

MY_P=${P/s/S}
DESCRIPTION="Sancho is a unit testing framework"
HOMEPAGE="http://www.mems-exchange.org/software/sancho/"
SRC_URI="http://www.mems-exchange.org/software/files/${PN}/${MY_P}.tar.gz"

LICENSE="CNRI"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=">=dev-lang/python-2.3"

S=${WORKDIR}/${MY_P}

src_install() {
	DOCS="CHANGES.txt"
	distutils_src_install
}

src_test() {
	einfo "Setting up test env."
	mkdir "${T}/tests"
	"${python}" setup.py install --home="${T}/tests" "$@" \
		|| die "Failed to install tests"
	pushd "${T}/tests"
	einfo "Running"
	failcount=0
	for tst in ${S}/test/*.py ; do
		b="$(basename ${tst})"
		o=${T}/tests/output-${b}
		ebegin "Testing ${b}"
		PYTHONPATH=lib/python "${python}" ${tst} >>${o}
		egrep -qv "^.*/${b}: .*:\$" ${o}
		rcv=$?
		eend $rc
		if [ $rcv -eq 0 ]; then
			let failcount=${failcount}+1
			eerror "Failure output for ${b}"
			cat ${o}
		fi
	done;
	[ $failcount -gt 0 ] && die "${failcount} tests failed"
	einfo "Cleaning up test env."
	popd
	#rm -rf "${T}/tests"
}
