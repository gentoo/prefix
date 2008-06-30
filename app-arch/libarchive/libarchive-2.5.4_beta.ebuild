# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/libarchive/libarchive-2.5.4_beta.ebuild,v 1.1 2008/05/26 12:17:19 flameeyes Exp $

EAPI="prefix"

MY_P="${P/_beta/b}"

inherit eutils libtool toolchain-funcs

DESCRIPTION="BSD tar command"
HOMEPAGE="http://people.freebsd.org/~kientzle/libarchive"
SRC_URI="http://people.freebsd.org/~kientzle/libarchive/src/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc64-solaris ~x86-solaris"
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

	epatch "${FILESDIR}/${MY_P}-glibc.patch"

	elibtoolize
	epunt_cxx
}

src_compile() {
	local myconf

	if ! use static && ! use build ; then
		myconf="--enable-bsdtar=shared --enable-bsdcpio=shared"
	fi

	econf --bindir="${EPREFIX}"/bin \
		--enable-bsdtar --enable-bsdcpio \
		$(use_enable acl) $(use_enable xattr) \
		${myconf} \
		--disable-dependency-tracking || die "econf failed."

	emake || die "emake failed."
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."

	# Create tar symlink for FreeBSD
	if [[ ${CHOST} == *-freebsd* ]]; then
		dosym bsdtar /bin/tar
		dosym bsdtar.1 /usr/share/man/man1/tar.1
		# We may wish to switch to symlink bsdcpio to cpio too one day
	fi

	dodoc NEWS README

	if use build; then
		rm -rf "${ED}"/usr
		rm -rf "${ED}"/lib/*.so*
		return 0
	fi

	# just don't do this for Darwin
	if [[ ${CHOST} != *-darwin* ]]; then
		dodir /$(get_libdir)
		mv "${ED}"/usr/$(get_libdir)/*.so* "${ED}"/$(get_libdir)
		gen_usr_ldscript libarchive.so
	fi
}
