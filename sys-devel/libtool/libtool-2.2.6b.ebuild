# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.2.6b.ebuild,v 1.8 2010/07/06 12:41:38 vapier Exp $

LIBTOOLIZE="true" #225559
inherit eutils autotools flag-o-matic multilib prefix

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="vanilla test"

RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10.1
	!=sys-devel/automake-1.10"
DEPEND="${RDEPEND}
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/help2man"

pkg_setup() {
	if use test && ! has_version '>sys-devel/binutils-2.19.51'; then
		einfo "Disabling --as-needed, since you got older binutils and you asked"
		einfo "to run tests. With the stricter (older) --as-needed behaviour"
		einfo "you'd be seeing a test failure in test #63; this has been fixed"
		einfo "in the newer version of binutils."
		append-ldflags $(no-as-needed)
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-tests-locale.patch #249168

	if ! use vanilla ; then
		[[ ${CHOST} == *-winnt* || ${CHOST} == *-interix* ]] &&
			epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-winnt.patch
		epatch "${FILESDIR}"/2.2.6b/${PN}-2.2.6b-mint.patch
		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-hppa-hpux.patch
		epatch "${FILESDIR}"/2.2.6b/${PN}-2.2.6b-irix.patch

		# seems that libtool has to know about EPREFIX a little bit better,
		# since it fails to find prefix paths to search libs from, resulting in
		# some packages building static only, since libtool is fooled into
		# thinking that libraries are unavailable (argh...). This could also be
		# fixed by making the gcc wrapper return the correct result for
		# -print-search-dirs (doesn't include prefix dirs ...).
		if use prefix ; then
			epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-eprefix.patch
			eprefixify libltdl/m4/libtool.m4
		fi

		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-module-bundle.patch
		epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-use-linux-version.patch
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
	fi

	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL="$(type -P bash)"
}

src_compile() {
	local myconf
	# usr/bin/libtool is provided by binutils-apple
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	econf ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local p=
	[[ ${CHOST} == *-darwin* ]] && p=g
	local x
	for x in ${p}libtool ${p}libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

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
