# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gettext/gettext-0.16.1.ebuild,v 1.7 2007/01/23 19:46:08 grobian Exp $

EAPI="prefix"

inherit flag-o-matic eutils multilib toolchain-funcs mono libtool elisp-common

DESCRIPTION="GNU locale utilities"
HOMEPAGE="http://www.gnu.org/software/gettext/gettext.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="emacs nls doc nocxx"

DEPEND="virtual/libiconv
	dev-libs/expat"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epunt_cxx

	epatch "${FILESDIR}"/${PN}-0.14.1-lib-path-tests.patch #81628
	epatch "${FILESDIR}"/${PN}-0.14.2-fix-race.patch #85054
	epatch "${FILESDIR}"/${PN}-0.15-expat-no-dlopen.patch #146211

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
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_with emacs) \
		--disable-java \
		${myconf} \
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

	# older gettext's sometimes installed libintl ...
	# need to keep the linked version or the system
	# could die (things like sed link against it :/)
	local libname="libintl$(get_libname 7)"
	if [[ -e ${EROOT}/usr/$(get_libdir)/${libname} ]] ; then
		cp -pPR ${EROOT}/usr/$(get_libdir)/${libname}* "${ED}"/usr/$(get_libdir)/
		touch "${ED}"/usr/$(get_libdir)/${libname}*
	fi
	if [[ -e ${EROOT}/$(get_libdir)/${libname} ]] ; then
		dodir /$(get_libdir)
		cp -pPR ${EROOT}/$(get_libdir)/${libname}* "${ED}"/$(get_libdir)/
		touch "${ED}"/$(get_libdir)/${libname}*
	fi

	if [[ $USERLAND == "BSD" ]] ; then
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

	# Remove emacs site-lisp stuff if 'emacs' is not in USE
	if use emacs ; then
		elisp-site-file-install "${FILESDIR}"/50po-mode-gentoo.el
	else
		rm -rf "${ED}"/usr/share/emacs
	fi

	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_postinst() {
	use emacs && elisp-site-regen
	ewarn "Any package that linked against the previous version"
	ewarn "of gettext will have to be rebuilt."
	ewarn "Please 'emerge gentoolkit' and run:"
	ewarn "revdep-rebuild --library libintl.so.7"
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
