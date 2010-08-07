# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/wxpython/wxpython-2.8.11.0.ebuild,v 1.2 2010/07/28 13:56:51 arfrever Exp $

EAPI="2"
PYTHON_DEPEND="2"
WX_GTK_VER="2.8"
SUPPORT_PYTHON_ABIS="1"

inherit alternatives eutils fdo-mime flag-o-matic multilib python wxwidgets

MY_P="${P/wxpython-/wxPython-src-}"

DESCRIPTION="A blending of the wxWindows C++ class library with Python"
HOMEPAGE="http://www.wxpython.org/"
SRC_URI="mirror://sourceforge/wxpython/${MY_P}.tar.bz2
	doc? ( mirror://sourceforge/wxpython/wxPython-docs-${PV}.tar.bz2
		   mirror://sourceforge/wxpython/wxPython-newdocs-2.8.9.2.tar.bz2 )
	examples? ( mirror://sourceforge/wxpython/wxPython-demo-${PV}.tar.bz2 )"

LICENSE="wxWinLL-3"
SLOT="2.8"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="aqua cairo doc examples opengl"

RDEPEND="
	dev-python/setuptools
	aqua? ( >=x11-libs/wxGTK-${PV}:2.8[opengl?,tiff,aqua=] )
	!aqua? ( >=x11-libs/wxGTK-${PV}:2.8[opengl?,tiff,X] )
	>=x11-libs/gtk+-2.4[aqua=]
	>=x11-libs/pango-1.2
	>=dev-libs/glib-2.0
	media-libs/libpng
	media-libs/jpeg:0
	media-libs/tiff
	cairo?	( >=dev-python/pycairo-1.8.4 )
	opengl?	( >=dev-python/pyopengl-2.0.0.44 )
	aqua? ( >=dev-lang/python-2.6[aqua?] )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

RESTRICT_PYTHON_ABIS="3.*"

S="${WORKDIR}/${MY_P}/wxPython"
DOC_S="${WORKDIR}/wxPython-${PV}"

src_prepare() {
	sed -i "s:cflags.append('-O3'):pass:" config.py || die "sed failed"

	epatch "${FILESDIR}"/${PN}-2.8.9-wxversion-scripts.patch
	# drop editra - we have it as a separate package now
	epatch "${FILESDIR}"/${PN}-2.8.11-drop-editra.patch

	if use doc; then
		cd "${DOC_S}"
		epatch "${FILESDIR}"/${PN}-${SLOT}-cache-writable.patch
	fi

	if use examples; then
		cd "${DOC_S}"
		epatch "${FILESDIR}"/${PN}-${SLOT}-wxversion-demo.patch
	fi

	python_copy_sources
}

src_configure() {
	need-wxwidgets unicode

	append-flags -fno-strict-aliasing

	use opengl \
		&& mypyconf="${mypyconf} BUILD_GLCANVAS=1" \
		|| mypyconf="${mypyconf} BUILD_GLCANVAS=0"

	mypyconf="${mypyconf} WX_CONFIG=${WX_CONFIG}"
	mypyconf="${mypyconf} UNICODE=1"

	use aqua \
		&& mypyconf="${mypyconf} WXPORT=mac" \
		|| mypyconf="${mypyconf} WXPORT=gtk2"
}

src_compile() {
	building() {
		"$(PYTHON)" setup.py ${mypyconf} build
	}
	python_execute_function -s building
}

src_install() {
	local mypyconf

	mypyconf="${mypyconf} WX_CONFIG=${WX_CONFIG}"
	use opengl \
		&& mypyconf="${mypyconf} BUILD_GLCANVAS=1" \
		|| mypyconf="${mypyconf} BUILD_GLCANVAS=0"

	mypyconf="${mypyconf} UNICODE=1"

	use aqua \
		&& mypyconf="${mypyconf} WXPORT=mac" \
		|| mypyconf="${mypyconf} WXPORT=gtk2"

	installation() {
		"$(PYTHON)" setup.py ${mypyconf} install --root="${D}" --install-purelib "${EPREFIX}"$(python_get_sitedir)
	}
	python_execute_function -s installation

	# Collision protection.
	for file in "${ED}"/usr/bin/*; do
		mv "${file}" "${file}-${SLOT}"
	done
	rename_files() {
		for file in "${ED}$(python_get_sitedir)/"wx{version.*,.pth}; do
			mv "${file}" "${file}-${SLOT}" || return 1
		done
	}
	python_execute_function -q rename_files

	dodoc "${S}"/docs/{CHANGES,PyManual,README,wxPackage,wxPythonManual}.txt

	insinto /usr/share/applications
	doins "${S}"/distrib/{Py{AlaMode,Crust,Shell},XRCed}.desktop
	insinto /usr/share/pixmaps
	newins "${S}"/wx/py/PyCrust_32.png PyCrust.png
	newins "${S}"/wx/tools/XRCed/XRCed_32.png XRCed.png

	if use doc; then
		dodir /usr/share/doc/${PF}/docs
		cp -R "${DOC_S}"/docs/* "${ED}"usr/share/doc/${PF}/docs/
		# For some reason newer API docs aren't available so use 2.8.9.2's
		cp -R "${WORKDIR}"/wxPython-2.8.9.2/docs/* "${ED}"usr/share/doc/${PF}/docs/
	fi

	if use examples; then
		dodir /usr/share/doc/${PF}/demo
		dodir /usr/share/doc/${PF}/samples
		cp -R "${DOC_S}"/demo/* "${ED}"/usr/share/doc/${PF}/demo/
		cp -R "${DOC_S}"/samples/* "${ED}"/usr/share/doc/${PF}/samples/
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update

	create_symlinks() {
		alternatives_auto_makesym "$(python_get_sitedir)/wx.pth" "$(python_get_sitedir)/wx.pth-[0-9].[0-9]"
		alternatives_auto_makesym "$(python_get_sitedir)/wxversion.py" "$(python_get_sitedir)/wxversion.py-[0-9].[0-9]"
	}
	python_execute_function -q create_symlinks

	python_mod_optimize wx-${SLOT}-gtk2-unicode wxversion.py

	echo
	elog "Gentoo uses the Multi-version method for SLOT'ing."
	elog "Developers, see this site for instructions on using"
	elog "2.6 or 2.8 with your apps:"
	elog "http://wiki.wxpython.org/index.cgi/MultiVersionInstalls"
	elog
	if use doc; then
		elog "To access the general wxWidgets documentation, run"
		elog "/usr/share/doc/${PF}/docs/viewdocs.py"
		elog
		elog "wxPython documentation is available by pointing a browser"
		elog "at /usr/share/doc/${PF}/docs/api/index.html"
		elog
	fi
	if use examples; then
		elog "The demo.py app which contains hundreds of demo modules"
		elog "with documentation and source code has been installed at"
		elog "/usr/share/doc/${PF}/demo/demo.py"
		elog
		elog "Many more example apps and modules can be found in"
		elog "/usr/share/doc/${PF}/samples/"
	fi
	echo
	ewarn "Editra is no longer packaged with wxpython in Gentoo."
	ewarn "You can find it in the tree as app-editors/editra"
	echo
}

pkg_postrm() {
	python_mod_cleanup wx-${SLOT}-gtk2-unicode wxversion.py
	fdo-mime_desktop_database_update

	create_symlinks() {
		alternatives_auto_makesym "$(python_get_sitedir)/wx.pth" "$(python_get_sitedir)/wx.pth-[0-9].[0-9]"
		alternatives_auto_makesym "$(python_get_sitedir)/wxversion.py" "$(python_get_sitedir)/wxversion.py-[0-9].[0-9]"
	}
	python_execute_function -q create_symlinks
}
