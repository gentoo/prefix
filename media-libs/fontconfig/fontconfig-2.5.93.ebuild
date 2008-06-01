# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.5.93.ebuild,v 1.2 2008/05/30 18:53:46 aballier Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.gz"

LICENSE="fontconfig"
SLOT="1.0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc xml"

RDEPEND=">=media-libs/freetype-2.1.4
	!xml? ( >=dev-libs/expat-1.95.3 )
	xml? ( >=dev-libs/libxml2-2.6 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-text/docbook-sgml-utils )"
PDEPEND="app-admin/eselect-fontconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epunt_cxx #74077
	# Neeeded to get a sane .so versionning on fbsd, please dont drop
	# If you have to run eautoreconf, you can also leave the elibtoolize call as
	# it will be a no-op.
	elibtoolize
}

src_compile() {
	# harvest some font locations, such that users can benefit from the
	# host OS's installed fonts
	case ${CHOST} in
		*-darwin*)
			addfonts=",/Library/Fonts,/System/Library/Fonts"
		;;
		*-solaris*)
			[[ -d /usr/X/lib/X11/fonts/TrueType ]] && \
				addfonts=",/usr/X/lib/X11/fonts/TrueType"
		;;
		*-linux-gnu)
			[[ -d /usr/share/fonts ]] && \
				addfonts=",/usr/share/fonts"
		;;
	esac

	econf $(use_enable doc docs) \
		--localstatedir="${EPREFIX}"/var \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-default-fonts="${EPREFIX}"/usr/share/fonts \
		--with-add-fonts="${EPREFIX}/usr/local/share/fonts${addfonts}" \
		$(use_enable xml libxml2) \
		|| die

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	insinto /etc/fonts
	doins "${S}"/fonts.conf

	doman $(find "${S}" -type f -name *.1 -print)
	newman doc/fonts-conf.5 fonts.conf.5
	dodoc doc/fontconfig-user.{txt,pdf}

	if use doc; then
		doman doc/Fc*.3
		dohtml doc/fontconfig-devel.html doc
		dodoc doc/fontconfig-devel.{txt,pdf}
	fi

	dodoc AUTHORS ChangeLog README

	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf, we force update it ...
	# <azarah@gentoo.org> (11 Dec 2002)
	echo 'CONFIG_PROTECT_MASK="/etc/fonts/fonts.conf"' > "${T}"/37fontconfig
	doenvd "${T}"/37fontconfig
}

pkg_postinst() {
	echo
	ewarn "Please make fontconfig configuration changes in ${EPREFIX}/etc/fonts/conf.d/"
	ewarn "and NOT to ${EPREFIX}/etc/fonts/fonts.conf, as it will be replaced!"
	echo

	if [[ ${ROOT} = / ]]; then
		ebegin "Creating global font cache..."
		"${EPREFIX}"/usr/bin/fc-cache -sr
		eend $?
	fi
}
