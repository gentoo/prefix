# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/openssl/openssl-0.9.8o-r2.ebuild,v 1.2 2010/09/28 11:02:13 ssuominen Exp $

# this ebuild is only for the libcrypto.so.0.9.8 and libssl.so.0.9.8 SONAME for ABI compat

EAPI=1
inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Toolkit for SSL v2/v3 and TLS v1"
HOMEPAGE="http://www.openssl.org/"
SRC_URI="mirror://openssl/source/${P}.tar.gz"

LICENSE="openssl"
SLOT="0.9.8"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="bindist gmp kerberos sse2 test zlib"

RDEPEND="gmp? ( dev-libs/gmp )
	zlib? ( sys-libs/zlib )
	kerberos? ( app-crypt/mit-krb5 )
	!=dev-libs/openssl-0.9.8*:0"
DEPEND="${RDEPEND}
	sys-apps/diffutils
	>=dev-lang/perl-5
	test? ( sys-devel/bc )"

pkg_setup() {
	[[ -e ${EROOT}/usr/$(get_libdir)/libcrypto.so.0.9.8 ]] && \
		rm -f "${EROOT}"/usr/$(get_libdir)/libcrypto.so.0.9.8
	[[ -e ${EROOT}/usr/$(get_libdir)/libssl.so.0.9.8 ]] && \
		rm -f "${EROOT}"/usr/$(get_libdir)/libssl.so.0.9.8
}

src_unpack() {
	unpack ${A}
	cd "${S}"

# this patch kills Darwin, but seems not necessary on Solaris and Linux
#	epatch "${FILESDIR}"/${PN}-0.9.7e-gentoo.patch
	epatch "${FILESDIR}"/${PN}-0.9.8e-bsd-sparc64.patch
	epatch "${FILESDIR}"/${PN}-0.9.8h-ldflags.patch #181438
	epatch "${FILESDIR}"/${PN}-0.9.8m-binutils.patch #289130
	epatch "${FILESDIR}"/${PN}-1.0.0a-fix-double-free.patch #332027

	# disable fips in the build
	# make sure the man pages are suffixed #302165
	# don't bother building man pages if they're disabled
	sed -i \
		-e '/DIRS/s: fips : :g' \
		-e '/^MANSUFFIX/s:=.*:=ssl:' \
		-e '/^MAKEDEPPROG/s:=.*:=$(CC):' \
		-e $(has noman FEATURES \
			&& echo '/^install:/s:install_docs::' \
			|| echo '/^MANDIR=/s:=.*:='"${EPREFIX}"'/usr/share/man:') \
		Makefile{,.org} \
		|| die
	# show the actual commands in the log
	sed -i '/^SET_X/s:=.*:=set -x:' Makefile.shared

	epatch "${FILESDIR}"/${PN}-0.9.8g-engines-installnames.patch
	epatch "${FILESDIR}"/${PN}-0.9.8n-interix.patch
	epatch "${FILESDIR}"/${PN}-0.9.8n-mint.patch
	epatch "${FILESDIR}"/${PN}-0.9.8l-aixso.patch #213277: with import files now
	if [[ ${CHOST} == *-interix* ]] ; then
		sed -i -e 's/-Wl,-soname=/-Wl,-h -Wl,/' Makefile.shared || die
	fi

	# again, this windows patch should not do any harm to others, but
	# header files are copied instead of linked now, so leave it conditional.
	[[ ${CHOST} == *-winnt* ]] && epatch "${FILESDIR}"/${PN}-0.9.8k-winnt.patch

	# remove -arch for darwin
	sed -i '/^"darwin/s,-arch [^ ]\+,,g' Configure

	# allow openssl to be cross-compiled
	cp "${FILESDIR}"/gentoo.config-0.9.8 gentoo.config || die "cp cross-compile failed"
	chmod a+rx gentoo.config

	append-flags -fno-strict-aliasing
	case $($(tc-getAS) --noexecstack -v 2>&1 </dev/null) in
		*"GNU Binutils"*) # GNU as with noexecstack support
			append-flags -Wa,--noexecstack
		;;
	esac


	# type -P required on platforms where perl is not installed
	# in the same prefix (prefix-chaining).
	sed -i '1s,^:$,#!'"$(type -P perl)"',' Configure #141906
	sed -i '/^"debug-steve/d' Configure # 0.9.8k shipped broken
	sed -i '1s/perl5/perl/' tools/c_rehash #308455

	# avoid waiting on terminal input forever when spitting
	# 64bit warning message.
	[[ ${CHOST} == *-hpux* ]] && sed -i -e 's,stty,true,g' -e 's,read waste,true,g' config

	# Upstream insists that the GNU assembler fails, so insist on calling the
	# vendor assembler. However, I find otherwise. At least on Solaris-9
	# --darkside (26 Aug 2008)
	if [[ ${CHOST} == sparc-sun-solaris2.9 ]]; then
		sed -i -e "s:/usr/ccs/bin/::" crypto/bn/Makefile || die "sed failed"
	fi

	if use gmp && [[ ${CHOST} == *-apple-darwin* ]] ; then
		append-ldflags -lgmp
	fi

	./config --test-sanity || die "I AM NOT SANE"
}

src_compile() {
	unset APPS #197996
	unset SCRIPTS #312551

	tc-export CC AR RANLIB

	# Clean out patent-or-otherwise-encumbered code
	# Camellia: Royalty Free            http://en.wikipedia.org/wiki/Camellia_(cipher)
	# IDEA:     5,214,703 25/05/2010    http://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm
	# EC:       ????????? ??/??/2015    http://en.wikipedia.org/wiki/Elliptic_Curve_Cryptography
	# MDC2:     Expired                 http://en.wikipedia.org/wiki/MDC-2
	# RC5:      5,724,428 03/03/2015    http://en.wikipedia.org/wiki/RC5

	use_ssl() { use $1 && echo "enable-${2:-$1} ${*:3}" || echo "no-${2:-$1}" ; }
	echoit() { echo "$@" ; "$@" ; }

	local krb5=$(has_version app-crypt/mit-krb5 && echo "MIT" || echo "Heimdal")

	case $CHOST in
		sparc-sun-solaris*)
			# openssl doesn't grok this setup, and guesses
			# the architecture wrong, just disable asm for now
			confopts="${confopts} no-asm"
		;;
	esac

	local sslout=$(./gentoo.config)
	einfo "Use configuration ${sslout:-(openssl knows best)}"
	local config="Configure"
	[[ -z ${sslout} ]] && config="config"
	echoit \
	./${config} \
		${sslout} \
		$(use sse2 || echo "no-sse2") \
		enable-camellia \
		$(use_ssl !bindist ec) \
		$(use_ssl !bindist idea) \
		enable-mdc2 \
		$(use_ssl !bindist rc5) \
		enable-tlsext \
		$(use_ssl gmp gmp -lgmp) \
		$(use_ssl kerberos krb5 --with-krb5-flavor=${krb5}) \
		$(use_ssl zlib) \
		--prefix="${EPREFIX}"/usr \
		--openssldir="${EPREFIX}"/etc/ssl \
		shared threads ${confopts} \
		|| die "Configure failed"

	if [[ ${CHOST} == i?86*-*-linux* || ${CHOST} == i?86*-*-freebsd* ]]; then
		# does not compile without optimization on x86-linux and x86-fbsd
		filter-flags -O0
		is-flagq -O* || append-flags -O1
	fi

	# Clean out hardcoded flags that openssl uses
	local CFLAG=$(grep ^CFLAG= Makefile | LC_ALL=C sed \
		-e 's:^CFLAG=::' \
		-e 's:-fomit-frame-pointer ::g' \
		-e 's:-O[0-9] ::g' \
		-e 's:-march=[-a-z0-9]* ::g' \
		-e 's:-mcpu=[-a-z0-9]* ::g' \
		-e 's:-m[a-z0-9]* ::g' \
	)
	# CFLAGS can contain : with e.g. MIPSpro
	sed -i \
		-e "/^LIBDIR=/s:=.*:=$(get_libdir):" \
		-e "/^CFLAG/s|=.*|=${CFLAG} ${CFLAGS}|" \
		-e "/^SHARED_LDFLAGS=/s|$| ${LDFLAGS}|" \
		Makefile || die

	if [[ ${CHOST} == *-winnt* ]]; then
		( cd fips && emake -j1 links PERL=$(type -P perl) ) || die "make links in fips failed"
	fi

	# depend is needed to use $confopts
	emake -j1 depend || die "depend failed"
	emake -j1 build_libs || die "make build_libs failed"
}

src_test() {
	emake -j1 test || die "make test failed"
}

src_install() {
	dolib.so lib{crypto,ssl}$(get_libname 0.9.8) || die
}
