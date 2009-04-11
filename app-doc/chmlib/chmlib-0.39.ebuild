# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-doc/chmlib/chmlib-0.39.ebuild,v 1.5 2007/07/15 23:35:58 mr_bones_ Exp $

inherit eutils multilib flag-o-matic versionator

DESCRIPTION="Library for MS CHM (compressed html) file format plus extracting and http server utils"
HOMEPAGE="http://www.jedrea.com/chmlib/"
SRC_URI="http://www.jedrea.com/${PN}/${P}.tar.bz2"
DEPEND=">=sys-apps/sed-4"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

MY_PV=$(get_version_component_range 1-2 )
S="${WORKDIR}/${PN}-${MY_PV}"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -r "s,(\\\$\\{INSTALLPREFIX\\}),\${DESTDIR}\\1,g;
			s,@LIBTOOL@,libtool,g;
			s,(\\\$\\{INSTALLPREFIX\\})/lib,\1/$(get_libdir),g" \
			Makefile.in || die "sed failed"

	# bit ugly, but to reduce prefix diff
	[[ ${CHOST} == *-darwin* ]] && sed -i -e 's/libtool/glibtool/g' Makefile.in

	if [ "${ARCH}" = "ppc" ]; then
		# In this case it is safe to take this rather
		# stupid action =)
		sed -i "s:__i386__:__powerpc__:" src/chm_lib.c
	fi

	if [ "${ARCH}" == "hppa" ]; then
		sed -i "s:__i386__:__hppa__:" src/chm_lib.c
	fi
}

src_compile() {
	append-flags "-L${S}/src/.libs"

	econf --enable-examples=yes|| die "econf failed"
	emake || die
}

src_install() {
	#Make expects to find these dirs.
	dodir /usr/bin
	dodir /usr/$(get_libdir)
	dodir /usr/include
	dodir /usr/share/doc/${PF}/examples/

	make install DESTDIR=${D}

	#Install examples as well.
	insinto /usr/share/doc/${PF}/examples/
	doins src/test_chmLib.c src/enum_chmLib.c src/chm_http.c

	dodoc AUTHORS NEWS README
}
