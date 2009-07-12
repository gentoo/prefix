# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/tcpdump/tcpdump-4.0.1_pre20090709.ebuild,v 1.1 2009/07/09 15:49:03 pva Exp $

EAPI="2"
inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="A Tool for network monitoring and data acquisition"
HOMEPAGE="http://www.tcpdump.org/"
MY_P=${PN}-${PV/_pre/-}
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"
S=${WORKDIR}/${MY_P}
#	SRC_URI="http://www.tcpdump.org/release/${P}.tar.gz
#		http://www.jp.tcpdump.org/release/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="+chroot smi ssl ipv6 -samba test"

RDEPEND="net-libs/libpcap
	smi? ( net-libs/libsmi )
	ssl? ( >=dev-libs/openssl-0.9.6m )"
DEPEND="${RDEPEND}
	test? ( app-arch/sharutils
		dev-lang/perl )"

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

src_configure() {
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
		$(use_with chroot chroot /var/lib/tcpdump)
}

src_compile() {
	make CCOPT="$CFLAGS" || die "make failed"
}

src_test() {
	sed '/^\(bgp_vpn_attrset\|ikev2four\|espudp1\|eapon1\)/d;' -i tests/TESTLIST
	make check || die "tests failed"
}

src_install() {
	dosbin tcpdump || die
	doman tcpdump.1 || die
	dodoc *.awk || die
	dodoc CHANGES CREDITS README || die

	keepdir /var/lib/tcpdump
	fperms 700 /var/lib/tcpdump
	fowners tcpdump:tcpdump /var/lib/tcpdump
}
