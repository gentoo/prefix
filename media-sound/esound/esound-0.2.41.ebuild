# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/esound/esound-0.2.41.ebuild,v 1.10 2009/06/01 16:41:29 ssuominen Exp $

EAPI=2
inherit libtool gnome.org eutils flag-o-matic

DESCRIPTION="The Enlightened Sound Daemon"
HOMEPAGE="http://www.tux.org/~ricdude/EsounD.html"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="alsa debug doc ipv6 oss static-libs tcpd"

COMMON_DEPEND=">=media-libs/audiofile-0.2.3
	alsa? ( media-libs/alsa-lib )
	doc?  ( app-text/docbook-sgml-utils )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6-r2 )"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	app-admin/eselect-esd"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.2.39-fix-errno.patch" \
		"${FILESDIR}/${P}-debug.patch"

	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-0.2.38-interix3.patch
}

src_configure() {
	# Strict aliasing issues
	append-flags -fno-strict-aliasing

	local myconf

	if ! use alsa; then
		myconf="--enable-oss"
	else
		myconf="$(use_enable oss)"
	fi

	# Interix does not have access to windows sound devices.
	# Instead, one would need to run esound on windows natively.
	[[ ${CHOST} == *-interix* ]] && myconf="${myconf} --disable-local-sound"

	econf \
		--sysconfdir="${EPREFIX}"/etc/esd \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable ipv6) \
		$(use_enable debug debugging) \
		$(use_enable alsa) \
		--disable-arts \
		--disable-artstest \
		$(use_with tcpd libwrap) \
		${myconf}
}

src_install() {
	emake -j1 DESTDIR="${D}" install  || die "emake install failed"
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
