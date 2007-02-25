# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bsdtar/bsdtar-2.0_beta11.ebuild,v 1.1 2007/02/11 19:19:10 flameeyes Exp $

EAPI="prefix"

inherit eutils autotools toolchain-funcs flag-o-matic

MY_P="libarchive-${PV/_beta/b}"

DESCRIPTION="BSD tar command"
HOMEPAGE="http://people.freebsd.org/~kientzle/libarchive/"
SRC_URI="http://people.freebsd.org/~kientzle/libarchive/src/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="build static acl xattr test"

RDEPEND="!dev-libs/libarchive
	kernel_linux? (
		acl? ( sys-apps/acl )
		xattr? ( sys-apps/attr )
	)
	!static? ( !build? (
		app-arch/bzip2
		sys-libs/zlib ) )"
DEPEND="${RDEPEND}
	test? ( virtual/pmake )
	kernel_linux? ( sys-fs/e2fsprogs
		virtual/os-headers )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/libarchive-1.3.1-static.patch
	epatch "${FILESDIR}"/libarchive-2.0b6-acl.patch
	epatch "${FILESDIR}"/libarchive-2.0b7-noacl.patch
	epatch "${FILESDIR}"/libarchive-2.0b11-tests.patch

	eautoreconf
	epunt_cxx
}

src_compile() {
	local myconf

	if use static || use build ; then
		myconf="${myconf} --enable-static-bsdtar"
	else
		myconf="${myconf} --disable-static-bsdtar"
	fi

	# Upstream doesn't seem to care to fix the problems
	# and I don't want to continue running after them.
	append-flags -fno-strict-aliasing

	econf \
		--bindir="${EPREFIX}"/bin \
		$(use_enable acl) \
		$(use_enable xattr) \
		${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_test() {
	cd "${S}/libarchive/test"
	$(get_bmake) || einfo "Ignore this failure."
	$(get_bmake) test || die "$(get_bmake) test failed"

	cd "${S}/tar/test"
	PATH="${S}:${PATH}" $(get_bmake) test || die "$(get_bmake) test failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	# Create tar symlink for FreeBSD
	if [[ ${CHOST} == *-freebsd* ]]; then
		dosym bsdtar /bin/tar
		dosym bsdtar.1 /usr/share/man/man1/tar.1
	fi

	if use build; then
		rm -rf "${ED}"/usr
		rm -rf "${ED}"/lib/*.so*
		return 0
	fi

	if [[ ${USERLAND} != "Darwin" ]]; then
		dodir /$(get_libdir)
		mv "${ED}"/usr/$(get_libdir)/*.so* "${ED}"/$(get_libdir)
		gen_usr_ldscript libarchive.so
	fi
}
