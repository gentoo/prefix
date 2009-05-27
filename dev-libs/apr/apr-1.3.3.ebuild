# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-1.3.3.ebuild,v 1.10 2009/01/23 11:41:20 armin76 Exp $

EAPI=1

inherit autotools

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc +urandom debug"
RESTRICT="test"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

#	# the included libtool.m4 is causing big trouble, use the system one
#	rm -f build/libtool.m4
#	epatch "${FILESDIR}"/${PN}-1.2.8-libtool.patch

	epatch "${FILESDIR}"/${PN}-1.2.11-mint.patch

	# for some reason not all the .m4 files that are referenced in
	# configure.in exist, so we remove all references and include every
	# .m4 file in build using aclocal via eautoreconf
	# See bug 135463
	sed -i -e '/sinclude/d' configure.in
	AT_M4DIR="build" eautoreconf

	epatch "${FILESDIR}"/config.layout.patch
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	# For now we always enable ipv6. Testing has shown that is still works
	# correctly in ipv4 systems, and currently, the ipv4-only support
	# is broken in apr. (ipv6 is enabled by default) Bug #123320
	#myconf="${myconf} $(use_enable ipv6)"

	if use urandom; then
		myconf="${myconf} --with-devrandom=/dev/urandom"
	else
		myconf="${myconf} --with-devrandom=/dev/random"
	fi

	if use debug; then
		myconf="${myconf} --enable-maintainer-mode"
		myconf="${myconf} --enable-pool-debug=all"
	fi

	[[ ${CHOST} == *-mint* ]] && myconf="${myconf} --disable-dso"

	# shl_load does not search runpath, but hpux11 supports dlopen
	[[ ${CHOST} == *-hpux11* ]] && myconf="${myconf} --enable-dso=dlfcn"

	# We pre-load the cache with the correct answer!  This avoids
	# it violating the sandbox.  This may have to be changed for
	# non-Linux systems or if sem_open changes on Linux.  This
	# hack is built around documentation in /usr/include/semaphore.h
	# and the glibc (pthread) source
	# See bugs 24215 and 133573
	echo 'ac_cv_func_sem_open=${ac_cv_func_sem_open=no}' >> "${S}"/config.cache

	if [[ ${CHOST} == *-solaris2.10 ]]; then
		case $(<$([[ ${CHOST} != ${CBUILD} ]] && echo "${EPREFIX}/usr/${CHOST}")/usr/include/atomic.h) in
		*atomic_cas_ptr*) ;;
		*)
			elog "You do not have Solaris Patch ID "$(
				[[ ${CHOST} == sparc* ]] && echo 118884 || echo 118885
			)" (Problem 4954703) installed on your host ($(hostname)),"
			elog "using generic atomic operations instead."
			myconf="${myconf} --disable-nonportable-atomics"
			;;
		esac
	fi
	econf --enable-layout=gentoo \
		--enable-threads \
		--enable-nonportable-atomics \
		${myconf}

	# Make sure we use the system libtool
	local LIBTL
	[[ ${CHOST} == *-darwin* ]] \
		&& LIBTL="${EPREFIX}"/usr/bin/glibtool \
		|| LIBTL="${EPREFIX}"/usr/bin/libtool
	sed -i 's,$(apr_builddir)/libtool,'"${LIBTL}"',' "${S}"/build/apr_rules.mk
	sed -i 's,${installbuilddir}/libtool,'"${LIBTL}"',' "${S}"/apr-1-config
	rm -f "${S}"/libtool

	emake || die "Make failed"

	if use doc; then
		emake dox || die "make dox failed"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# This file is only used on AIX systems, which gentoo is not,
	# and causes collisions between the SLOTs, so kill it
	rm "${ED}"/usr/$(get_libdir)/apr.exp

	dodoc CHANGES NOTICE

	if use doc; then
		dohtml docs/dox/html/* || die
	fi
}

pkg_postinst() {
	ewarn "We are now using the system's libtool rather than bundling"
	ewarn "our own. You will need to rebuild Apache and possibly other"
	ewarn "software if you get a message similiar to the following:"
	ewarn
	ewarn "   /usr/share/apr-1/build-1/libtool: No such file or directory"
	ewarn
}
