# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/aegis/aegis-4.19.ebuild,v 1.8 2008/06/30 01:43:53 darkside Exp $

IUSE="tk"

DESCRIPTION="A transaction based revision control system"
SRC_URI="mirror://sourceforge/aegis/${P}.tar.gz"
HOMEPAGE="http://aegis.sourceforge.net"

DEPEND="sys-libs/zlib
	sys-devel/gettext
	sys-apps/groff
	sys-devel/bison
	tk? ( >=dev-lang/tk-8.3 )"
RDEPEND="" #221421

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86-linux ~ppc-macos"

src_compile() {
	# By default aegis configure puts shareable read/write files (locks etc)
	# in ${prefix}/com/aegis but the FHS says /var/lib/aegis can be shared.

	myconf="${myconf} --with-nlsdir=${EPREFIX}/usr/share/locale"

	econf \
		--sharedstatedir="${EPREFIX}"/var/lib/aegis \
		--with-nlsdir="${EPREFIX}"/usr/share/locale \
		|| die "./configure failed"

	# Second ebuild causes redefined/undefined function errors
	make clean

	# not emake safe, I think
	make || die
}

src_install () {
	make RPM_BUILD_ROOT="${D}" install || die

	# Alas gentoo appears to have no profile.d mechanism, so:
	rm "${ED}"/etc/profile.d/aegis.sh
	rm "${ED}"/etc/profile.d/aegis.csh
	rmdir "${ED}"/etc/profile.d
	rmdir "${ED}"/etc

	# OK so ${ED}/var/lib/aegis gets UID=3, but for some
	# reason so do the files under /usr/share, even though
	# they are read-only.
	use prefix || chown -R root:0 "${ED}"/usr/share
	dodoc lib/en/*

	# Link to share dir so user has a chance of noticing it.
	dosym /usr/share/aegis /usr/share/doc/${PF}/scripts

	# Config file examples are documentation.
	mv "${ED}"/usr/share/aegis/config.example "${ED}"/usr/share/doc/${PF}/

	dodoc BUILDING MANIFEST README
}
