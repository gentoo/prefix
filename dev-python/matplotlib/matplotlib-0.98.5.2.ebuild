# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/matplotlib/matplotlib-0.98.5.2.ebuild,v 1.5 2009/03/30 15:32:32 loki_val Exp $

WX_GTK_VER=2.8
EAPI=2
inherit eutils distutils wxwidgets

PDOC="users_guide_${PV}"

DESCRIPTION="Pure python plotting library with matlab like syntax"
HOMEPAGE="http://matplotlib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	doc? ( http://matplotlib.sourceforge.net/Matplotlib.pdf -> ${PDOC}.pdf )"

IUSE="cairo doc excel examples fltk gtk latex qt3 qt4 tk wxwindows"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="PYTHON BSD stix bakoma"

DEPEND=">=dev-python/numpy-1.1
	>=media-libs/freetype-2
	media-libs/libpng
	dev-python/pytz
	dev-python/python-dateutil
	gtk? ( dev-python/pygtk )
	tk? ( dev-lang/python[tk] )
	wxwindows? ( dev-python/wxpython:2.8 )"

RDEPEND="${DEPEND}
	latex? ( virtual/latex-base
		virtual/ghostscript
		app-text/dvipng
		virtual/poppler-utils )
	cairo? ( dev-python/pycairo )
	excel? ( dev-python/xlwt )
	fltk?  ( dev-python/pyfltk )
	qt3?   ( dev-python/PyQt )
	qt4?   ( dev-python/PyQt4 )"

DOCS="INTERACTIVE"

use_setup() {
	local uword="${2}"
	[ -z "${2}" ] && uword="${1}"
	if use ${1}; then
		echo "${uword} = True"
		echo "${uword}agg = True"
	else
		echo "${uword} = False"
		echo "${uword}agg = False"
	fi
}

src_prepare() {
	# create setup.cfg (see setup.cfg.template for any changes)
	cat > setup.cfg <<-EOF
		[provide_packages]
		pytz = False
		dateutil = False
		configobj = False
		enthought.traits = False
		[gui_support]
		$(use_setup gtk)
		$(use_setup tk)
		$(use_setup wxwindows wx)
		$(use_setup qt3 qt)
		$(use_setup qt4)
		$(use_setup fltk)
		$(use_setup cairo)
	EOF

	# sed to avoid checks needing a X display
	sed -i \
		-e "s/check_for_gtk()/$(use gtk && echo True || echo False)/" \
		-e "s/check_for_tk()/$(use tk && echo True || echo False)/" \
		setup.py || die "sed setup.py failed"

	# respect FHS: put mpl-data in /usr/share/matplotlib
	# and config files in /etc/matplotlib
	sed -i \
		-e "/'mpl-data\/matplotlibrc',/d" \
		-e "/'mpl-data\/matplotlib.conf',/d" \
		-e "s:'lib/matplotlib/mpl-data/matplotlibrc':'matplotlibrc':" \
		-e "s:'lib/matplotlib/mpl-data/matplotlib.conf':'matplotlib.conf':" \
		setup.py \
		|| die "sed setup.py for FHS failed"

	sed -i \
		-e "s:path =  get_data_path():path = '/etc/matplotlib':" \
		-e "s:os.path.dirname(__file__):'/usr/share/${PN}':g"  \
		lib/matplotlib/{__init__,config/cutils}.py \
		|| die "sed init for FHS failed"
}

src_install() {
	distutils_src_install

	# respect FHS
	dodir /usr/share/${PN}
	mv "${ED}"/usr/*/*/site-packages/${PN}/{mpl-data,backends/Matplotlib.nib} \
		"${ED}"/usr/share/${PN} || die "failed renaming"

	insinto /etc/matplotlib
	doins matplotlibrc matplotlib.conf \
		|| die "installing config files failed"

	insinto /usr/share/doc/${PF}
	if use doc; then
		doins "${DISTDIR}"/${PDOC}.pdf || die
	fi
	if use examples; then
		doins -r examples || die
	fi
}
