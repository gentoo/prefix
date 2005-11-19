# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/openssl/openssl-0.9.8a.ebuild,v 1.1 2005/10/12 05:20:02 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Toolkit for SSL v2/v3 and TLS v1"
HOMEPAGE="http://www.openssl.org/"
SRC_URI="mirror://openssl/source/${P}.tar.gz"

LICENSE="openssl"
SLOT="0"
KEYWORDS="-* ~ppc-macos"
IUSE="emacs test bindist zlib"

RDEPEND=""
DEPEND="${RDEPEND}
	sys-apps/diffutils
	>=dev-lang/perl-5
	test? ( sys-devel/bc )"

src_unpack() {
	unpack ${A}

	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.9.8-ppc64.patch
	epatch "${FILESDIR}"/${PN}-0.9.7e-gentoo.patch
	epatch "${FILESDIR}"/${PN}-0.9.8-hppa-fix-detection.patch
	epatch "${FILESDIR}"/${PN}-0.9.7-alpha-default-gcc.patch
	epatch "${FILESDIR}"/${PN}-0.9.8-parallel-build.patch
#	epatch "${FILESDIR}"/${PN}-0.9.8-make-engines-dir.patch
	epatch "${FILESDIR}"/${PN}-0.9.8-engines-dylib.patch

	# allow openssl to be cross-compiled
	cp "${FILESDIR}"/gentoo.config-0.9.7g gentoo.config || die "cp cross-compile failed"
	chmod a+rx gentoo.config

	# Don't build manpages if we don't want them
	has noman FEATURES && sed -i '/^install:/s:install_docs::' Makefile.org

	case $(gcc-version) in
		3.2)
			filter-flags -fprefetch-loop-arrays -freduce-all-givs -funroll-loop
		;;
		3.4 | 3.3 )
			filter-flags -fprefetch-loop-arrays -freduce-all-givs -funroll-loops
			[[ ${ARCH} == "ppc" ||  ${ARCH} == "ppc64" ]] && append-flags -fno-strict-aliasing
		;;
	esac
	append-flags -Wa,--noexecstack

	# replace CFLAGS
	OLDIFS=$IFS
	IFS=$'\n'
	for a in $( grep -n -e "^\"linux-" Configure ); do
		LINE=$( echo $a | awk -F: '{print $1}' )
		CUR_CFLAGS=$( echo $a | awk -F: '{print $3}' )
		NEW_CFLAGS=$(echo $CUR_CFLAGS | sed -r -e "s|-O[23]||" -e "s:-fomit-frame-pointer::" -e "s:-mcpu=[-a-z0-9]+::" -e "s:-m486::")
		# ppc64's current toolchain sucks at optimization and will break this package
		[[ $(tc-arch) != "ppc64" ]] && NEW_CFLAGS="${NEW_CFLAGS} ${CFLAGS}"

		sed -i "${LINE}s:$CUR_CFLAGS:$NEW_CFLAGS:" Configure || die "sed failed"
	done
	IFS=$OLDIFS

	if [ "$(get_libdir)" != "lib" ] ; then
		# using a library directory other than lib requires some magic
		sed -i \
			-e "s+\(\$(INSTALL_PREFIX)\$(INSTALLTOP)\)/lib+\1/$(get_libdir)+g" \
			-e "s+libdir=\$\${exec_prefix}/lib+libdir=\$\${exec_prefix}/$(get_libdir)+g" \
			Makefile.org engines/Makefile \
			|| die "sed failed"
		./config --test-sanity || die "sanity failed"
	fi
}

src_compile() {
	# Clean out patent-or-otherwise-encumbered code.
	# MDC-2: 4,908,861 13/03/2007
	# IDEA:  5,214,703 25/05/2010
	# RC5:   5,724,428 03/03/2015
	# EC:    ????????? ??/??/2015
	local confopts=""
	use bindist && confopts="no-idea no-rc5 no-mdc2 -no-ec"

	use zlib && confopts="${confopts} zlib-dynamic"

	local sslout=$(./gentoo.config)
	einfo "Use configuration ${sslout}"

	local config="Configure"
	[[ -z ${sslout} ]] && config="config"
	./${config} \
		-DPLATFORM="Darwin" \
		-L${PREFIX}/lib -L${PREFIX}/usr/lib \
		${sslout} \
		${confopts} \
		--prefix=${PREFIX}/usr \
		--openssldir=${PREFIX}/etc/ssl \
		shared threads \
		|| die "Configure failed"

	emake \
		CC="$(tc-getCC)" MAKEDEPPROG="$(tc-getCC)" \
		AR="$(tc-getAR) r" \
		RANLIB="$(tc-getRANLIB)" \
		all || die "make all failed"

	# force until we get all the gentoo.config kinks worked out
	tc-is-cross-compiler || src_test
}

src_test() {
	# make sure sandbox doesnt die on *BSD
	#add_predict /dev/crypto
	#make test || die "make test failed"
	:
}

src_install() {
	make PLATFORM=Darwin INSTALL_PREFIX="${D}" MANDIR=/usr/share/man install || die
	dodoc CHANGES* FAQ NEWS README
	dodoc doc/*.txt
	dohtml doc/*

	if use emacs ; then
		insinto /usr/share/emacs/site-lisp
		doins doc/c-indentation.el
	fi

	# create the certs directory.  Previous openssl builds
	# would need to create /usr/lib/ssl/certs but this looks
	# to be the more FHS compliant setup... -raker
	insinto /etc/ssl/certs
	doins certs/*.pem
	LD_LIBRARY_PATH="${D}"/usr/$(get_libdir)/ \
	OPENSSL="${D}"/usr/bin/openssl /usr/bin/perl tools/c_rehash \
		"${D}"/etc/ssl/certs

	# These man pages with other packages so rename them
	cd "${D}"/usr/share/man
	for m in man1/passwd.1 man3/rand.3 man3/err.3 ; do
		d=${m%%/*} ; m=${m##*/}
		mv -f ${d}/{,ssl-}${m}
		ln -snf ssl-${m} ${d}/openssl-${m}
	done

	fperms a+x /usr/$(get_libdir)/pkgconfig #34088
}

pkg_preinst() {
	if [[ -e ${ROOT}/usr/$(get_libdir)/libcrypto.so.0.9.7 ]] ; then
		cp -pPR "${ROOT}"/usr/$(get_libdir)/lib{crypto,ssl}.so.0.9.7 "${IMAGE}"/usr/$(get_libdir)/
	fi
}

pkg_postinst() {
	local BN_H="${ROOT}$(gcc-config -L)/include/openssl/bn.h"
	# Breaks things one some boxen, bug #13795.  The problem is that
	# if we have a 'gcc fixed' version in $(gcc-config -L) from 0.9.6,
	# then breaks as it was defined as 'int BN_mod(...)' and in 0.9.7 it
	# is a define with BN_div(...) - <azarah@gentoo.org> (24 Sep 2003)
	if [ -f "${BN_H}" ] && [ -n "$(grep '^int[[:space:]]*BN_mod(' "${BN_H}")" ]
	then
		rm -f "${BN_H}"
	fi

	if [[ -e ${ROOT}/usr/$(get_libdir)/libcrypto.so.0.9.7 ]] ; then
		ewarn "You must re-compile all packages that are linked against"
		ewarn "OpenSSL 0.9.7 by using revdep-rebuild from gentoolkit:"
		ewarn "# revdep-rebuild --soname libssl.so.0.9.7"
		ewarn "# revdep-rebuild --soname libcrypto.so.0.9.7"
		ewarn "After this, you can delete /usr/$(get_libdir)/libssl.so.0.9.7"
		ewarn "and /usr/$(get_libdir)/libcrypto.so.0.9.7"
	fi
}
