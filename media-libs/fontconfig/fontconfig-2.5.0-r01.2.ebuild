# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.5.0-r1.ebuild,v 1.10 2008/05/04 13:27:41 pva Exp $

inherit eutils libtool autotools

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.gz"

LICENSE="fontconfig"
SLOT="1.0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
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
	# add docbook switch so we can disable it
	epatch "${FILESDIR}"/${PN}-2.3.2-docbook.patch
	epatch "${FILESDIR}"/${P}-libtool-2.2.patch #213831 Fix libtool-2.2 brekage

	eautoreconf
	epunt_cxx #74077
}

src_compile() {
	# I'm thinking this should be removed
	[[ ${ARCH} == alpha && ${CC} == ccc ]] && \
		die "Dont compile fontconfig with ccc, it doesnt work very well"

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

	# disable docs only disables local docs generation, they come with the tarball
	econf $(use_enable doc docs) \
		$(use_enable doc docbook) \
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

	newman doc/fonts-conf.5 fonts.conf.5
	dohtml doc/fontconfig-user.html
	dodoc doc/fontconfig-user.{txt,pdf}

	if use doc; then
		doman doc/Fc*.3
		dohtml doc/fontconfig-devel.html doc
		dohtml -r doc/fontconfig-devel
		dodoc doc/fontconfig-devel.{txt,pdf}
	fi

	dodoc AUTHORS ChangeLog NEWS README

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
