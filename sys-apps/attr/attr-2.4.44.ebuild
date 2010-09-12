# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/attr/attr-2.4.44.ebuild,v 1.1 2010/06/08 21:43:04 vapier Exp $

EAPI="2"

inherit eutils toolchain-funcs autotools

DESCRIPTION="Extended attributes tools"
HOMEPAGE="http://savannah.nongnu.org/projects/attr"
SRC_URI="mirror://nongnu/${PN}/${P}.src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )
	sys-devel/autoconf"
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.4.44-gettext.patch
	epatch "${FILESDIR}"/${P}-headers.patch
	epatch "${FILESDIR}"/${PN}-2.4.41-no-static-paths.patch
	epatch "${FILESDIR}"/${PN}-2.4.41-features_h.patch
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	# libtool will clobber install-sh which is really a custom file
	mv install-sh acl.install-sh || die
	AT_M4DIR="m4" eautoreconf
	mv acl.install-sh install-sh || die
	strip-linguas po

	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/__THROW//g' include/xattr.h
		sed -i -e '/^LTLDFLAGS/d' libattr/Makefile
		append-flags -fno-strict-aliasing
		append-libs -lintl
	fi
}

src_configure() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir) \
		--bindir="${EPREFIX}"/bin
}

src_install() {
	emake DIST_ROOT="${D}" install install-lib install-dev || die
	# the man-pages packages provides the man2 files
	rm -r "${ED}"/usr/share/man/man2

	# we install attr into /bin, so we need the shared lib with it
	gen_usr_ldscript -a attr
}
