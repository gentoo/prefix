# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portage-utils/portage-utils-0.4.ebuild,v 1.1 2010/06/08 05:49:29 vapier Exp $

inherit flag-o-matic toolchain-funcs eutils prefix

DESCRIPTION="small and fast portage helper tools written in C"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static"

DEPEND="
	ppc-aix? ( dev-libs/gnulib )
	x86-interix? ( dev-libs/gnulib )
	ia64-hpux? ( dev-libs/gnulib )
	hppa-hpux? ( dev-libs/gnulib )
	sparc-solaris? ( dev-libs/gnulib )
	sparc64-solaris? ( dev-libs/gnulib )
"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# gcc-4.2 has problems with "[restrict]" in c99,
	# used in /usr/include/regex.h on hpux11.31.
	[[ ${CHOST} == *-hpux11.31 ]] && \
		sed -i -e 's/std=gnu99/std=gnu89/g' Makefile
	epatch "${FILESDIR}"/${P}-darwin8.patch
}

src_compile() {
	tc-export CC
	# note: Solaris 10+ fails to compile with gnulib, due to static/nonstatic
	# declaration of strcasecmp, it doesn't need gnulib
	if [[ ${CHOST} == *-aix* ||
		  ${CHOST} == *-interix[35]* ||
		  ${CHOST} == *-hpux* ||
		  ${CHOST} == *-solaris2.9 ]];
	then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		# append-libs doesn't work, since the Makefile doesn't know LIBS, it seems
		append-ldflags -lgnu
		# gnulib provides strcasestr
		sed -i -e 's/strcasestr/unused_strcasestr/' libq/compat.c
	fi
	use static && append-ldflags -static
	emake EPREFIX="${EPREFIX}" || die
}

src_install() {
	emake install EPREFIX="${EPREFIX}" DESTDIR="${D}" || die
	prepalldocs

	exeinto /etc/portage/bin
	doexe "${FILESDIR}"/post_sync || die
	insinto /etc/portage/postsync.d
	doins "${FILESDIR}"/q-reinitialize || die
	eprefixify ${ED}/etc/portage/bin/post_sync \
		${ED}/etc/portage/postsync.d/q-reinitialize
}

pkg_preinst() {
	# preserve +x bit on postsync files #301721
	local x
	pushd "${ED}" >/dev/null
	for x in etc/portage/postsync.d/* ; do
		[[ -x ${EROOT}/${x} ]] && chmod +x "${x}"
	done
}

pkg_postinst() {
	elog "${EPREFIX}/etc/portage/postsync.d/q-reinitialize has been installed for convenience"
	elog "If you wish for it to be automatically run at the end of every --sync:"
	elog "   # chmod +x /etc/portage/postsync.d/q-reinitialize"
	elog "Normally this should only take a few seconds to run but file systems"
	elog "such as ext3 can take a lot longer.  To disable, simply do:"
	elog "   # chmod -x /etc/portage/postsync.d/q-reinitialize"
}
