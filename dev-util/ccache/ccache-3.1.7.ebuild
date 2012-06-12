# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ccache/ccache-3.1.7.ebuild,v 1.6 2012/06/07 22:15:47 ranger Exp $

inherit multilib

DESCRIPTION="fast compiler cache"
HOMEPAGE="http://ccache.samba.org/"
SRC_URI="http://samba.org/ftp/ccache/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# make sure we always use system zlib
	rm -rf zlib
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS.txt MANUAL.txt NEWS.txt README.txt

	dobin "${FILESDIR}"/ccache-config || die
	dosed "/^LIBDIR=/s:lib:$(get_libdir):" /usr/bin/ccache-config

	if use !prefix ; then
		diropts -m0700
		dodir /root/.ccache
		keepdir /root/.ccache
	else
		sed -i -e "s:/usr/:${EPREFIX}/usr/:" \
			${ED}/usr/bin/ccache-config || die
		sed -i -e "s:/etc/:${EPREFIX}/etc/:" \
			${ED}/usr/bin/ccache-config || die
	fi
}

pkg_postinst() {
	"${EROOT}"/usr/bin/ccache-config --install-links
	"${EROOT}"/usr/bin/ccache-config --install-links ${CHOST}

	# nuke broken symlinks from previous versions that shouldn't exist
	rm -f "${EROOT}/usr/$(get_libdir)/ccache/bin/${CHOST}-cc"
	[[ -d "${EROOT}/usr/$(get_libdir)/ccache.backup" ]] && \
		rm -rf "${EROOT}/usr/$(get_libdir)/ccache.backup"

	elog "To use ccache with **non-Portage** C compiling, add"
	elog "/usr/$(get_libdir)/ccache/bin to the beginning of your path, before /usr/bin."
	elog "Portage 2.0.46-r11+ will automatically take advantage of ccache with"
	elog "no additional steps.  If this is your first install of ccache, type"
	elog "something like this to set a maximum cache size of 2GB:"
	elog "# ccache -M 2G"
	elog
	elog "If you are upgrading from an older version than 3.x you should clear"
	elog "all of your caches like so:"
	elog "# CCACHE_DIR='${CCACHE_DIR:-${PORTAGE_TMPDIR}/ccache}' ccache -C"
}
