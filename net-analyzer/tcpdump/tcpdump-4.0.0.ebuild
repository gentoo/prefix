# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/tcpdump/tcpdump-4.0.0.ebuild,v 1.2 2009/02/20 18:57:18 armin76 Exp $

EAPI=1
inherit autotools flag-o-matic toolchain-funcs eutils

DESCRIPTION="A Tool for network monitoring and data acquisition"
HOMEPAGE="http://www.tcpdump.org/"
SRC_URI="http://www.tcpdump.org/release/${P}.tar.gz
	http://www.jp.tcpdump.org/release/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="+chroot smi ssl ipv6 samba"

DEPEND="net-libs/libpcap
	smi? ( net-libs/libsmi )
	ssl? ( >=dev-libs/openssl-0.9.6m )"

pkg_setup() {
	if use samba ; then
		ewarn
		ewarn "CAUTION !!! CAUTION !!! CAUTION"
		ewarn
		ewarn "You're about to compile tcpdump with samba printing support"
		ewarn "Upstream tags it as 'possibly-buggy SMB printer'"
		ewarn "So think twice whether this is fine with you"
		ewarn
		ewarn "CAUTION !!! CAUTION !!! CAUTION"
		ewarn
		ewarn "(Giving you 10 secs to think about it)"
		ewarn
		ebeep 5
		epause 5
	fi
	enewgroup tcpdump
	enewuser tcpdump -1 -1 -1 tcpdump
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-libsmi-autodep.patch"
	epatch "${FILESDIR}/${P}-ipv6-build.patch"
	eautoreconf
}

src_compile() {
	# tcpdump needs some optymalization. see bug #108391
	( ! is-flag -O? || is-flag -O0 ) && append-flags -O2

	replace-flags -O[3-9] -O2
	filter-flags -finline-functions

	# Fix wrt bug #48747
	if [[ $(gcc-major-version) -gt 3 ]] || \
		[[ $(gcc-major-version) -eq 3 && $(gcc-minor-version) -ge 4 ]]
	then
		filter-flags -funit-at-a-time
		append-flags -fno-unit-at-a-time
	fi

	econf --with-user=tcpdump \
		$(use_with ssl crypto) \
		$(use_with smi) \
		$(use_enable ipv6) \
		$(use_enable samba smb) \
		$(use_enable chroot chroot /var/lib/tcpdump)

	make CCOPT="$CFLAGS" || die "make failed"
}

src_install() {
	dosbin tcpdump || die
	doman tcpdump.1
	dodoc *.awk
	dodoc CHANGES CREDITS README

	keepdir /var/lib/tcpdump
	fperms 700 /var/lib/tcpdump
	fowners tcpdump:tcpdump /var/lib/tcpdump
}
