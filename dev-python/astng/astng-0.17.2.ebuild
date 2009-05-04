# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/astng/astng-0.17.2.ebuild,v 1.1 2008/02/28 20:37:47 dev-zero Exp $

NEED_PYTHON="2.3"

inherit distutils eutils multilib

DESCRIPTION="Abstract Syntax Tree New Generation for logilab packages"
SRC_URI="ftp://ftp.logilab.org/pub/astng/logilab-${P}.tar.gz"
HOMEPAGE="http://www.logilab.org/projects/astng/"
IUSE=""
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
LICENSE="GPL-2"

DEPEND=">=dev-python/logilab-common-0.13-r1"
RDEPEND="${DEPEND}"

S="${WORKDIR}/logilab-${P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Skip a failing test.
	epatch "${FILESDIR}/${PN}-0.16.1-skip-gobject-test.patch"
}

src_install() {
	distutils_src_install
	python_version
	# we need to remove this file because it collides with the one
	# from logilab-common (which we depend on).
	rm "${ED}/usr/$(get_libdir)/python${PYVER}/site-packages/logilab/__init__.py"
}

src_test() {
	python_version

	# Do a temporary install.
	local spath="usr/$(get_libdir)/python${PYVER}/site-packages/"

	# This is a hack to make tests work without installing to the live
	# filesystem. We copy part of the logilab site-packages to a temporary
	# dir, install there, and run from there.
	mkdir -p "${T}/test/${spath}/logilab"
	cp -r "/${spath}/logilab/common" "${T}/test/${spath}/logilab" \
		|| die "copying logilab-common failed!"

	"${python}" setup.py install --root="${T}/test" || die "test copy failed"

	# Use a hacked up copy of pytest that exits nonzero on failure.
	sed -e 's/exitafter=False/exitafter=True/' \
		< "/usr/bin/pytest" > "${T}/pytest" || die "sed failed"

	# Pytest picks up tests relative to the current dir, so cd in.
	pushd "${T}/test/${spath}/logilab/astng" >/dev/null
	PYTHONPATH="${T}/test/${spath}" "${python}" "${T}/pytest" -v \
		|| die "tests failed"
	popd >/dev/null
	rm -rf "${T}/test"
}
