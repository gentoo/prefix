# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/graphviz/graphviz-2.16.1.ebuild,v 1.3 2008/05/11 19:54:58 maekke Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils autotools multilib python

DESCRIPTION="Open Source Graph Visualization Software"
HOMEPAGE="http://www.graphviz.org/"
SRC_URI="http://www.graphviz.org/pub/graphviz/ARCHIVE/${P}.tar.gz"

LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="cairo doc examples gnome gtk jpeg nls perl png python ruby X tcl tk"

# Requires ksh
RESTRICT="test"

RDEPEND="
	>=dev-libs/expat-2.0.0
	>=dev-libs/glib-2.11.1
	>=media-libs/fontconfig-2.3.95
	>=media-libs/freetype-2.1.10
	>=media-libs/gd-2.0.28
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.10
	virtual/libiconv
	ruby?	( dev-lang/ruby )
	tcl?	( >=dev-lang/tcl-8.3 )
	tk?		( >=dev-lang/tk-8.3 )
	X?		( x11-libs/libX11 x11-libs/libXaw x11-libs/libXpm
			gnome?	( gnome-base/libgnomeui )
			gtk?	( >=x11-libs/gtk+-2 )
			cairo?	( >=x11-libs/pango-1.12 >=x11-libs/cairo-1.1.10 ) )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.20
	sys-devel/flex
	nls?	( >=sys-devel/gettext-0.14.5 )
	perl?	( dev-lang/swig )
	python?	( dev-lang/swig )
	ruby?	( dev-lang/swig )
	tcl?	( dev-lang/swig )"

# Dependency description / Maintainer-Info:

# Rendering is done via the following plugins (/plugins):
# - core, dot_layout, neato_layout, gd (the ones which are always compiled in, depend on zlib, gd)
# - gtk (depends on gtk-2, cairo, libX11, gtk-2 depends on cairo and libX11 as well)
# - ming ( depends on ming-3.0 which is still p.masked)
# - pango ( depends on pango and cairo, but pango depends on cairo as well)
# - xlib ( depends on libX11, Xrender AND pango, can make use of gnomeui and inotify support)
# - ming ( depends on ming-3 which is still masked, ?)

# There can be swig-generated bindings for the following languages (/tclpkg/gv):
# - c-sharp (disabled)
# - scheme (enabled via guile) ... broken on ~x86
# - io (disabled)
# - java (enabled via java) *2
# - lua (enabled via lua)
# - ocaml (enabled via ocaml)
# - perl (enabled via perl) *1
# - php (enabled via php) *2
# - python (enabled via python) *1
# - ruby (enabled via ruby) *1
# - tcl (enabled via tcl)
# *1 = The ${P}-bindings.patch takes care that those bindings are installed to the right location
# *2 = Those bindings don't build because the paths for the headers/libs aren't
#      detected correctly and/or the options passed to swig are wrong (-php instead of -php4/5)

# There are several other tools in /tclpkg:
# gdtclft, tcldot, tclhandle, tclpathplan, tclstubs ; enabled with: --with-tcl
# tkspline, tkstubs ; enabled with: --with-tk

# And the commands (/cmd):
# - dot, dotty, gvpr, lefty, lneato, tools/* :)
# Lefty needs Xaw and X to build

pkg_setup() {
	if use tcl && ! built_with_use dev-lang/swig tcl ; then
		eerror "SWIG has to be built with tcl support."
		die "Missing tcl USE-flag for dev-lang/swig"
	fi
	# bug 181147
	if use png && ! built_with_use media-libs/gd png ; then
		eerror "media-libs/gd has to be built with png support"
		die "remerge media-libs/gd with USE=\"png\""
	fi
	if use jpeg && ! built_with_use media-libs/gd jpeg ; then
		eerror "media-libs/gd has to be built with jpeg support"
		die "remerge media-libs/gd with USE=\"jpeg\""
	fi
	# bug 202781
	if ! built_with_use x11-libs/cairo svg ; then
		eerror "x11-libs/cairo has to be built with svg support"
		die "emerge x11-libs/cairo with USE=\"svg\""
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-bindings.patch
	epatch "${FILESDIR}"/${P}-gcc43-missing-includes.patch

	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's/\.so/.dylib/g' tclpkg/gv/Makefile.am

	# ToDo: Do the same thing for examples and/or
	#       write a patch for a configuration-option
	#       and send it to upstream
	if ! use doc ; then
		find . -iname Makefile.am \
			| xargs sed -i -e '/html_DATA/d' -e '/pdf_DATA/d' || die
	fi

	# This is an old version of libtool
	rm -rf libltdl
	sed -i -e '/libltdl/d' configure.ac || die

	# Update this file from our local libtool which is much newer than the
	# bundled one. This allows MAKEOPTS=-j2 to work on FreeBSD.
	cp "${EPREFIX}"/usr/share/libtool/install-sh config

	# no nls, no gettext, no iconv macro, so disable it
	use nls || { sed -i -e '/^AM_ICONV/d' configure.ac || die; }

	# Nuke the dead symlinks for the bindings
	sed -i -e '/$(pkgluadir)/d' tclpkg/gv/Makefile.am || die

	eautoreconf
}

src_compile() {
	# If we want pango, we need --with-x, otherwise
	# nothing gets built. Dependencies should be ok.
	local myconf=""
	if use X || use cairo ; then
		myconf="--with-x"
	else
		myconf="--without-x"
	fi

	econf \
		--enable-ltdl					\
		--disable-guile					\
		--disable-java					\
		--disable-io					\
		--disable-lua					\
		--disable-ocaml					\
		$(use_enable perl)				\
		--disable-php					\
		$(use_enable python)			\
		$(use_enable ruby)				\
		--disable-sharp					\
		$(use_enable tcl)				\
		$(use_enable tk)				\
		$(use_with cairo pangocairo)	\
		$(use_with gnome gnomeui)		\
		$(use_with gtk)					\
		--without-ming					\
		--with-digcola					\
		--with-ipsepcola				\
		--with-fontconfig				\
		--with-freetype					\
		--with-libgd					\
		${myconf}						\
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	sed -i -e "s:htmldir:htmlinfodir:g" doc/info/Makefile || die

	emake DESTDIR="${D}" \
		txtdir='${EPREFIX}'/usr/share/doc/${PF} \
		htmldir='${EPREFIX}'/usr/share/doc/${PF}/html \
		htmlinfodir='${EPREFIX}'/usr/share/doc/${PF}/html/info \
		pdfdir='${EPREFIX}'/usr/share/doc/${PF}/pdf \
		pkgconfigdir='${EPREFIX}'/usr/$(get_libdir)/pkgconfig \
		install || die "emake install failed"

	use examples || rm -rf "${ED}/usr/share/graphviz/demo"

	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	# This actually works if --enable-ltdl is passed
	# to configure
	dot -c
	if use python ; then
		python_mod_optimize
	fi
}

pkg_postrm() {
	if use python ; then
		python_mod_cleanup
	fi
}
