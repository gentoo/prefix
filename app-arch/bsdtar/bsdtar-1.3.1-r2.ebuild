# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bsdtar/bsdtar-1.3.1-r2.ebuild,v 1.2 2006/11/11 12:42:57 blubb Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils autotools toolchain-funcs flag-o-matic

MY_P="libarchive-${PV}"

DESCRIPTION="BSD tar command"
HOMEPAGE="http://people.freebsd.org/~kientzle/libarchive/"
SRC_URI="http://people.freebsd.org/~kientzle/libarchive/src/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="build static acl xattr"

RDEPEND="!dev-libs/libarchive
	kernel_linux? (
		acl? ( sys-apps/acl )
		xattr? ( sys-apps/attr )
	)
	!static? ( !build? (
		app-arch/bzip2
		sys-libs/zlib ) )"
DEPEND="${RDEPEND}
	kernel_linux? ( sys-fs/e2fsprogs
		virtual/os-headers )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/libarchive-1.3.1-static.patch
	epatch "${FILESDIR}"/libarchive-1.2.57-acl.patch
	epatch "${FILESDIR}"/libarchive-1.2.53-strict-aliasing.patch
	epatch "${FILESDIR}"/libarchive-1.3.1-infiniteloop.patch

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

	econf \
		--bindir="${EPREFIX}"/bin \
		$(use_enable acl) \
		$(use_enable xattr) \
		${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	# Create tar symlink for FreeBSD
	if [[ ${CHOST} == *-freebsd* ]]; then
		dosym bsdtar /bin/tar
		dosym bsdtar.1.gz /usr/share/man/man1/tar.1.gz
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
