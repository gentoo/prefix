# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gettext/gettext-0.16.1-r1.ebuild,v 1.16 2010/03/30 23:22:10 solar Exp $

inherit flag-o-matic eutils multilib toolchain-funcs mono libtool autotools

DESCRIPTION="GNU locale utilities"
HOMEPAGE="http://www.gnu.org/software/gettext/gettext.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="emacs nls doc nocxx elibc_glibc"

DEPEND="virtual/libiconv
	dev-libs/expat"
PDEPEND="emacs? ( app-emacs/po-mode )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.14.1-lib-path-tests.patch #81628
	epatch "${FILESDIR}"/${PN}-0.14.2-fix-race.patch #85054
	epatch "${FILESDIR}"/${PN}-0.15-expat-no-dlopen.patch #146211
	epatch "${FILESDIR}"/${P}-x64-solaris.patch

	# bundled libtool seems to be broken so skip certain rpath tests
	# http://lists.gnu.org/archive/html/bug-libtool/2005-03/msg00070.html
	sed -i \
		-e '2iexit 77' \
		autoconf-lib-link/tests/rpath-3*[ef] || die "sed tests"

	# sanity check for Bug 105304
	if [[ -z ${USERLAND} ]] ; then
		eerror "You just hit Bug 105304, please post your 'emerge info' here:"
		eerror "http://bugs.gentoo.org/105304"
		die "Aborting to prevent screwing your system"
	fi

	for x in $(find "${S}" -type f -name 'libtool.m4'); do
		cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 ${x}
	done

	( # need new libtool for interix
		export AT_NO_RECURSIVE=yes
		cd "${S}" && eautoreconf
		cd "${S}"/gettext-tools && AT_M4DIR="m4 ../gettext-runtime/m4 ../autoconf-lib-link/m4 ../m4 gnulib-m4 libgettextpo/gnulib-m4" eautoreconf
		cd "${S}"/gettext-runtime && AT_M4DIR="m4 ../autoconf-lib-link/m4 ../m4 gnulib-m4" eautoreconf
		cd "${S}"/gettext-runtime/libasprintf && AT_M4DIR="../../m4 ../m4" eautoreconf
		cd "${S}"/autoconf-lib-link && AT_M4DIR="m4 ../m4" eautoreconf
	) || die "eautoreconf failed"

	epunt_cxx
}

src_compile() {
	local myconf=""
	# Build with --without-included-gettext (on glibc systems)
	if use elibc_glibc ; then
		myconf="${myconf} --without-included-gettext $(use_enable nls)"
	else
		myconf="${myconf} --with-included-gettext --enable-nls"
	fi
	use nocxx && export CXX=$(tc-getCC)

	# Emacs support is now in a separate package, so configure --without-emacs
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--without-emacs \
		--disable-java \
		${myconf} \
		$(use_enable openmp) \
		|| die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die "install failed"
	use nls || rm -r "${ED}"/usr/share/locale
	dosym msgfmt /usr/bin/gmsgfmt #43435
	dobin gettext-tools/misc/gettextize || die "gettextize"

	# remove stuff that glibc handles
	if use elibc_glibc ; then
		rm -f "${ED}"/usr/include/libintl.h
		rm -f "${ED}"/usr/$(get_libdir)/libintl.*
	fi
	rm -f "${ED}"/usr/share/locale/locale.alias "${ED}"/usr/lib/charset.alias

	if [[ ${USERLAND} == "BSD" ]] ; then
		libname="libintl$(get_libname 8)"
		# Move dynamic libs and creates ldscripts into /usr/lib
		dodir /$(get_libdir)
		mv "${ED}"/usr/$(get_libdir)/${libname}* "${ED}"/$(get_libdir)/
		gen_usr_ldscript ${libname}
	fi

	if use doc ; then
		dohtml "${ED}"/usr/share/doc/${PF}/*.html
	else
		rm -rf "${ED}"/usr/share/doc/${PF}/{csharpdoc,examples,javadoc2,javadoc1}
	fi
	rm -f "${ED}"/usr/share/doc/${PF}/*.html

	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_preinst() {
	# older gettext's sometimes installed libintl ...
	# need to keep the linked version or the system
	# could die (things like sed link against it :/)
	preserve_old_lib /{,usr/}$(get_libdir)/libintl$(get_libname 7)
}

pkg_postinst() {
	ewarn "Any package that linked against the previous version"
	ewarn "of gettext will have to be rebuilt."
	ewarn "Please 'emerge gentoolkit' and run:"
	ewarn "revdep-rebuild --library libintl.so.7"
}
