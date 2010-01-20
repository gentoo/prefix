# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/encodings/encodings-1.0.3.ebuild,v 1.9 2010/01/18 18:32:28 armin76 Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org font encodings"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# font-util is required for bootstrapping, which _may_ be done (depending on
# platform) in the x-modular eclass...
RDEPEND=""
DEPEND="${RDEPEND}
	x11-apps/mkfontscale
	media-fonts/font-util"

CONFIGURE_OPTIONS="--with-encodingsdir=${EPREFIX}/usr/share/fonts/encodings"

ECONF_SOURCE="${S}"

src_compile() {
	mkdir "${S}"/build
	cd "${S}"/build
	x-modular_src_compile
}

src_install() {
	cd "${S}"/build
	x-modular_src_install
}
