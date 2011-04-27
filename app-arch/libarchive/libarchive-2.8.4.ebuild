# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/libarchive/libarchive-2.8.4.ebuild,v 1.1 2010/08/11 08:48:08 ferringb Exp $

EAPI="2"

inherit eutils libtool toolchain-funcs flag-o-matic autotools

DESCRIPTION="BSD tar command"
HOMEPAGE="http://code.google.com/p/libarchive/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz
	http://people.freebsd.org/~kientzle/libarchive/src/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc64-solaris ~x86-solaris"
IUSE="static static-libs acl xattr kernel_linux +bzip2 +lzma +zlib"

COMPRESS_LIBS_DEPEND="lzma? ( app-arch/xz-utils )
		bzip2? ( app-arch/bzip2 )
		zlib? ( sys-libs/zlib )"

RDEPEND="!dev-libs/libarchive
	dev-libs/openssl
	acl? ( virtual/acl )
	xattr? ( kernel_linux? ( sys-apps/attr ) )
	!static? ( ${COMPRESS_LIBS_DEPEND} )"
DEPEND="${RDEPEND}
	${COMPRESS_LIBS_DEPEND}
	kernel_linux? ( sys-fs/e2fsprogs
		virtual/os-headers )"

src_prepare() {
	# for FreeMiNT
	eautoreconf
	elibtoolize
	epunt_cxx
}

src_configure() {
	local myconf

	if ! use static ; then
		myconf="--enable-bsdtar=shared --enable-bsdcpio=shared"
	fi

	# force static libs for static binaries
	if use static && ! use static-libs; then
		myconf="${myconf} --enable-static"
	fi

	# Check for need of this in 2.7.1 and later, on 2.7.0, -Werror was
	# added to the final release, but since it's done in the
	# Makefile.am we can just work it around this way.
	append-flags -Wno-error

	# for getpwnam_r usage
	[[ ${CHOST} == *-solaris* ]] && append-flags -D_POSIX_PTHREAD_SEMANTICS

	# We disable lzmadec because we support the newer liblzma from xz-utils
	# and not liblzmadec with this version.
	econf --bindir="${EPREFIX}"/bin \
		--enable-bsdtar --enable-bsdcpio \
		$(use_enable acl) $(use_enable xattr) \
		$(use_with zlib) \
		$(use_with bzip2 bz2lib) $(use_with lzma) \
		$(use_enable static-libs static) \
		--without-lzmadec \
		${myconf} \
		--disable-dependency-tracking || die "econf failed."
}

src_test() {
	# Replace the default src_test so that it builds tests in parallel
	emake check || die "tests failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	# remove useless .a and .la files (only for non static compilation)
	use static-libs || find "${ED}" \( -name '*.a' -or -name '*.la' \) -delete

	# Create tar symlink for FreeBSD
	if ! use prefix && [[ ${CHOST} == *-freebsd* ]]; then
		dosym bsdtar /bin/tar
		dosym bsdtar.1 /usr/share/man/man1/tar.1
		# We may wish to switch to symlink bsdcpio to cpio too one day
	fi

	dodoc NEWS README
	gen_usr_ldscript -a archive
}
