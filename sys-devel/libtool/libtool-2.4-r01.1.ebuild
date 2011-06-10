# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.4-r1.ebuild,v 1.1 2010/11/29 15:12:34 flameeyes Exp $

EAPI="3"

LIBTOOLIZE="true" #225559
inherit eutils autotools multilib prefix

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="vanilla"

RDEPEND="sys-devel/gnuconfig
	!<sys-devel/autoconf-2.62:2.5
	!<sys-devel/automake-1.10.1:1.10
	!=sys-devel/libtool-2*:1.5"
DEPEND="${RDEPEND}
	|| ( >=sys-devel/binutils-2.20
		sys-devel/binutils-apple sys-devel/native-cctools )
	|| ( app-arch/xz-utils app-arch/lzma-utils )"

src_prepare() {
	if ! use vanilla ; then
		[[ ${CHOST} == *-winnt* ]] &&
			epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-winnt.patch
		epatch "${FILESDIR}"/2.2.6b/${PN}-2.2.6b-mint.patch
# fails on two hunks, likely is still necessary
#		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-hppa-hpux.patch
		epatch "${FILESDIR}"/2.2.6b/${PN}-2.2.6b-irix.patch

		# seems that libtool has to know about EPREFIX a little bit better,
		# since it fails to find prefix paths to search libs from, resulting in
		# some packages building static only, since libtool is fooled into
		# thinking that libraries are unavailable (argh...). This could also be
		# fixed by making the gcc wrapper return the correct result for
		# -print-search-dirs (doesn't include prefix dirs ...).
		if use prefix ; then
			epatch "${FILESDIR}"/2.2.10/${PN}-2.2.10-eprefix.patch
			eprefixify libltdl/m4/libtool.m4
		fi

		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-module-bundle.patch
		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-use-linux-version.patch
		epatch "${FILESDIR}"/${PV}/${P}-interix.patch
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
	fi
}

src_configure() {
	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL="$(type -P bash)"

	local myconf
	# usr/bin/libtool is provided by binutils-apple
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	econf ${myconf} || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	for x in $(find "${ED}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf "${EPREFIX}"/usr/share/gnuconfig/${x##*/} "${x}"
	done
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libltdl$(get_libname 3)
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libltdl$(get_libname 3)
}
