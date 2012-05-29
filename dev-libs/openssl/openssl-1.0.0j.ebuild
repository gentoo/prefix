# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/openssl/openssl-1.0.0j.ebuild,v 1.9 2012/05/25 17:41:49 vapier Exp $

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs multilib

REV="1.7"
DESCRIPTION="full-strength general purpose cryptography library (including SSL v2/v3 and TLS v1)"
HOMEPAGE="http://www.openssl.org/"
SRC_URI="mirror://openssl/source/${P}.tar.gz
	http://cvs.pld-linux.org/cgi-bin/cvsweb.cgi/~checkout~/packages/${PN}/${PN}-c_rehash.sh?rev=${REV} -> ${PN}-c_rehash.sh.${REV}"

LICENSE="openssl"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="bindist gmp kerberos rfc3779 sse2 static-libs test zlib"

# Have the sub-libs in RDEPEND with [static-libs] since, logically,
# our libssl.a depends on libz.a/etc... at runtime.
LIB_DEPEND="gmp? ( dev-libs/gmp[static-libs(+)] )
	zlib? ( sys-libs/zlib[static-libs(+)] )
	kerberos? ( app-crypt/mit-krb5 )"
RDEPEND="static-libs? ( ${LIB_DEPEND} )
	!static-libs? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	sys-apps/diffutils
	>=dev-lang/perl-5
	test? ( sys-devel/bc )"

PDEPEND="app-misc/ca-certificates"

src_unpack() {
	unpack ${P}.tar.gz
	SSL_CNF_DIR="/etc/ssl"
	sed \
		-e "/^DIR=/s:=.*:=${EPREFIX}${SSL_CNF_DIR}:" \
		"${DISTDIR}"/${PN}-c_rehash.sh.${REV} \
		> "${WORKDIR}"/c_rehash || die #416717
}

src_prepare() {
	# Make sure we only ever touch Makefile.org and avoid patching a file
	# that gets blown away anyways by the Configure script in src_configure
	rm -f Makefile

	epatch "${FILESDIR}"/${PN}-1.0.0a-ldflags.patch #327421
	epatch "${FILESDIR}"/${PN}-1.0.0d-fbsd-amd64.patch #363089
	epatch "${FILESDIR}"/${PN}-1.0.0d-windres.patch #373743
	epatch "${FILESDIR}"/${PN}-1.0.0h-pkg-config.patch
	epatch "${FILESDIR}"/${PN}-1.0.0e-parallel-build.patch
	epatch "${FILESDIR}"/${PN}-1.0.0e-x32.patch
	epatch_user #332661

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
		Makefile.org \
		|| die
	# show the actual commands in the log
	sed -i '/^SET_X/s:=.*:=set -x:' Makefile.shared

	epatch "${FILESDIR}"/${PN}-0.9.8g-engines-installnames.patch
	epatch "${FILESDIR}"/${PN}-1.0.0a-interix.patch
	epatch "${FILESDIR}"/${PN}-1.0.0a-mint.patch
	epatch "${FILESDIR}"/${PN}-0.9.8l-aixso.patch #213277: with import files now
	epatch "${FILESDIR}"/${PN}-1.0.0b-darwin-bundle-compile-fix.patch
	if [[ ${CHOST} == *-interix* ]] ; then
		sed -i -e 's/-Wl,-soname=/-Wl,-h -Wl,/' Makefile.shared || die
	fi

	# again, this windows patch should not do any harm to others, but
	# header files are copied instead of linked now, so leave it conditional.
	[[ ${CHOST} == *-winnt* ]] && epatch "${FILESDIR}"/${PN}-0.9.8k-winnt.patch

	# remove -arch for darwin
	sed -i '/^"darwin/s,-arch [^ ]\+,,g' Configure || die

	# allow openssl to be cross-compiled
	cp "${FILESDIR}"/gentoo.config-1.0.0 gentoo.config || die
	chmod a+rx gentoo.config

	append-flags -fno-strict-aliasing
	append-flags $(test-flags-CC -Wa,--noexecstack)

	# type -P required on platforms where perl is not installed
	# in the same prefix (prefix-chaining).
	sed -i '1s,^:$,#!'"$(type -P perl)"',' Configure || die #141906
	sed -i '1s/perl5/perl/' tools/c_rehash || die #308455

	# fixup c_rehash script, bug #350601
	sed -i \
		-e "s:DIR=/etc:DIR=${EPREFIX}/etc:" \
		-e "s:SSL_CMD=/usr:SSL_CMD=${EPREFIX}/usr:" \
		"${WORKDIR}"/c_rehash || die

	# avoid waiting on terminal input forever when spitting
	# 64bit warning message.
	[[ ${CHOST} == *-hpux* ]] && sed -i -e 's,stty,true,g' -e 's,read waste,true,g' config

	# Upstream insists that the GNU assembler fails, so insist on calling the
	# vendor assembler. However, I find otherwise. At least on Solaris-9
	# --darkside (26 Aug 2008)
	if [[ ${CHOST} == sparc-sun-solaris2.9 ]]; then
		sed -i -e "s:/usr/ccs/bin/::" crypto/bn/Makefile || die "sed failed"
	fi

	./config --test-sanity || die "I AM NOT SANE"
}

src_configure() {
	unset APPS #197996
	unset SCRIPTS #312551
	unset CROSS_COMPILE #311473

	tc-export CC AR RANLIB RC

	# Clean out patent-or-otherwise-encumbered code
	# Camellia: Royalty Free            http://en.wikipedia.org/wiki/Camellia_(cipher)
	# IDEA:     Expired                 http://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm
	# EC:       ????????? ??/??/2015    http://en.wikipedia.org/wiki/Elliptic_Curve_Cryptography
	# MDC2:     Expired                 http://en.wikipedia.org/wiki/MDC-2
	# RC5:      5,724,428 03/03/2015    http://en.wikipedia.org/wiki/RC5

	use_ssl() { usex $1 "enable-${2:-$1}" "no-${2:-$1}" " ${*:3}" ; }
	echoit() { echo "$@" ; "$@" ; }

	local krb5=$(has_version app-crypt/mit-krb5 && echo "MIT" || echo "Heimdal")

	case $CHOST in
		sparc*-sun-solaris*)
			# openssl doesn't grok this setup, and guesses
			# the architecture wrong causing segfaults,
			# just disable asm for now
			# FIXME: I need to report this upstream
			confopts="${confopts} no-asm"
		;;
		*-aix*)
			# symbols in asm file aren't exported for yet unknown reason
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
		enable-idea \
		enable-mdc2 \
		$(use_ssl !bindist rc5) \
		enable-tlsext \
		$(use_ssl gmp gmp -lgmp) \
		$(use_ssl kerberos krb5 --with-krb5-flavor=${krb5}) \
		$(use_ssl rfc3779) \
		$(use_ssl zlib) \
		--prefix="${EPREFIX}"/usr \
		--openssldir="${EPREFIX}"${SSL_CNF_DIR} \
		--libdir=$(get_libdir) \
		shared threads ${confopts} \
		|| die

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
		-e "/^CFLAG/s|=.*|=${CFLAG} ${CFLAGS}|" \
		-e "/^SHARED_LDFLAGS=/s|$| ${LDFLAGS}|" \
		Makefile || die
}

src_compile() {
	if [[ ${CHOST} == *-winnt* ]]; then
		( cd fips && emake -j1 links PERL=$(type -P perl) ) || die "make links in fips failed"
	fi

	# depend is needed to use $confopts; it also doesn't matter
	# that it's -j1 as the code itself serializes subdirs
	emake -j1 depend || die
	emake all || die
	# rehash is needed to prep the certs/ dir; do this
	# separately to avoid parallel build issues.
	emake rehash || die
}

src_test() {
	emake -j1 test || die
}

src_install() {
	emake INSTALL_PREFIX="${D}" install || die
	dobin "${WORKDIR}"/c_rehash || die #333117
	dodoc CHANGES* FAQ NEWS README doc/*.txt doc/c-indentation.el
	dohtml -r doc/*
	use rfc3779 && dodoc engines/ccgost/README.gost

	# This is crappy in that the static archives are still built even
	# when USE=static-libs.  But this is due to a failing in the openssl
	# build system: the static archives are built as PIC all the time.
	# Only way around this would be to manually configure+compile openssl
	# twice; once with shared lib support enabled and once without.
	use static-libs || rm -f "${ED}"/usr/lib*/lib*.a

	# create the certs directory
	dodir ${SSL_CNF_DIR}/certs
	cp -RP certs/* "${ED}"${SSL_CNF_DIR}/certs/ || die
	rm -r "${ED}"${SSL_CNF_DIR}/certs/{demo,expired}

	# Namespace openssl programs to prevent conflicts with other man pages
	cd "${ED}"/usr/share/man
	local m d s
	for m in $(find . -type f | xargs grep -L '#include') ; do
		d=${m%/*} ; d=${d#./} ; m=${m##*/}
		[[ ${m} == openssl.1* ]] && continue
		[[ -n $(find -L ${d} -type l) ]] && die "erp, broken links already!"
		mv ${d}/{,ssl-}${m}
		# fix up references to renamed man pages
		sed -i '/^[.]SH "SEE ALSO"/,/^[.]/s:\([^(, ]*(1)\):ssl-\1:g' ${d}/ssl-${m}
		ln -s ssl-${m} ${d}/openssl-${m}
		# locate any symlinks that point to this man page ... we assume
		# that any broken links are due to the above renaming
		for s in $(find -L ${d} -type l) ; do
			s=${s##*/}
			rm -f ${d}/${s}
			ln -s ssl-${m} ${d}/ssl-${s}
			ln -s ssl-${s} ${d}/openssl-${s}
		done
	done
	[[ -n $(find -L ${d} -type l) ]] && die "broken manpage links found :("

	dodir /etc/sandbox.d #254521
	echo 'SANDBOX_PREDICT="/dev/crypto"' > "${ED}"/etc/sandbox.d/10openssl

	diropts -m0700
	keepdir ${SSL_CNF_DIR}/private
}

pkg_preinst() {
	has_version ${CATEGORY}/${PN}:0.9.8 && return 0
	preserve_old_lib /usr/$(get_libdir)/lib{crypto,ssl}$(get_libname 0.9.8)
}

pkg_postinst() {
	ebegin "Running 'c_rehash ${EROOT%/}${SSL_CNF_DIR}/certs/' to rebuild hashes #333069"
	c_rehash "${EROOT%/}${SSL_CNF_DIR}/certs" >/dev/null
	eend $?

	has_version ${CATEGORY}/${PN}:0.9.8 && return 0
	preserve_old_lib_notify /usr/$(get_libdir)/lib{crypto,ssl}$(get_libname 0.9.8)
}
