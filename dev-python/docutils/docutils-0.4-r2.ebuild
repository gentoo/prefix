# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/docutils/docutils-0.4-r2.ebuild,v 1.12 2008/02/04 15:28:03 hawking Exp $

EAPI="prefix"

inherit distutils eutils multilib

DESCRIPTION="Set of python tools for processing plaintext docs into HTML, XML, etc..."
HOMEPAGE="http://docutils.sourceforge.net/"
SRC_URI="mirror://sourceforge/docutils/${P}.tar.gz
	glep? ( mirror://gentoo/glep-${PV}-r1.tbz2 )"

LICENSE="public-domain PYTHON BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="glep emacs"

DEPEND=">=dev-lang/python-2.3"
# Emacs support is in PDEPEND to avoid a dependency cycle (bug #183242)
PDEPEND="emacs? ( >=app-emacs/rst-0.4 )"

EMP=${PN}-0.3.7

GLEP_SRC=${WORKDIR}/glep-${PV}-r1

src_unpack() {
	unpack ${A}
	# simplified algorithm to select installing optparse and textwrap
	cd "${S}"
	epatch "${FILESDIR}"/${EMP}-extramodules.patch
	# Fix for Python 2.5 test (bug# 172557)
	epatch "${FILESDIR}"/${P}-python-2.5-fix.patch
}

src_compile() {
	distutils_src_compile

	# Generate html docs from reStructured text sources.

	# make roman.py available for the doc building process
	ln -s extras/roman.py

	pushd tools

	# Place html4css1.css in base directory. This makes sure the
	# generated reference to it is correct.
	cp ../docutils/writers/html4css1/html4css1.css ..

	PYTHONPATH=.. ${python} ./buildhtml.py --stylesheet-path=../html4css1.css --traceback .. \
		|| die "buildhtml"

	popd

	# clean up after the doc building
	rm roman.py html4css1.css
}

install_txt_doc() {
	local doc=${1}
	local dir="txt/$(dirname ${doc})"
	docinto ${dir}
	dodoc ${doc}
}

src_test() {
	cd "${S}"/test
	PYTHONPATH="${S}" ./alltests.py || die "alltests.py failed"
}

src_install() {
	DOCS="*.txt"
	distutils_src_install
	# Tools
	cd "${S}"/tools
	for tool in *.py
	do
		dobin ${tool}
	done
	# Docs
	cd "${S}"
	dohtml -r docs tools
	# manually install the stylesheet file
	insinto /usr/share/doc/${PF}/html
	doins docutils/writers/html4css1/html4css1.css
	for doc in $(find docs tools -name '*.txt')
	do
		install_txt_doc $doc
	done

	# installing Gentoo GLEP tools. Uses versioned GLEP distribution
	if use glep
	then
		distutils_python_version
		dobin ${GLEP_SRC}/glep.py || die "newbin failed"
		insinto /usr/$(get_libdir)/python${PYVER}/site-packages/docutils/readers
		newins ${GLEP_SRC}/glepread.py glep.py || die "newins reader failed"
		insinto /usr/$(get_libdir)/python${PYVER}/site-packages/docutils/transforms
		newins ${GLEP_SRC}/glepstrans.py gleps.py || "newins transform failed"
		insinto /usr/$(get_libdir)/python${PYVER}/site-packages/docutils/writers
		doins -r ${GLEP_SRC}/glep_html || die "doins writer failed"
	fi
}
