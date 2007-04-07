# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/graphviz/graphviz-2.12.ebuild,v 1.17 2007/04/01 15:22:57 yoswink Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils autotools multilib python

DESCRIPTION="Open Source Graph Visualization Software"
HOMEPAGE="http://www.graphviz.org/"
SRC_URI="http://www.graphviz.org/pub/graphviz/ARCHIVE/${P}.tar.gz"

LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-solaris"
IUSE="doc examples gnome gtk nls pango perl python ruby X tcl tk"

RDEPEND=">=media-libs/gd-2.0.28
	>=sys-libs/zlib-1.2.3
	>=media-libs/freetype-2.1.3
	>=media-libs/libpng-1.2.5
	>=media-libs/jpeg-6b
	>=dev-libs/expat-1.95.5
	=dev-libs/glib-2*
	virtual/libiconv
	media-libs/fontconfig
	pango? ( x11-libs/pango )
	gnome? ( gnome-base/libgnomeui )
	gtk? ( >=x11-libs/gtk+-2 )
	perl? ( dev-lang/perl )
	python? ( dev-lang/python )
	ruby? ( dev-lang/ruby )
	X? ( x11-libs/libXaw x11-libs/libXpm )
	tcl? ( >=dev-lang/tcl-8.3 )
	tk? ( >=dev-lang/tk-8.3 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	perl? ( dev-lang/swig )
	python? ( dev-lang/swig )
	ruby? ( dev-lang/swig )
	tcl? ( dev-lang/swig )"

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
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-notcl.patch"
	epatch "${FILESDIR}/${P}-find-system-libgd.patch"
	epatch "${FILESDIR}/${P}-configure.patch"
	epatch "${FILESDIR}/${P}-bindings.patch"

	sed -i \
		-e 's:LC_COLLATE=C:LC_ALL=C:g' \
		lib/common/Makefile.* || die "sed failed" # bug 134834

	# ToDo: Do the same thing for examples and/or
	#       write a patch for a configuration-option
	#       and send it to upstream
	if ! use doc ; then
		find . -iname Makefile.am \
			| xargs sed -i \
			-e '/html_DATA/d' \
			-e '/pdf_DATA/d'
	fi

	# This is an old version of libtool
	rm -rf libltdl
	sed -i -e '/libltdl/d' \
		configure.ac || die "sed failed"

	# no nls, no gettext, no iconv macro, so disable it
	use nls || sed -i '/^AM_ICONV/d' configure.ac

	# Nuke the dead symlinks for the bindings
	sed -i \
		-e '/$(pkgluadir)/d' \
		tclpkg/gv/Makefile.am || die "sed failed"

	eautoreconf
}

src_compile() {
	# If we want pango, we need --with-x, otherwise
	# nothing gets built. Dependencies should be ok.
	local myconf=""
	if use X || use pango ; then
		myconf="--with-x"
	else
		myconf="--without-x"
	fi

	econf \
		--enable-ltdl \
		--with-libgd \
		--with-digcola \
		--with-ipsepcola \
		--without-ming \
		--disable-{sharp,io} \
		$(use_enable tcl) \
		$(use_enable tk) \
		--disable-guile \
		--disable-java \
		--disable-ocaml \
		--disable-lua \
		$(use_enable perl) \
		--disable-php \
		$(use_enable python) \
		$(use_enable ruby) \
		$(use_with gtk) \
		$(use_with pango pangocairo) \
		${myconf} \
		$(use_with gnome gnomeui) \
		|| die "econf failed"
	emake || die "emake failed, use gcc-apple on OSX!"
}

src_install() {
	sed -i \
		-e "s:htmldir:htmlinfodir:g" \
		doc/info/Makefile

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
