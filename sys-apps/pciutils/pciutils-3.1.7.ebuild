# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pciutils/pciutils-3.1.7.ebuild,v 1.2 2010/04/11 19:32:33 vapier Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs

DESCRIPTION="Various utilities dealing with the PCI bus"
HOMEPAGE="http://atrey.karlin.mff.cuni.cz/~mj/pciutils.html"
SRC_URI="ftp://atrey.karlin.mff.cuni.cz/pub/linux/pci/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="network-cron zlib"

DEPEND="zlib? ( sys-libs/zlib )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-install-lib.patch #273489
	epatch "${FILESDIR}"/${P}-fbsd.patch #262321
	epatch "${FILESDIR}"/${PN}-2.2.7-update-pciids-both-forms.patch
}

uyesno() { use $1 && echo yes || echo no ; }
pemake() {
	emake \
		HOST="${CHOST}" \
		CROSS_COMPILE="${CHOST}-" \
		CC="$(tc-getCC)" \
		DNS="yes" \
		IDSDIR="\$(SHAREDIR)/misc" \
		MANDIR="\$(SHAREDIR)/man" \
		PREFIX="${EPREFIX}/usr" \
		SHARED="yes" \
		STRIP="" \
		ZLIB=$(uyesno zlib) \
		LIBDIR="\${PREFIX}/$(get_libdir)" \
		"$@"
}

src_compile() {
	pemake OPT="${CFLAGS}" all || die
}

src_install() {
	pemake DESTDIR="${D}" install install-lib || die
	dodoc ChangeLog README TODO

	if use network-cron ; then
		exeinto /etc/cron.monthly
		newexe "${FILESDIR}"/pciutils.cron update-pciids \
			|| die "Failed to install update cronjob"
	fi

	# Install both forms until HAL has migrated
	if use zlib ; then
		local sharedir="${ED}/usr/share/misc"
		elog "Providing a backwards compatibility non-compressed pci.ids"
		gzip -d <"${sharedir}"/pci.ids.gz >"${sharedir}"/pci.ids
	fi

	newinitd "${FILESDIR}"/init.d-pciparm pciparm
	newconfd "${FILESDIR}"/conf.d-pciparm pciparm
}

pkg_postinst() {
	elog "The 'pcimodules' program has been replaced by 'lspci -k'"
}
