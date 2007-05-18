# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gkrellm/gkrellm-2.2.10.ebuild,v 1.9 2007/05/14 16:31:13 armin76 Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs

DESCRIPTION="Single process stack of various system monitors"
HOMEPAGE="http://www.gkrellm.net/"
SRC_URI="http://members.dslextreme.com/users/billw/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="gnutls lm_sensors nls ssl X"

RDEPEND=">=dev-libs/glib-2
	gnutls? ( net-libs/gnutls )
	lm_sensors? ( sys-apps/lm_sensors )
	nls? ( virtual/libintl )
	ssl? ( dev-libs/openssl )
	X? ( >=x11-libs/gtk+-2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"

pkg_setup() {
	enewgroup gkrellmd
	enewuser gkrellmd -1 -1 -1 gkrellmd
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-build.patch
	if use gnutls ; then
		epatch "${FILESDIR}"/${P}-gnutls.patch
	fi

	sed -e 's:#user\tnobody:user\tgkrellmd:' \
		-e 's:#group\tproc:group\tgkrellmd:' \
		-i server/gkrellmd.conf || die "sed gkrellmd.conf failed"

	sed -e "s:/usr/lib:${EPREFIX}/usr/$(get_libdir):" \
		-e "s:/usr/local/lib:${EPREFIX}/usr/local/$(get_libdir):" \
		-i src/${PN}.h || die "sed ${PN}.h failed"
}

src_compile() {
	if use X ; then
		emake \
			CC=$(tc-getCC) \
			INSTALLROOT="${EPREFIX}"/usr \
			INCLUDEDIR="${EPREFIX}"/usr/include/gkrellm2 \
			$(use nls && echo enable_nls=1) \
			$(use gnutls || echo without-gnutls=yes) \
			$(use lm_sensors || echo without-libsensors=yes) \
			$(use ssl || echo without-ssl=yes) \
			|| die "emake failed"
	else
		cd server
		emake \
			CC=$(tc-getCC) \
			$(use lm_sensors || echo without-libsensors=yes) \
			|| die "emake failed"
	fi
}

src_install() {
	if use X ; then
		emake install \
			$(use nls || echo enable_nls=0) \
			INSTALLDIR="${ED}"/usr/bin \
			INCLUDEDIR="${ED}"/usr/include \
			LOCALEDIR="${ED}"/usr/share/locale \
			PKGCONFIGDIR="${ED}"/usr/$(get_libdir)/pkgconfig \
			|| die "emake install failed"

		mv "${ED}"/usr/bin/{${PN},gkrellm2}

		dohtml *.html
		newman ${PN}.1 gkrellm2.1

		newicon src/icon.xpm ${PN}.xpm
		make_desktop_entry gkrellm2 GKrellM ${PN}.xpm
	else
		dobin server/gkrellmd || die "dobin failed"

		insinto /usr/include/gkrellm2
		doins server/gkrellmd.h || die "doins failed"
	fi

	doinitd "${FILESDIR}"/gkrellmd || die "doinitd failed"

	insinto /etc
	doins server/gkrellmd.conf || die "doins failed"

	doman gkrellmd.1
	dodoc Changelog CREDITS README
}
