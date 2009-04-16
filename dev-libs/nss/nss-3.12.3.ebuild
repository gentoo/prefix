# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nss/nss-3.12.3.ebuild,v 1.1 2009/04/15 13:37:53 armin76 Exp $

inherit eutils flag-o-matic multilib toolchain-funcs

NSPR_VER="4.7.4"
RTM_NAME="NSS_${PV//./_}_RTM"
DESCRIPTION="Mozilla's Network Security Services library that implements PKI support"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/nss/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/${RTM_NAME}/src/${P}.tar.bz2"
#SRC_URI="http://dev.gentoo.org/~armin76/dist/${P}.tar.bz2
#	mirror://gentoo/${P}.tar.bz2"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="utils"

S="${WORKDIR}/${P}"

DEPEND=">=dev-libs/nspr-${NSPR_VER}
	>=dev-db/sqlite-3.5"

src_unpack() {
	unpack ${A}

	cd "${S}"/mozilla/security/coreconf
	# hack nspr paths
	echo 'INCLUDES += -I'"${EPREFIX}"'/usr/include/nspr -I$(DIST)/include/dbm' \
		>> headers.mk || die "failed to append include"

	# cope with nspr being in /usr/$(get_libdir)/nspr
	sed -e 's:$(DIST)/lib:'"${EPREFIX}"'/usr/'"$(get_libdir)"/nspr':' \
		-i location.mk

	# modify install path
	sed -e 's:SOURCE_PREFIX = $(CORE_DEPTH)/\.\./dist:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
		-i source.mk

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk

	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.12-config.patch
	epatch "${FILESDIR}"/${PN}-3.12-config-1.patch
	epatch "${FILESDIR}"/${PN}-mips64-2.patch

	epatch "${FILESDIR}"/${PN}-3.12-solaris-gcc.patch  # breaks non-gnu tools
}

src_compile() {
	strip-flags

	echo > "${T}"/test.c
	$(tc-getCC) -c "${T}"/test.c -o "${T}"/test.o
	case $(file "${T}"/test.o) in
	*64-bit*) export USE_64=1;;
	*32-bit*) ;;
	*) die "Failed to detect whether your arch is 64bits or 32bits, disable distcc if you're using it, please";;
	esac

	export NSDISTMODE=copy
	export NSS_USE_SYSTEM_SQLITE=1
	export NSS_ENABLE_ECC=1
	cd "${S}"/mozilla/security/coreconf
	emake -j1 BUILD_OPT=1 XCFLAGS="${CFLAGS}" CC="$(tc-getCC)" || die "coreconf make failed"
	cd "${S}"/mozilla/security/dbm
	emake -j1 BUILD_OPT=1 XCFLAGS="${CFLAGS}" CC="$(tc-getCC)" || die "dbm make failed"
	cd "${S}"/mozilla/security/nss
	emake -j1 BUILD_OPT=1 XCFLAGS="${CFLAGS}" CC="$(tc-getCC)" || die "nss make failed"
}

src_install () {
	MINOR_VERSION=12
	cd "${S}"/mozilla/security/dist

	# put all *.a files in /usr/lib/nss (because some have conflicting names
	# with existing libraries)
	dodir /usr/$(get_libdir)/nss
	cp -L */lib/*.so "${ED}"/usr/$(get_libdir)/nss || die "copying shared libs failed"
	cp -L */lib/*.chk "${ED}"/usr/$(get_libdir)/nss || die "copying chk files failed"
	cp -L */lib/*.a "${ED}"/usr/$(get_libdir)/nss || die "copying libs failed"

	# all the include files
	insinto /usr/include/nss
	doins private/nss/*.h
	doins public/nss/*.h
	cd "${ED}"/usr/$(get_libdir)/nss
	for file in *.so; do
		mv ${file} ${file}.${MINOR_VERSION}
		ln -s ${file}.${MINOR_VERSION} ${file}
	done

	# coping with nss being in a different path. We move up priority to
	# ensure that nss/nspr are used specifically before searching elsewhere.
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/nss" > "${ED}"/etc/env.d/08nss

	dodir /usr/bin
	dodir /usr/$(get_libdir)/pkgconfig
	cp "${FILESDIR}"/3.12-nss-config.in "${ED}"/usr/bin/nss-config
	cp "${FILESDIR}"/3.12-nss.pc.in "${ED}"/usr/$(get_libdir)/pkgconfig/nss.pc
	NSS_VMAJOR=`cat ${S}/mozilla/security/nss/lib/nss/nss.h | grep "#define.*NSS_VMAJOR" | awk '{print $3}'`
	NSS_VMINOR=`cat ${S}/mozilla/security/nss/lib/nss/nss.h | grep "#define.*NSS_VMINOR" | awk '{print $3}'`
	NSS_VPATCH=`cat ${S}/mozilla/security/nss/lib/nss/nss.h | grep "#define.*NSS_VPATCH" | awk '{print $3}'`

	sed -e "s,@libdir@,"${EPREFIX}"/usr/"$(get_libdir)"/nss,g" \
		-e "s,@prefix@,"${EPREFIX}"/usr,g" \
		-e "s,@exec_prefix@,\$\{prefix},g" \
		-e "s,@includedir@,\$\{prefix}/include/nss,g" \
		-e "s,@MOD_MAJOR_VERSION@,$NSS_VMAJOR,g" \
		-e "s,@MOD_MINOR_VERSION@,$NSS_VMINOR,g" \
		-e "s,@MOD_PATCH_VERSION@,$NSS_VPATCH,g" \
		-i "${ED}"/usr/bin/nss-config
	chmod 755 "${ED}"/usr/bin/nss-config

	sed -e "s,@libdir@,"${EPREFIX}"/usr/"$(get_libdir)"/nss,g" \
	      -e "s,@prefix@,"${EPREFIX}"/usr,g" \
	      -e "s,@exec_prefix@,\$\{prefix},g" \
	      -e "s,@includedir@,\$\{prefix}/include/nss," \
	      -e "s,@NSPR_VERSION@,`nspr-config --version`,g" \
	      -e "s,@NSS_VERSION@,$NSS_VMAJOR.$NSS_VMINOR.$NSS_VPATCH,g" \
	      -i "${ED}"/usr/$(get_libdir)/pkgconfig/nss.pc
	chmod 644 "${ED}"/usr/$(get_libdir)/pkgconfig/nss.pc

	if use utils; then
		cd "${S}"/mozilla/security/dist/*/bin/
		for f in *; do
			newbin ${f} nss${f}
		done
	fi
}
