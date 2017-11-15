# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# XXX: atm, libbz2.a is always PIC :(, so it is always built quickly
#      (since we're building shared libs) ...

EAPI=5

inherit eutils toolchain-funcs multilib multilib-minimal prefix

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"
SRC_URI="http://www.bzip.org/${PV}/${P}.tar.gz"

LICENSE="BZIP2"
SLOT="0/1" # subslot = SONAME
KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="static static-libs"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.4-makefile-CFLAGS.patch
	"${FILESDIR}"/${PN}-1.0.6-saneso.patch
	"${FILESDIR}"/${PN}-1.0.4-man-links.patch #172986
	"${FILESDIR}"/${PN}-1.0.6-progress.patch
	"${FILESDIR}"/${PN}-1.0.3-no-test.patch
	"${FILESDIR}"/${PN}-1.0.4-POSIX-shell.patch #193365
	"${FILESDIR}"/${PN}-1.0.6-mingw.patch #393573
	"${FILESDIR}"/${PN}-1.0.6-out-of-tree-build.patch
	"${FILESDIR}"/${PN}-1.0.6-CVE-2016-3189.patch #620466

	"${FILESDIR}"/${PN}-1.0.6-r7-checkenv.patch # for AIX, Darwin?
	"${FILESDIR}"/${PN}-1.0.6-prefix.patch
)

src_prepare() {
	epatch "${PATCHES[@]}"

	# - Use right man path
	# - Generate symlinks instead of hardlinks
	# - pass custom variables to control libdir
	sed -i \
		-e 's:\$(PREFIX)/man:\$(PREFIX)/share/man:g' \
		-e 's:ln -s -f $(PREFIX)/bin/:ln -s -f :' \
		-e 's:$(PREFIX)/lib:$(PREFIX)/$(LIBDIR):g' \
		Makefile || die

	eprefixify bz{diff,grep,more}
	# this a makefile for Darwin, which already "includes" saneso
	cp "${FILESDIR}"/${P}-Makefile-libbz2_dylib Makefile-libbz2_dylib || die

	if [[ ${CHOST} == *-hpux* ]] ; then
		sed -i -e 's,-soname,+h,' Makefile-libbz2_so || die "cannot replace -soname with +h"
		if [[ ${CHOST} == hppa*-hpux* && ${CHOST} != hppa64*-hpux* ]] ; then
			sed -i -e '/^SOEXT/s,so,sl,' Makefile-libbz2_so || die "cannot replace so with sl"
			sed -i -e '/^SONAME/s,=,=${EPREFIX}/lib/,' Makefile-libbz2_so || die "cannt set soname"
		fi
	fi
	if [[ ${CHOST} == *-cygwin* ]] ; then
		sed -i -e "s/-o libbz2\.so\.${PV}/-Wl,--out-implib=libbz2$(get_libname ${PV})/" \
			   -e "s/-Wl,-soname -Wl,libbz2\.so\.1/-o cygbz2-${PV%%.*}.dll/" \
			   -e "s/libbz2\.so/libbz2$(get_libname)/g" \
			Makefile-libbz2_so
	fi
}

bemake() {
	emake \
		VPATH="${S}" \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		"$@"
}

multilib_src_compile() {
	bemake -f "${S}"/Makefile-libbz2_so all
	# Make sure we link against the shared lib #504648
	ln -sf libbz2.so.${PV} libbz2.so
	bemake -f "${S}"/Makefile all LDFLAGS="${LDFLAGS} $(usex static -static '')"
}

multilib_src_install() {
	into /usr

	if ! tc-is-static-only; then

	# Install the shared lib manually.  We install:
	#  .x.x.x - standard shared lib behavior
	#  .x.x   - SONAME some distros use #338321
	#  .x     - SONAME Gentoo uses
	dolib.so libbz2$(get_libname ${PV})
	[[ ${CHOST} == *-cygwin* ]] && dobin cygbz2-${PV%%.*}.dll
	local v
	[[ $(get_libname) != $(get_libname ${PV}) ]] &&
	for v in libbz2$(get_libname) libbz2$(get_libname ${PV%%.*}) libbz2$(get_libname ${PV%.*}) ; do
		dosym libbz2$(get_libname ${PV}) /usr/$(get_libdir)/${v}
	done

	fi  # tc-is-static-only

	use static-libs && dolib.a libbz2.a

	if multilib_is_native_abi ; then
		gen_usr_ldscript -a bz2

		dobin bzip2recover
		into /
		dobin bzip2
	fi
}

multilib_src_install_all() {
	# `make install` doesn't cope with out-of-tree builds, nor with
	# installing just non-binaries, so handle things ourselves.
	insinto /usr/include
	doins bzlib.h
	into /usr
	dobin bz{diff,grep,more}
	doman *.1

	dosym bzdiff /usr/bin/bzcmp
	dosym bzdiff.1 /usr/share/man/man1/bzcmp.1

	dosym bzmore /usr/bin/bzless
	dosym bzmore.1 /usr/share/man/man1/bzless.1

	local x
	for x in bunzip2 bzcat bzip2recover ; do
		dosym bzip2.1 /usr/share/man/man1/${x}.1
	done
	for x in bz{e,f}grep ; do
		dosym bzgrep /usr/bin/${x}
		dosym bzgrep.1 /usr/share/man/man1/${x}.1
	done

	dodoc README* CHANGES manual.pdf
	dohtml manual.html

	# move "important" bzip2 binaries to /bin and use the shared libbz2.so
	dosym bzip2 /bin/bzcat
	dosym bzip2 /bin/bunzip2
}
