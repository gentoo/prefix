# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/arj/arj-3.10.22-r1.ebuild,v 1.5 2005/12/10 00:20:20 herbs Exp $

EAPI="prefix"

inherit gnuconfig eutils toolchain-funcs

DESCRIPTION="Utility for opening arj archives"
HOMEPAGE="http://arj.sourceforge.net/"
SRC_URI="mirror://sourceforge/arj/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""
RESTRICT="nostrip"

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/001_arches_align.patch"
	epatch "${FILESDIR}/002_no_remove_static_const.patch"
	epatch "${FILESDIR}/003_64_bit_clean.patch"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	if [ -x ${EPREFIX}/usr/sbin/gcc-config ]
	then
		# Do we have a gcc that use the new layout and gcc-config ?
		if ${EPREFIX}/usr/sbin/gcc-config --get-current-profile &> /dev/null
		then
			export GCC_PROFILE="$(${EPREFIX}/usr/sbin/gcc-config --get-current-profile)"

			# Just recheck gcc version ...
			if [ "$(gcc-version)" != "3.2" ] && [ "$(gcc-version)" != "3.3" ]
			then
				# See if we can get a gcc profile we know is proper ...
				if ${EPREFIX}/usr/sbin/gcc-config --get-bin-path ${CHOST}-3.3.4 &> /dev/null
				then
					export PATH="$(${EPREFIX}/usr/sbin/gcc-config --get-bin-path ${CHOST}-3.3.4):${PATH}"
					export GCC_PROFILE="${CHOST}-3.3.4"
				else
					eerror "This build needs gcc-3.2 or gcc-3.3!"
					eerror
					eerror "Use gcc-config to change your gcc profile:"
					eerror
					eerror "  # gcc-config $CHOST-3.3.4"
					eerror
					eerror "or whatever gcc version is relevant."
					die
				fi
			fi
		fi
	fi

	gnuconfig_update

	cd ${S}/gnu
	autoconf
	econf || die

	cd ${S}
	make prepare || die "make prepare failed"
	make package || die "make package failed"
}

src_install() {
	case $CHOST in
		*darwin8)
			cd "${S}"/darwin8/en/rs/u
			;;
		*darwin7)
			cd "${S}"/darwin7/en/rs/u
			;;
		# todo add solaris, bsd, etc
		*)
			cd "${S}"/linux-gnu/en/rs/u
			;;
	esac
	dobin bin/* || die
	dodoc doc/arj/* ${S}/ChangeLog
}
