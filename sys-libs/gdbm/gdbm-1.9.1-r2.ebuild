# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gdbm/gdbm-1.9.1-r2.ebuild,v 1.3 2011/12/07 20:32:55 zmedico Exp $

EAPI="3"

inherit eutils libtool flag-o-matic multilib autotools

EX_P="${PN}-1.8.3"
DESCRIPTION="Standard GNU database libraries"
HOMEPAGE="http://www.gnu.org/software/gdbm/"
SRC_URI="mirror://gnu/gdbm/${P}.tar.gz
	exporter? ( mirror://gnu/gdbm/${EX_P}.tar.gz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+berkdb exporter static-libs"

EX_S="${WORKDIR}"/${EX_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-compat-link.patch #383743
	elibtoolize
	#rm aclocal.m4
	#epatch "${FILESDIR}"/${P}-fix-compat-linking.patch #377421
	#eautoreconf # we need this for #377421, next to the patch
}

src_configure() {
	# gdbm doesn't appear to use either of these libraries
	export ac_cv_lib_dbm_main=no ac_cv_lib_ndbm_main=no

	if use exporter ; then
		pushd "${EX_S}" >/dev/null
		append-lfs-flags
		econf --disable-shared
		popd >/dev/null
	fi

	#[[ ${CHOST} == x86_64-pc-freebsd* ]] && append-flags -fPIC #363583
	econf \
		--includedir="${EPREFIX}"/usr/include/gdbm \
		--with-gdbm183-libdir="${EX_S}/.libs" \
		--with-gdbm183-includedir="${EX_S}" \
		$(use_enable berkdb libgdbm-compat) \
		$(use_enable exporter gdbm-export) \
		$(use_enable static-libs static)
}

src_compile() {
	if use exporter ; then
		emake -C "${WORKDIR}"/${EX_P} libgdbm.la || die
	fi

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	use static-libs || find "${ED}" -name '*.la' -delete
	mv "${ED}"/usr/include/gdbm/gdbm.h "${ED}"/usr/include/ || die
	dodoc ChangeLog NEWS README
}

pkg_preinst() {
	preserve_old_lib libgdbm{,_compat}.so.{2,3} #32510
}

pkg_postinst() {
	preserve_old_lib_notify libgdbm{,_compat}.so.{2,3} #32510
}
