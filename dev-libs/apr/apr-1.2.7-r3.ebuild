# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-1.2.7-r3.ebuild,v 1.2 2006/09/10 17:32:03 the_paya Exp $

EAPI="prefix"

inherit autotools

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="ipv6 urandom debug"
RESTRICT="test"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}

	# for some reason not all the .m4 files that are referenced in 
	# configure.in exist, so we remove all references and include every
	# .m4 file in build using aclocal via eautoreconf
	# See bug 135463
	sed -i -e '/sinclude/d' configure.in
	AT_M4DIR="build" eautoreconf

	epatch ${FILESDIR}/config.layout.patch

}

src_compile() {


	myconf="--enable-layout=gentoo"

	# For now we always enable ipv6. Testing has shown that is still works
	# correctly in ipv4 systems, and currently, the ipv4-only support
	# is broken in apr. (ipv6 is enabled by default)
	#myconf="${myconf} $(use_enable ipv6)"

	myconf="${myconf} --enable-threads"
	myconf="${myconf} --enable-nonportable-atomics"
	if use urandom; then
		einfo "Using /dev/urandom as random device"
		myconf="${myconf} --with-devrandom=/dev/urandom"
	else
		einfo "Using /dev/random as random device"
		myconf="${myconf} --with-devrandom=/dev/random"
	fi

	useq debug && myconf="${myconf} --enable-maintainer-mode"

	# We pre-load the cache with the correct answer!  This avoids
	# it violating the sandbox.  This may have to be changed for
	# non-Linux systems or if sem_open changes on Linux.  This
	# hack is built around documentation in /usr/include/semaphore.h
	# and the glibc (pthread) source
	# See bugs 24215 and 133573
	echo 'ac_cv_func_sem_open=${ac_cv_func_sem_open=no}' >> ${S}/config.cache

	econf ${myconf} || die "Configure failed"

	# Make sure we use the system libtool
	sed -i 's,$(apr_builddir)/libtool,/usr/bin/libtool,' build/apr_rules.mk
	sed -i 's,${installbuilddir}/libtool,/usr/bin/libtool,' apr-1-config
	rm libtool

	emake || die "Make failed"
}

src_install() {

	make DESTDIR="${D}" install || die "make install failed"

	dodoc CHANGES NOTICE LICENSE
}

pkg_postinst() {
	ewarn "We are now using the system's libtool rather then bundling"
	ewarn "our own. You will need to rebuild Apache and possibly other"
	ewarn "software if you get a message similiar to the following:"
	ewarn
	ewarn "   /usr/share/apr-1/build-1/libtool: No such file or directory"
	ewarn
}
