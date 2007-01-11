# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/wxlib.eclass,v 1.18 2007/01/04 23:11:17 dirtyepic Exp $

# Author Diego Pettenò <flameeyes@gentoo.org>
# Maintained by wxwidgets herd

# This eclass is used by wxlib-based packages (wxGTK, wxMotif, wxBase, wxMac) to share code between
# them.

inherit flag-o-matic eutils multilib toolchain-funcs

IUSE="debug doc odbc unicode"

LICENSE="wxWinLL-3"

# Note 1: Gettext is not runtime dependency even if nls? because wxWidgets
#         has its own implementation of it
# Note 2: PCX support is enabled if the correct libraries are detected.
#         There is no USE flag for this.

DEPEND="${RDEPEND}
	sys-libs/zlib
	sys-apps/sed"

HOMEPAGE="http://www.wxwidgets.org"
SRC_URI="mirror://sourceforge/wxwindows/wxWidgets-${PV}.tar.bz2
	doc? ( mirror://sourceforge/wxwindows/wxWidgets-${PV}-HTML.tar.gz )"
S=${WORKDIR}/wxWidgets-${PV}


# Configure a build.
# It takes three parameters;
# $1: prefix for the build directory (used for wxGTK which has two
#     builds needed.
# $2: "unicode" if it must be build with else ""
# $3: all the extra parameters to pass to configure script
configure_build() {
	export LANG='C'

	mkdir ${S}/$1_build
	cd ${S}/$1_build
	# odbc works with ansi only:
	subconfigure $3 $(use_with odbc)
	emake -j1 CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "emake failed"
	#wxbase has no contrib:
	if [[ -e contrib/src ]]; then
		cd contrib/src
		emake -j1 CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "emake contrib failed"
	fi

	if [[ "$2" == "unicode" ]] && use unicode; then
		mkdir ${S}/$1_build_unicode
		cd ${S}/$1_build_unicode
		subconfigure $3 --enable-unicode
		emake -j1 CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "Unicode emake failed"
		if [[ -e contrib/src ]]; then
			cd contrib/src
			emake -j1 CXX="$(tc-getCXX)" CC="$(tc-getCC)" || die "Unicode emake contrib failed"
		fi
	fi
}

# This is a commodity function which calls configure script
# with the default parameters plus extra parameters. It's used
# as building the unicode version required redoing it.
# It takes all the params and passes them to the script
subconfigure() {
	ECONF_SOURCE="${S}" \
		econf \
			--disable-precomp-headers \
			--with-zlib \
			$(use_enable debug) $(use_enable debug debug_gdb) \
			$* || die "./configure failed"
}

# Installs a build
# It takes only a parameter: the prefix for the build directory
# see configure_build function
install_build() {
	cd ${S}/$1_build
	einstall libdir="${D}/usr/$(get_libdir)" || die "Install failed"
	if [[ -e contrib ]]; then
		cd contrib/src
		einstall libdir="${D}/usr/$(get_libdir)" || die "Install contrib failed"
	fi
	if [[ -e ${S}/$1_build_unicode ]]; then
		cd ${S}/$1_build_unicode
		einstall libdir="${D}/usr/$(get_libdir)" || die "Unicode install failed"
		cd contrib/src
		einstall libdir="${D}/usr/$(get_libdir)" || die "Unicode install contrib failed"
	fi
}

# To be called at the end of src_install to perform common cleanup tasks
wxlib_src_install() {

	cp ${D}/usr/bin/wx-config ${D}/usr/bin/wx-config-2.6 || die "Failed to cp wx-config"

	# In 2.6 all wx-config*'s go in/usr/lib/wx/config not
	# /usr/bin where 2.4 keeps theirs.
	# Only install wx-config if 2.4 is not installed:
	if [ -e "/usr/bin/wx-config" ]; then
		if [ "$(/usr/bin/wx-config --release)" = "2.4" ]; then
			rm ${D}/usr/bin/wx-config
		fi
	fi


	if use doc; then
		dodir /usr/share/doc/${PF}/{demos,samples,utils}
		dohtml ${S}/contrib/docs/html/ogl/*
		dohtml ${S}/docs/html/*
		cp -R ${S}/demos/* ${D}/usr/share/doc/${PF}/demos/
		cp -R ${S}/utils/* ${D}/usr/share/doc/${PF}/utils/
		cp -R ${S}/samples/* ${D}/usr/share/doc/${PF}/samples/
		dodoc ${S}/*.txt
	fi

}


EXPORT_FUNCTIONS src_install

