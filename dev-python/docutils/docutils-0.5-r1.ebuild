# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/docutils/docutils-0.5-r1.ebuild,v 1.2 2009/09/20 19:01:24 ulm Exp $

EAPI="2"

NEED_PYTHON="2.4"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils multilib

DESCRIPTION="Set of python tools for processing plaintext docs into HTML, XML, etc..."
HOMEPAGE="http://docutils.sourceforge.net/"
SRC_URI="mirror://sourceforge/docutils/${P}.tar.gz
	glep? ( mirror://gentoo/glep-0.4-r1.tbz2 )"

LICENSE="public-domain PYTHON BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="glep emacs"

DEPEND="dev-python/setuptools"
RDEPEND=""
# Emacs support is in PDEPEND to avoid a dependency cycle (bug #183242)
PDEPEND="emacs? ( || ( >=app-emacs/rst-0.4 >=virtual/emacs-23 ) )"

RESTRICT_PYTHON_ABIS="3*"

EMP="${PN}-0.3.7"

GLEP_SRC="${WORKDIR}/glep-0.4-r1"

src_prepare() {
	epatch "${FILESDIR}/${P}-test_node_class_names-python-2.6.patch"

	# simplified algorithm to select installing optparse and textwrap
	epatch "${FILESDIR}/${EMP}-extramodules.patch"

	sed -i \
		-e 's/from distutils.core/from setuptools/' \
		setup.py || die "sed failed"
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
	cd "${S}/test"

	testing() {
		PYTHONPATH="../build-${PYTHON_ABI}/lib" ./alltests.py
	}
	python_execute_function testing
}

src_install() {
	DOCS="*.txt"
	distutils_src_install

	# Tools
	cd "${S}"/tools
	for tool in *.py; do
		dobin ${tool}
	done

	# Docs
	cd "${S}"
	dohtml -r docs tools
	# Manually install the stylesheet file
	insinto /usr/share/doc/${PF}/html
	doins docutils/writers/html4css1/html4css1.css
	for doc in $(find docs tools -name '*.txt'); do
		install_txt_doc $doc
	done

	# installing Gentoo GLEP tools. Uses versioned GLEP distribution
	if use glep; then
		dobin ${GLEP_SRC}/glep.py || die "newbin failed"

		installation_of_glep_tools() {
			local sitedir=$(python_get_sitedir)
			insinto ${sitedir#${EPREFIX}}/docutils/readers
			newins ${GLEP_SRC}/glepread.py glep.py || die "newins reader failed"
			insinto ${sitedir#${EPREFIX}}/docutils/transforms
			newins ${GLEP_SRC}/glepstrans.py gleps.py || die "newins transform failed"
			insinto ${sitedir#${EPREFIX}}/docutils/writers
			doins -r ${GLEP_SRC}/glep_html || die "doins writer failed"
		}
		python_execute_function --action-message 'Installation of GLEP tools with Python ${PYTHON_ABI}...' installation_of_glep_tools
	fi
}

pkg_postinst() {
	python_mod_optimize docutils roman.py
}

pkg_postrm() {
	python_mod_cleanup
}
