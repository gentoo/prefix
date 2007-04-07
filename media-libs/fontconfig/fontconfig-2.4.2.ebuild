# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.4.2.ebuild,v 1.9 2007/02/13 10:58:53 corsair Exp $

EAPI="prefix"

inherit eutils libtool autotools

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.gz"

LICENSE="fontconfig"
SLOT="1.0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="doc xml"

RDEPEND=">=media-libs/freetype-2.1.4
	!xml? ( >=dev-libs/expat-1.95.3 )
	xml? ( >=dev-libs/libxml2-2.6 )"
DEPEND="${RDEPEND}
	doc? ( app-text/docbook-sgml-utils )"

src_unpack() {
	unpack ${A}

	cd "${S}"
	# add docbook switch so we can disable it
	epatch "${FILESDIR}"/${PN}-2.3.2-docbook.patch

	eautoreconf

	# elibtoolize
	epunt_cxx #74077
}

src_compile() {
	[ "${ARCH}" == "alpha" -a "${CC}" == "ccc" ] && \
		die "Dont compile fontconfig with ccc, it doesnt work very well"

	# disable docs only disables local docs generation, they come with the tarball
	econf $(use_enable doc docs) \
		$(use_enable doc docbook) \
		--localstatedir="${EPREFIX}"/var \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-default-fonts="${EPREFIX}"/usr/share/fonts \
		--with-add-fonts="${EPREFIX}"/usr/local/share/fonts,"${EPREFIX}"/usr/X11R6/lib/X11/fonts \
		$(use_enable xml libxml2) \
		|| die

	emake -j1 || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	insinto /etc/fonts
	doins "${S}"/fonts.conf
	newins "${S}"/fonts.conf fonts.conf.new

	cd "${S}"
	newman doc/fonts-conf.5 fonts-conf.5

	dohtml doc/fontconfig-user.html
	dodoc doc/fontconfig-user.{txt,pdf}

	if use doc; then
		doman doc/Fc*.3
		dohtml doc/fontconfig-devel.html doc
		dohtml -r doc/fontconfig-devel
		dodoc doc/fontconfig-devel.{txt,pdf}
	fi

	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf, we force update it ...
	# <azarah@gentoo.org> (11 Dec 2002)
	ewarn "Please make fontconfig configuration changes in /etc/fonts/conf.d/"
	ewarn "and NOT to /etc/fonts/fonts.conf, as it will be replaced!"
	mv -f ${EROOT}/etc/fonts/fonts.conf.new ${EROOT}/etc/fonts/fonts.conf
	rm -f ${EROOT}/etc/fonts/._cfg????_fonts.conf

	if [ "${EROOT}" = "/" ]
	then
		ebegin "Creating global font cache..."
		"${EPREFIX}"/usr/bin/fc-cache -s
		eend $?
	fi
}
