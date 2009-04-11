# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/esound/esound-0.2.38-r1.ebuild,v 1.10 2008/06/17 13:09:45 remi Exp $

WANT_AUTOMAKE=1.10
inherit libtool gnome.org eutils autotools flag-o-matic

DESCRIPTION="The Enlightened Sound Daemon"
HOMEPAGE="http://www.tux.org/~ricdude/EsounD.html"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="alsa debug doc ipv6 tcpd"

# esound comes with arts support, but it hasn't been tested yet, feel free to
# submit patches/improvements
COMMON_DEPEND=">=media-libs/audiofile-0.1.5
	alsa? ( >=media-libs/alsa-lib-0.5.10b )
	doc?  ( app-text/docbook-sgml-utils )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6-r2 )"
#	arts? ( kde-base/arts )

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	app-admin/eselect-esd"

src_unpack() {

	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-0.2.32-amd64.patch"

	epatch "${FILESDIR}/${PN}-0.2.36-mode_t.patch"
	epatch "${FILESDIR}/${PN}-0.2.38-as-needed.patch"
	epatch "${FILESDIR}/${PN}-0.2.38-doc.patch"
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch
	epatch "${FILESDIR}/${PN}-0.2.38-libtool-2.2.patch"

	eautoreconf
}

src_compile() {
	# Strict aliasing problem
	append-flags -fno-strict-aliasing

	local myconf=

	# Interix does not have access to windows sound devices.
	# Instead, one would need to run esound on windows natively.
	[[ ${CHOST} == *-interix* ]] && myconf="${myconf} --disable-local-sound"

	econf \
		--sysconfdir="${EPREFIX}"/etc/esd \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		$(use_enable ipv6) \
		$(use_enable debug debugging) \
		$(use_enable alsa) \
		$(use_with tcpd libwrap) \
		--disable-dependency-tracking \
		${myconf} \
		|| die "Configure failed"

	emake || die "Make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install  || die "Installation failed"
	mv "${ED}/usr/bin/"{esd,esound-esd}

	dodoc AUTHORS ChangeLog MAINTAINERS NEWS README TIPS TODO

	newconfd "${FILESDIR}/esound.conf.d" esound

	extradepend=""
	use tcpd && extradepend=" portmap"
	use alsa && extradepend="$extradepend alsasound"
	sed -e "s/@extradepend@/$extradepend/" "${FILESDIR}/esound.init.d.2" >"${T}/esound"
	doinitd "${T}/esound"
}

pkg_postinst() {
	eselect esd update --if-unset \
		|| die "eselect failed, try removing /usr/bin/esd and re-emerging."
}
