# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-themes/gtk-engines-rezlooks/gtk-engines-rezlooks-0.6.ebuild,v 1.7 2008/12/20 18:58:42 maekke Exp $

inherit autotools

DESCRIPTION="Rezlooks GTK+ Engine"
HOMEPAGE="http://www.gnome-look.org/content/show.php?content=39179"
SRC_URI="http://www.gnome-look.org/content/files/39179-rezlooks-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/rezlooks-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# automake complains: ChangeLog missing. There however is a Changelog.
	# to avoid problems with case insensitive fs, move somewhere else first.
	mv Changelog{,.1}
	mv Changelog.1 ChangeLog

	eautoreconf # required for interix
}

src_compile() {
	econf --disable-dependency-tracking --enable-animation
	emake || die "make failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS Changelog CREDITS NEWS README
}
