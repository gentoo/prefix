# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/dictd/dictd-1.10.9.ebuild,v 1.1 2007/08/18 01:15:54 philantrop Exp $

EAPI="prefix"

DESCRIPTION="Dictionary Client/Server for the DICT protocol"
HOMEPAGE="http://www.dict.org/"
SRC_URI="mirror://sourceforge/dict/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

# The dictd tests are broken.
RESTRICT="test"

src_unpack() {
	unpack ${A}

	cd "${S}"
	sed -i -e 's:^CFLAGS=\(.*\):CFLAGS=\1 -fPIC:' libmaa/Makefile.in
	
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's:libtool:glibtool:g' libmaa/Makefile.in Makefile.in
}

src_compile() {
	# with-local-libmaa is needed because libmaa is not in the tree
	# because nothing in the whole wide world but dictd uses it.
	# There are no sources apart from those in dictd, no homepage, nothing.
	# Doesn't really make sense to split it off from dictd into its own package
	# and add that just for dictd.
	econf \
		--with-cflags="${CFLAGS}" \
		--with-local-libmaa \
		--without-local-zlib \
		--without-local-dmalloc \
		--without-local-regex \
		--without-checker \
		--without-efence \
		--without-insure \
		--without-purify \
		--disable-plugin \
		--sysconfdir="${EPREFIX}"/etc/dict || die "econf failed"
	emake || die "make failed"
}

src_install() {
	# Now install it.
	make DESTDIR="${D}" install || die "install failed"

	# Install docs
	dodoc README TODO COPYING ChangeLog ANNOUNCE || die "installing docs part 1 failed"
	dodoc doc/dicf.ms doc/rfc.ms doc/rfc.sh doc/rfc2229.txt || die "installing docs part 2 failed"
	dodoc doc/security.doc doc/toc.ms || die "installing docs part 3 failed"

	# conf files.
	dodir /etc/dict
	insinto /etc/dict
	doins "${FILESDIR}"/${PVR}/dict.conf
	doins "${FILESDIR}"/${PVR}/dictd.conf
	doins "${FILESDIR}"/${PVR}/site.info

	# startups for dictd
	newinitd "${FILESDIR}"/${PVR}/dictd dictd
	newconfd "${FILESDIR}"/${PVR}/dictd.confd dictd

	# Remove useless cruft, fixes bug 107376
	rm -f ${ED}/usr/bin/colorit
	rm -f ${ED}/usr/share/man/man1/colorit.1
}

pkg_postinst() {
	echo
	elog "To start and use ${PN} you will have to emerge at least one dictionary from"
	elog "the app-dicts category with the package name starting with 'dictd-'."
	elog "To install all available dictionaries, emerge app-dicts/dictd-dicts."
	elog "${PN} will NOT start without at least one dictionary."
	echo
}
